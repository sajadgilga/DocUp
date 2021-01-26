import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:Neuronio/blocs/DoctorInfoBloc.dart';
import 'package:Neuronio/blocs/EntityBloc.dart';
import 'package:Neuronio/blocs/PanelBloc.dart';
import 'package:Neuronio/blocs/SearchBloc.dart';
import 'package:Neuronio/constants/assets.dart';
import 'package:Neuronio/constants/colors.dart';
import 'package:Neuronio/constants/strings.dart';
import 'package:Neuronio/models/PatientEntity.dart';
import 'package:Neuronio/models/VisitResponseEntity.dart';
import 'package:Neuronio/networking/Response.dart';
import 'package:Neuronio/services/googleCalendarService.dart';
import 'package:Neuronio/ui/visitsList/visitSearchResult/VisitResult.dart';
import 'package:Neuronio/ui/widgets/APICallError.dart';
import 'package:Neuronio/ui/widgets/APICallLoading.dart';
import 'package:Neuronio/ui/widgets/ActionButton.dart';
import 'package:Neuronio/ui/widgets/AutoText.dart';
import 'package:Neuronio/ui/widgets/Avatar.dart';
import 'package:Neuronio/ui/widgets/PageTopLeftIcon.dart';
import 'package:Neuronio/ui/widgets/PicList.dart';
import 'package:Neuronio/ui/widgets/VerticalSpace.dart';
import 'package:Neuronio/utils/CrossPlatformDeviceDetection.dart';
import 'package:Neuronio/utils/CrossPlatformSvg.dart';
import 'package:Neuronio/utils/Utils.dart';
import 'package:Neuronio/utils/dateTimeService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PatientRequestPage extends StatefulWidget {
  final PatientEntity patientEntity;

  PatientRequestPage({Key key, this.patientEntity}) : super(key: key);

  @override
  _PatientRequestPageState createState() => _PatientRequestPageState();
}

class _PatientRequestPageState extends State<PatientRequestPage> {
  DoctorInfoBloc _bloc = DoctorInfoBloc();

  //TODO amir: make it and enum, here and now 0 means physical visit
  int patientVisitStatus = 0;
  int sectionId;
  bool submitLoadingToggle = false;

  VisitEntity visitEntity;

  void _updateSearch() {
    var searchBloc = BlocProvider.of<SearchBloc>(context);
    if (patientVisitStatus == 0 || patientVisitStatus == 1) {
      searchBloc.add(SearchVisit(
          text: '', acceptStatus: 1, visitType: patientVisitStatus));
    } else {
      searchBloc.add(SearchVisit(text: '', acceptStatus: 0));
    }
    var _panelBloc = BlocProvider.of<PanelBloc>(context);
    _panelBloc.add(GetMyPanels());
  }

