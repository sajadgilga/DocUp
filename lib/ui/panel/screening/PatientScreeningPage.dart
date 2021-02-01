import 'package:Neuronio/blocs/EntityBloc.dart';
import 'package:Neuronio/blocs/ScreenginBloc.dart';
import 'package:Neuronio/constants/assets.dart';
import 'package:Neuronio/constants/colors.dart';
import 'package:Neuronio/constants/strings.dart';
import 'package:Neuronio/models/MedicalTest.dart';
import 'package:Neuronio/models/NoronioService.dart';
import 'package:Neuronio/models/Screening.dart';
import 'package:Neuronio/models/UserEntity.dart';
import 'package:Neuronio/ui/mainPage/NavigatorView.dart';
import 'package:Neuronio/ui/panel/PanelAlert.dart';
import 'package:Neuronio/ui/panel/partnerContact/chatPage/PartnerInfo.dart';
import 'package:Neuronio/ui/widgets/APICallError.dart';
import 'package:Neuronio/ui/widgets/APICallLoading.dart';
import 'package:Neuronio/ui/widgets/ActionButton.dart';
import 'package:Neuronio/ui/widgets/AutoText.dart';
import 'package:Neuronio/ui/widgets/DocupHeader.dart';
import 'package:Neuronio/ui/widgets/PageTopLeftIcon.dart';
import 'package:Neuronio/ui/widgets/SquareBoxNoronioClinic.dart';
import 'package:Neuronio/utils/Utils.dart';
import 'package:Neuronio/utils/entityUpdater.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timelines/timelines.dart';

class PatientScreeningPage extends StatefulWidget {
  final Function(String, UserEntity) onPush;
  final Function(String, MedicalTestPageData) globalOnPush;

  PatientScreeningPage({@required this.onPush, @required this.globalOnPush});

  @override
  _PatientScreeningPageState createState() => _PatientScreeningPageState();
}

