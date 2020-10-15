import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:docup/blocs/DoctorInfoBloc.dart';
import 'package:docup/blocs/PanelBloc.dart';
import 'package:docup/blocs/SearchBloc.dart';
import 'package:docup/constants/assets.dart';
import 'package:docup/constants/colors.dart';
import 'package:docup/constants/strings.dart';
import 'package:docup/models/PatientEntity.dart';
import 'package:docup/models/VisitResponseEntity.dart';
import 'package:docup/networking/Response.dart';
import 'package:docup/ui/visitsList/visitSearchResult/VisitResult.dart';
import 'package:docup/ui/widgets/APICallError.dart';
import 'package:docup/ui/widgets/APICallLoading.dart';
import 'package:docup/ui/widgets/ActionButton.dart';
import 'package:docup/ui/widgets/Avatar.dart';
import 'package:docup/ui/widgets/PageTopLeftIcon.dart';
import 'package:docup/ui/widgets/VerticalSpace.dart';
import 'package:docup/utils/Utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PatientRequestPage extends StatefulWidget {
  final PatientEntity patientEntity;

  PatientRequestPage({Key key, this.patientEntity}) : super(key: key);

  @override
  _PatientRequestPageState createState() => _PatientRequestPageState();
}

class _PatientRequestPageState extends State<PatientRequestPage> {
  DoctorInfoBloc _bloc = DoctorInfoBloc();

  void _updateSearch() {
    var searchBloc = BlocProvider.of<SearchBloc>(context);
    searchBloc.add(SearchVisit(text: ''));
    var _panelBloc = BlocProvider.of<PanelBloc>(context);
    _panelBloc.add(GetMyPanels());
  }

  @override
  void initState() {
    _bloc.responseVisitStream.listen((data) {
      if (data.status == Status.COMPLETED) {
        String span = data.data.status == 1 ? "تایید" : "رد";
        toast(context, 'درخواست بیمار با موفقیت $span شد');
        _updateSearch();
        Navigator.pop(context);
      } else if (data.status == Status.ERROR) {
        toast(context, data.error.toString());
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _bloc.getVisit(widget.patientEntity.vid);
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => _bloc.getVisit(widget.patientEntity.vid),
        child: StreamBuilder<Response<VisitEntity>>(
          stream: _bloc.getVisitStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              switch (snapshot.data.status) {
                case Status.LOADING:
                  return APICallLoading();
                  break;
                case Status.COMPLETED:
                  return _headerWidget(snapshot.data.data);
                  break;
                case Status.ERROR:
                  return APICallError(
                    errorMessage: Strings.notFoundRequest,
                    onRetryPressed: () =>
                        _bloc.getVisit(widget.patientEntity.vid),
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
                    topLeftFlag: true,
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
                child: Text(
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
                          Text(
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
                            _bloc.responseVisit(visitEntity, false);
                          },
                        ),
                        ActionButton(
                          width: 150,
                          title: "تایید",
                          icon: Icon(Icons.check),
                          color: IColors.green,
                          callBack: () {
                            _bloc.responseVisit(visitEntity, true);
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
                        _bloc.responseVisit(visitEntity, false);
                      },
                    ),
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
    double maxHeight =
        max(MediaQuery.of(context).size.height * (15 / 100), 250);
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5, vertical: 15),
      constraints: BoxConstraints(maxHeight: maxHeight, minHeight: minHeight),
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
                Text(
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
    Widget _prevVisitHealthFileItem() {
      return Container(
        child: Column(
          children: <Widget>[
            Container(
              width: 150.0,
              height: 100.0,
              decoration: BoxDecoration(
                image: DecorationImage(
                    fit: BoxFit.cover, image: AssetImage('assets/hand1.jpg')),
                borderRadius: BorderRadius.all(Radius.circular(15)),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                child: Container(
                  color: Colors.white.withOpacity(.1),
                ),
              ),
            ),
            Text(
              'تصویر',
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: IColors.darkGrey,
              ),
            )
          ],
        ),
      );
    }

    List<Widget> pictures = [];

    /// TODO amir: Here we should fetch prev image visit health file
    return Container(
      margin: EdgeInsets.only(right: 15, top: 10),
      child: pictures.isEmpty
          ? Text(
              "پرونده ای موجود نمی باشد",
              style: TextStyle(fontSize: 14, color: IColors.darkGrey),
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: pictures,
            ),
    );
  }

  _patientDataWidget(VisitEntity entity) {
    String visitMethod = entity.visitMethod == 0 ? "متنی" : "تصویری";
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
                  width: 60,
                  child: Text(
                    replaceFarsiNumber(normalizeDateAndTime(entity.visitTime)),
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
                  Text(
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
                      Text(
                        entity.visitType == 0
                            ? "ویزیت حضوری"
                            : "ویزیت مجازی، $visitMethod",
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