  @override
  void initState() {
    _bloc.getVisit(widget.patientEntity.vid);

    var _state = BlocProvider.of<EntityBloc>(context).state;
    this.sectionId = _state.entity.sectionIdByNameAndPatientEntityId(
        Strings.testResults, widget.patientEntity.id);
    // if (sectionId != null)
    //   BlocProvider.of<FileBloc>(context)
    //       .add(FileListGet(listId: this.sectionId));

    _bloc.responseVisitStream.listen((data) {
      if (data.status == Status.COMPLETED) {
        submitLoadingToggle = false;

        void _doneAndClosePage() {
          _updateSearch();
          BlocProvider.of<EntityBloc>(context).add(EntityGet());
          Navigator.pop(context);
        }

        if (data.data.status == 1) {
          if (PlatformDetection.isAndroid) {
            showTwoButtonDialog(
                context,
                'درخواست بیمار تایید  شد.' +
                    "\n" +
                    "آیا مایلید این ویزیت را در گوگل کلندر خود اضافه کنید؟",
                "بله",
                "خیر", () {
              GoogleCalenderService.addVisitEvent(
                      visitEntity, widget.patientEntity)
                  .then((result) {
                if (result) {
                  toast(context, Strings.visitEventAddedToGoogleCalendar,
                      secs: 13);
                } else {
                  toast(context, Strings.visitEventFailedForGoogleCalendar,
                      secs: 13);
                }
                _doneAndClosePage();
              });
            }, () {
              _doneAndClosePage();
            });
          } else {
            showOneButtonDialog(context, 'درخواست بیمار تایید  شد', "تایید",
                () {
              _doneAndClosePage();
            });
          }
        } else {
          showOneButtonDialog(context, 'درخواست بیمار رد شد.', "تایید", () {
            _doneAndClosePage();
          });
        }
      } else if (data.status == Status.ERROR) {
        toast(context, data.error.toString());
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => _bloc.getVisit(widget.patientEntity.vid),
        child: StreamBuilder<Response<VisitEntity>>(
          stream: _bloc.getVisitStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              switch (snapshot.data.status) {
                case Status.LOADING:
                  return DocUpAPICallLoading2();
                  break;
                case Status.COMPLETED:
                  visitEntity = snapshot.data.data;
                  if (visitEntity.status == 0) {
                    patientVisitStatus = null;
                  } else {
                    patientVisitStatus = visitEntity.visitType;
                  }
                  return _headerWidget(visitEntity);
                  break;
                case Status.ERROR:
                  return APICallError(
                    () {
                      _bloc.getVisit(widget.patientEntity.vid);
                    },
                    errorMessage: Strings.notFoundRequest,
                  );
                  break;
              }
            }
            return Container();
          },
        ),
      ),
    );
  }

  _headerWidget(VisitEntity visitEntity) => SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: <Widget>[
              Stack(
                alignment: Alignment.center,
                children: [
                  PageTopLeftIcon(
                    topLeft: Icon(
                      Icons.arrow_back,
                      size: 25,
                      color: IColors.themeColor,
                    ),
                    onTap: () {
                      /// TODO
                      Navigator.pop(context, 'Nope.');
                    },
                    topRightFlag: false,
                    topLeftFlag: PlatformDetection.isIOS,
                  ),
                ],
              ),
              ALittleVerticalSpace(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  _patientDataWidget(visitEntity),
                  SizedBox(width: 10),
                  PolygonAvatar(
                    user: widget.patientEntity.user,
                    imageSize: 80,
                  ),
                ],
              ),
              SizedBox(height: 50),
              descriptionBox(
                "توضیحات:",
                Icon(Icons.info_outline),
                child: AutoText(
                  ([null, ""].contains(visitEntity.patientMessage))
                      ? "توضیحاتی موجود نمی باشد"
                      : visitEntity.patientMessage,
                  style: TextStyle(fontSize: 14, color: IColors.darkGrey),
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                ),
              ),
              descriptionBox(
                  "پرونده سلامت",
                  Image.asset(
                    Assets.patientDetailFilesIcon,
                    width: 15,
                    height: 15,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          AutoText(
                            "پرونده سلامت (در صورت ویزیت قبلی)",
                            textAlign: TextAlign.right,
                          ),
                        ],
                      ),
                      _picListBox(MediaQuery.of(context).size.width),
                    ],
                  )),
              SizedBox(
                height: 20,
              ),
              visitEntity.status == 0
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        ActionButton(
                          width: 150,
                          title: "رد",
                          icon: Icon(Icons.close),
                          color: IColors.red,
                          callBack: () {
                            if (!submitLoadingToggle) {
                              submitLoadingToggle = true;
                              _bloc.responseVisit(visitEntity, false);
                            }
                          },
                        ),
                        ActionButton(
                          width: 150,
                          title: "تایید",
                          icon: Icon(Icons.check),
                          color: IColors.green,
                          callBack: () {
                            if (!submitLoadingToggle) {
                              submitLoadingToggle = true;
                              _bloc.responseVisit(visitEntity, true);
                            }
                          },
                        ),
                      ],
                    )
                  : ActionButton(
                      width: MediaQuery.of(context).size.width * (65 / 100),
                      height: 50,
                      title: "لغو کردن ویزیت " +
                          (visitEntity.visitType == 0
                              ? "حضوری"
                              : (visitEntity.visitType == 1 ? "مجازی" : " - ")),
                      icon: Icon(Icons.close),
                      color: IColors.red,
                      callBack: () {
                        if (!submitLoadingToggle) {
                          submitLoadingToggle = true;
                          _bloc.responseVisit(visitEntity, false);
                        }
                      },
                    ),
              ALittleVerticalSpace(),
            ],
          ),
        ),
      );

  int _calculatePossiblePicCount(width) {
    return ((width - 50) / 160).toInt();
  }

  Widget descriptionBox(String title, Widget titleIcon, {Widget child}) {
    double minHeight =
        min(MediaQuery.of(context).size.height * (15 / 100), 250);
    // double maxHeight =
    //     max(MediaQuery.of(context).size.height * (15 / 100), 250);
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5, vertical: 15),
      constraints: BoxConstraints(minHeight: minHeight),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(15))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 7, right: 7),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                AutoText(
                  title,
                  style: TextStyle(fontSize: 16, color: IColors.darkGrey),
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                ),
                SizedBox(
                  width: 10,
                ),
                titleIcon,
              ],
            ),
          ),
          ALittleVerticalSpace(),
          child ?? SizedBox()
        ],
      ),
    );
  }

  Widget _picListBox(width) {
    return PicList(
      listId: this.sectionId,
      uploadAvailable: false,
      picLabel: Strings.panelTestResultsPicLabel,
      recentLabel: Strings.panelTestResultsPicListLabel,
      emptyListLabel: Strings.emptyTestFiles,
      uploadLabel: "",
      asset: CrossPlatformSvg.asset(
        "assets/cloud.svg",
        height: 35,
        width: 35,
        color: IColors.themeColor,
      ),
      tapCallback: () {},
    );
  }

  _patientDataWidget(VisitEntity entity) {
    return Expanded(
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.check,
                  color: IColors.green,
                ),
                Container(
                  width: 65,
                  child: AutoText(
                    replaceFarsiNumber(DateTimeService.normalizeDateAndTime(
                        entity.visitTime,
                        cutSeconds: true)),
                    style: TextStyle(fontSize: 12, color: IColors.green),
                    textAlign: TextAlign.end,
                    maxLines: 4,
                  ),
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.only(left: 10),
              alignment: Alignment.centerRight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  AutoText(
                      widget.patientEntity.user.name.split(" ")[0] +
                          " \n " +
                          (widget.patientEntity.user.name + " ")
                              .split(" ")
                              .sublist(1)
                              .join(" "),
                      maxLines: 3,
                      textAlign: TextAlign.right,
                      softWrap: true,
                      overflow: TextOverflow.fade,
                      textDirection: TextDirection.rtl,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      AutoText(
                        entity.visitTypeAndMethodDescription,
                        textAlign: TextAlign.right,
                        softWrap: true,
                        overflow: TextOverflow.fade,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: IColors.themeColor),
                      ),
                      SizedBox(
                        child: PatientStatus.values[entity.status].icon,
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