class _PatientScreeningPageState extends State<PatientScreeningPage> {
  void _initialApiCall() {
    var _state = BlocProvider.of<EntityBloc>(context).state;
    EntityAndPanelUpdater.processOnEntityLoad((entity) {
      if (_state.entity.isPatient) {
        BlocProvider.of<ScreeningBloc>(context).add(GetPatientScreening());
      }
    });
  }

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    _initialApiCall();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ScreeningBloc, ScreeningState>(
        builder: (context, state) {
      if (state is ScreeningLoaded) {
        PatientScreeningResponse screeningResponse = state.result;

        /// TODO remove this part
        if (screeningResponse.active == 1) {
          return _mainWidget(state.result);
        } else {
          return Stack(
            children: [
              _mainWidget(state.result),
              buyScreeningPanelAlert(state.result)
            ],
          );
        }
      } else if (state is ScreeningLoading) {
        return DocUpAPICallLoading2();
      } else {
        return APICallError(() {
          _initialApiCall();
        });
      }
    });
  }

  Widget buyScreeningPanelAlert(
      PatientScreeningResponse patientScreeningResponse) {
    return PanelAlert(
      callback: () {
        widget.onPush(NavigatorRoutes.buyScreening, null);
      },
      label: Strings.noActiveScreeningPlan,
      buttonLabel: "توضیحات بیشتر درباره سنجش",
    );
  }

  Widget _myDoctor(PatientScreeningResponse patientScreeningResponse) {
    return Padding(
      padding: EdgeInsets.only(right: 23, top: 20, left: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(),
                child: AutoText(
                  "پزشک من",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 30),
                child: Container(
                    width: 25,
                    child: Image.asset(
                      Assets.panelMyDoctorIcon,
                      width: 25,
                      height: 25,
                      color: IColors.themeColor,
                    )),
              ),
            ],
          ),
          patientScreeningResponse.statusSteps.doctor == null
              ? Container(
                  padding: EdgeInsets.all(10),
                  child: AutoText("پزشکی هنوز برای شما تعیین نشده"),
                )
              : Container(
                  alignment: Alignment.centerRight,
                  child: PartnerInfo(
                    entity: patientScreeningResponse.statusSteps.doctor,
                    bgColor: Color.fromARGB(0, 0, 0, 0),
                    padding: EdgeInsets.only(top: 8.0, bottom: 8.0, left: 8.0),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _mainWidget(PatientScreeningResponse patientScreeningResponse) {
    return SingleChildScrollView(
      child: Container(
        child: Column(
          children: <Widget>[
            PageTopLeftIcon(
              topLeft: Icon(
                Icons.arrow_back,
                color: IColors.themeColor,
                size: 20,
              ),
              topLeftFlag: false,
              topRight: Padding(
                padding: EdgeInsets.only(right: 25),
                child: menuLabel("پنل کاربری", fontSize: 20),
              ),
              topRightFlag: true,
              onTap: () {},
            ),
            _myDoctor(patientScreeningResponse),
            _timeLineWidget(patientScreeningResponse),
          ],
        ),
      ),
    );
  }

  Widget _timeLineWidget(PatientScreeningResponse patientScreeningResponse) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: FixedTimeline.tileBuilder(
        theme: TimelineTheme.of(context).copyWith(
          nodePosition: 2,
        ),
        builder: TimelineTileBuilder.connected(
          contentsAlign: ContentsAlign.reverse,
          indicatorBuilder: (_, index) {
            if (index == 0) {
              int remaining =
                  patientScreeningResponse.statusSteps.remainingTestsToBeDone;
              return Indicator.outlined(
                borderWidth: 2,
                size: 25,
                color: remaining == 0 ? IColors.themeColor : Colors.amberAccent,
                child: Center(
                  child: remaining == 0
                      ? Icon(
                          Icons.check,
                          color: IColors.themeColor,
                        )
                      : AutoText(
                          replaceEnglishWithPersianNumber(remaining.toString()),
                        ),
                ),
              );
            } else if (index == 1) {
              bool done = patientScreeningResponse.statusSteps.icaStatus;
              return Indicator.outlined(
                borderWidth: 2,
                size: 25,
                color: done ? IColors.themeColor : Colors.amberAccent,
                child: Center(
                  child: done
                      ? Icon(
                          Icons.check,
                          color: IColors.themeColor,
                        )
                      : SizedBox(),
                ),
              );
            } else if (index == 2) {
              bool done = patientScreeningResponse.statusSteps.visitStatus;
              return Indicator.outlined(
                borderWidth: 2,
                size: 25,
                color: done ? IColors.themeColor : Colors.amberAccent,
                child: Center(
                  child: done
                      ? Icon(
                          Icons.check,
                          color: IColors.themeColor,
                        )
                      : SizedBox(),
                ),
              );
            } else if (index == 3) {
              bool done = patientScreeningResponse.statusSteps.visitStatus;

              return Indicator.outlined(
                borderWidth: 2,
                size: 25,
                color: done ? IColors.themeColor : Colors.amberAccent,
                child: Center(
                  child: done
                      ? Icon(
                          Icons.check,
                          color: IColors.themeColor,
                        )
                      : SizedBox(),
                ),
              );
            }
            return Container();
          },
          contentsBuilder: (_, index) {
            if (index == 0) {
              return onlineTestTimeLineItem(patientScreeningResponse);
            } else if (index == 1) {
              return icaTestTimeLineItem(patientScreeningResponse);
            } else if (index == 2) {
              return visitRequestTimeLineItem(patientScreeningResponse);
            } else if (index == 3) {
              return doctorPanelTimeLineItem(patientScreeningResponse);
            }
            return Container();
          },
          connectorBuilder: (context, index, type) => Connector.solidLine(
            thickness: 2,
            color: IColors.themeColor,
          ),
          itemCount: 4,
        ),
      ),
    );
  }

  Widget onlineTestTimeLineItem(
      PatientScreeningResponse patientScreeningResponse) {
    List<NoronioServiceItem> convertToNoronioServiceList(
        List<MedicalTestItem> tests) {
      List<NoronioServiceItem> services = [];

      tests.forEach((element) {
        NoronioServiceItem cognitiveTest = NoronioServiceItem(
            element.name,
            Assets.noronioServiceBrainTest,
            element.imageURL,
            NoronioClinicServiceType.MultipleChoiceTest, () {
          /// TODO
          MedicalTestPageData medicalTestPageData = MedicalTestPageData(
              MedicalPageDataType.Screening,
              patientEntity: null, onDone: () {
            _initialApiCall();
          },
              medicalTestItem: MedicalTestItem(element.testId, element.name),
              editableFlag: true,
              sendableFlag: true,
              screeningId: patientScreeningResponse.statusSteps.id);

          widget.globalOnPush(
              NavigatorRoutes.cognitiveTest, medicalTestPageData);
        }, !element.done);
        services.add(cognitiveTest);
      });

      return services;
    }

    Widget _services(List<NoronioServiceItem> serviceList) {
      List<Widget> serviceRows = [];
      for (int i = 0; i < serviceList.length; i += 2) {
        Widget ch1 = SquareBoxNoronioClinicService(
          serviceList[i],
          showDoneIcon: !(serviceList[i].enable ?? false),
          boxSize: 110,
          showLocation: false,
          defaultBgColor: IColors.whiteTransparent,
          bFontSize: 9,
          lFontSize: 7,
        );
        Widget ch2 = (i == serviceList.length - 1)
            ? SquareBoxNoronioClinicService(
                NoronioServiceItem.empty(),
                boxSize: 110,
                bFontSize: 9,
                showLocation: false,
                lFontSize: 7,
              )
            : SquareBoxNoronioClinicService(
                serviceList[i + 1],
                showDoneIcon: !(serviceList[i + 1].enable ?? false),
                boxSize: 110,
                defaultBgColor: IColors.whiteTransparent,
                bFontSize: 9,
                showLocation: false,
                lFontSize: 7,
              );

        serviceRows.add(Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [ch1, ch2],
        ));
      }
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: serviceRows,
          ),
        ),
      );
    }

    return Card(
        child: Container(
      padding: EdgeInsets.all(8.0),
      width: MediaQuery.of(context).size.width * 0.8,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                child: menuLabel(
                  "تست های آنلاین",
                ),
                width: MediaQuery.of(context).size.width * 0.4,
                height: 50,
              ),
            ],
          ),
          patientScreeningResponse.statusSteps.testsResponseStatus.isEmpty
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      child: AutoText(
                        "تستی برای پلن سنجش تعریف نشده",
                      ),
                      width: MediaQuery.of(context).size.width * 0.5,
                      height: 50,
                    ),
                  ],
                )
              : _services(convertToNoronioServiceList(
                  patientScreeningResponse.statusSteps.medicalTestItems))
        ],
      ),
    ));
  }

  Widget icaTestTimeLineItem(
      PatientScreeningResponse patientScreeningResponse) {
    return Card(
        child: Container(
      padding: EdgeInsets.all(8.0),
      width: MediaQuery.of(context).size.width * 0.8,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                child: menuLabel(
                  "تست ICA",
                ),
                width: MediaQuery.of(context).size.width * 0.5,
                height: 50,
              ),
            ],
          ),

          /// TODO
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                alignment: Alignment.center,
                child: AutoText(
                  "با شما تماس گرفته می شود.",
                ),
                width: MediaQuery.of(context).size.width * 0.5,
                height: 50,
              ),
            ],
          )
        ],
      ),
    ));
  }

  Widget visitRequestTimeLineItem(
      PatientScreeningResponse patientScreeningResponse) {
    return Card(
        child: Container(
      padding: EdgeInsets.all(8.0),
      width: MediaQuery.of(context).size.width * 0.8,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                child: menuLabel(
                  "ثبت درخواست ویزیت",
                ),
                width: MediaQuery.of(context).size.width * 0.5,
                height: 50,
              ),
            ],
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.5,
            child: ActionButton(
              title: "صفحه درخواست ویزیت",
              color: patientScreeningResponse.statusSteps.icaStatus
                  ? IColors.themeColor
                  : IColors.disabledButton,
              height: 50,
              callBack: () {
                if (patientScreeningResponse.statusSteps.icaStatus) {
                  widget.onPush(NavigatorRoutes.doctorDialogue,
                      patientScreeningResponse.statusSteps.doctor);
                } else {
                  toast(context, "شما هنوز تست ICA را کامل نکردید.");
                }
              },
            ),
          )
        ],
      ),
    ));
  }

  Widget doctorPanelTimeLineItem(
      PatientScreeningResponse patientScreeningResponse) {
    return Card(
        child: Container(
      padding: EdgeInsets.all(8.0),
      width: MediaQuery.of(context).size.width * 0.8,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                child: menuLabel(
                  "ارتباط با پزشک",
                ),
                width: MediaQuery.of(context).size.width * 0.5,
                height: 50,
              ),
            ],
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.5,
            child: ActionButton(
              title: "پنل ارتباطی",
              color: patientScreeningResponse.statusSteps.visitStatus
                  ? IColors.themeColor
                  : IColors.disabledButton,
              height: 50,
              callBack: () {
                if (patientScreeningResponse.statusSteps.visitStatus) {
                  widget.onPush(NavigatorRoutes.myPartnerDialog,
                      patientScreeningResponse.statusSteps.doctor);
                } else {
                  toast(context,
                      "شما هنوز درخواست ویزیتی را برای پزشک ارسال نکردید");
                }
              },
            ),
          )
        ],
      ),
    ));
  }
}
