import 'package:Neuronio/blocs/EntityBloc.dart';
import 'package:Neuronio/blocs/ScreenginBloc.dart';
import 'package:Neuronio/constants/assets.dart';
import 'package:Neuronio/constants/colors.dart';
import 'package:Neuronio/constants/strings.dart';
import 'package:Neuronio/models/MedicalTest.dart';
import 'package:Neuronio/models/NoronioService.dart';
import 'package:Neuronio/models/Screening.dart';
import 'package:Neuronio/models/UserEntity.dart';
import 'package:Neuronio/repository/ScreeningRepository.dart';
import 'package:Neuronio/ui/mainPage/NavigatorView.dart';
import 'package:Neuronio/ui/panel/PanelAlert.dart';
import 'package:Neuronio/ui/panel/partnerContact/chatPage/PartnerInfo.dart';
import 'package:Neuronio/ui/visit/VisitUtils.dart';
import 'package:Neuronio/ui/widgets/APICallError.dart';
import 'package:Neuronio/ui/widgets/APICallLoading.dart';
import 'package:Neuronio/ui/widgets/ActionButton.dart';
import 'package:Neuronio/ui/widgets/AutoText.dart';
import 'package:Neuronio/ui/widgets/DocupHeader.dart';
import 'package:Neuronio/ui/widgets/PageTopLeftIcon.dart';
import 'package:Neuronio/ui/widgets/SquareBoxNeuronioClinic.dart';
import 'package:Neuronio/utils/Utils.dart';
import 'package:Neuronio/utils/EntityUpdater.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timelines/timelines.dart';

class PatientScreeningPage extends StatefulWidget {
  final Function(String, UserEntity, int, VisitSource) onPush;
  final Function(String, MedicalTestPageData) globalOnPush;
  final int panelId;
  final UserEntity partner;

  PatientScreeningPage(
      {@required this.onPush,
      @required this.globalOnPush,
      this.panelId,
      this.partner});

  @override
  _PatientScreeningPageState createState() => _PatientScreeningPageState();
}

class _PatientScreeningPageState extends State<PatientScreeningPage> {
  void _initialApiCall() {
    EntityAndPanelUpdater.processOnEntityLoad((entity) {
      /// it could be patient or doctor requesting screening step detail for monitoring
      if (entity.isDoctor) {
        BlocProvider.of<ScreeningBloc>(context).add(
            GetPatientScreening(panelId: widget.panelId, withLoading: true));
      } else {
        int panelId = entity.panelByPartnerId.id;

        BlocProvider.of<ScreeningBloc>(context)
            .add(GetPatientScreening(panelId: panelId, withLoading: true));
      }
    });
  }

  @override
  void initState() {
    var _state = BlocProvider.of<EntityBloc>(context).state;
    if (_state.entity.isDoctor) {
      /// we should initial api call because it is not called in entity updater cause here it us not in main page
      _initialApiCall();
    } else if (_state.entity.isPatient) {
      /// do nothing because it is already initialed in entity updater
    }

    // SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ScreeningBloc, ScreeningState>(
        builder: (context, state) {
      if (state is ScreeningLoaded || state.result != null) {
        PatientScreeningResponse screeningResponse = state.result;

        if (screeningResponse.active == 1) {
          return _mainWidget(state.result);
        } else {
          return Stack(
            children: [
              _mainWidget(state.result),
              _noActiveScreeningSteps(state.result)
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

  Widget _noActiveScreeningSteps(
      PatientScreeningResponse patientScreeningResponse) {
    if (BlocProvider.of<EntityBloc>(context).state.entity.isPatient) {
      return PanelAlert(
        callback: () {
          widget.onPush(
              NavigatorRoutes.buyScreening, null, null, VisitSource.SCREENING);
        },
        label: InAppStrings.noActiveScreeningPlanForPatient,
        buttonLabel: "توضیحات بیشتر درباره سنجش",
      );
    }
    return PanelAlert(
      callback: () {
        Navigator.pop(context);
      },
      buttonLabel: "بازگشت",
      label: InAppStrings.noActiveScreeningPlanForDoctor,
    );
  }

  Widget _myPartner(PatientScreeningResponse patientScreeningResponse) {
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
                  BlocProvider.of<EntityBloc>(context).state.entity.isPatient
                      ? "پزشک من"
                      : "بیمار من",
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
                    entity: BlocProvider.of<EntityBloc>(context)
                            .state
                            .entity
                            .isPatient
                        ? patientScreeningResponse.statusSteps.doctor
                        : widget.partner,
                    bgColor: Color.fromARGB(0, 0, 0, 0),
                    padding: EdgeInsets.only(top: 8.0, bottom: 8.0, left: 8.0),
                    onPush: (_, __) {},
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
                child: menuLabel("پلن غربالگری", fontSize: 20),
              ),
              topRightFlag: true,
              onTap: () {},
            ),
            _myPartner(patientScreeningResponse),
            _timeLineWidget(patientScreeningResponse),
            // ActionButton(
            //   title: "گزارش پروفایل",
            //   callBack: () {
            // widget.onPush(NavigatorRoutes.screeningAutoGeneratedReport, null,
            //     patientScreeningResponse.statusSteps.id, VisitSource.ICA);
            // },
            // color: IColors.themeColor,
            // )
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
    List<NeuronioServiceItem> convertToNeuronioServiceList(
        List<MedicalTestItem> tests) {
      List<NeuronioServiceItem> services = [];

      tests.forEach((element) {
        NeuronioServiceItem cognitiveTest = NeuronioServiceItem(
            element.name,
            Assets.neuronioServiceBrainTest,
            element.imageURL,
            NeuronioClinicServiceType.MultipleChoiceTest, () {
          if (BlocProvider.of<EntityBloc>(context).state.entity.isPatient) {
            if (element.isGoogleDocTest) {
              ScreeningRepository repo = ScreeningRepository();
              repo
                  .doScreeningTestLifeQ(
                      element.testId, patientScreeningResponse.statusSteps.id)
                  .then((value) {
                _initialApiCall();
              });
              launchURL(element.testLink);
            } else if (element.isInAppTest) {
              MedicalTestPageData medicalTestPageData = MedicalTestPageData(
                  MedicalPageDataType.Screening,
                  patientEntity: null, onDone: () {
                _initialApiCall();
              },
                  medicalTestItem:
                      MedicalTestItem(element.testId, element.name),
                  editableFlag: true,
                  sendableFlag: true,
                  screeningId: patientScreeningResponse.statusSteps.id);

              widget.globalOnPush(
                  NavigatorRoutes.cognitiveTest, medicalTestPageData);
            }
          }
        }, !element.done);
        services.add(cognitiveTest);
      });

      return services;
    }

    Widget _services(List<NeuronioServiceItem> serviceList) {
      List<Widget> serviceRows = [];
      for (int i = 0; i < serviceList.length; i += 2) {
        Widget ch1 = SquareBoxNeuronioClinicService(
          serviceList[i],
          showDoneIcon: !(serviceList[i].enable ?? false),
          boxSize: 110,
          showLocation: false,
          defaultBgColor: IColors.whiteTransparent,
          bFontSize: 9,
          lFontSize: 7,
        );
        Widget ch2 = (i == serviceList.length - 1)
            ? SquareBoxNeuronioClinicService(
                NeuronioServiceItem.empty(),
                boxSize: 110,
                bFontSize: 9,
                showLocation: false,
                lFontSize: 7,
              )
            : SquareBoxNeuronioClinicService(
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
              : _services(convertToNeuronioServiceList(
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
                  "تست هوشمند سلامت شناختی",
                ),
                width: MediaQuery.of(context).size.width * 0.5,
                height: 50,
              ),
            ],
          ),
          ActionButton(
            title: BlocProvider.of<EntityBloc>(context).state.entity.isPatient
                ? "صفحه درخواست ویزیت ICA"
                : "صفحه نمره دهی ICA",
            color:
                patientScreeningResponse.statusSteps.remainingTestsToBeDone == 0
                    ? IColors.themeColor
                    : IColors.disabledButton,
            height: 50,
            callBack: () {
              if (BlocProvider.of<EntityBloc>(context).state.entity.isPatient) {
                if (patientScreeningResponse
                        .statusSteps.remainingTestsToBeDone ==
                    0) {
                  widget.onPush(
                      NavigatorRoutes.doctorDialogue,
                      patientScreeningResponse.statusSteps.clinicDoctor,
                      null,
                      VisitSource.ICA);
                } else {
                  toast(context, "شما هنوز تست‌های اولیه را کامل نکردید.");
                }
              } else {
                widget.onPush(NavigatorRoutes.icaTestScoring, widget.partner,
                    patientScreeningResponse.statusSteps.id, VisitSource.ICA);
              }
            },
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
                if (BlocProvider.of<EntityBloc>(context)
                    .state
                    .entity
                    .isPatient) {
                  if (patientScreeningResponse.statusSteps.icaStatus) {
                    if (patientScreeningResponse.statusSteps.doctor == null) {
                      widget.onPush(
                          NavigatorRoutes.selectDoctorForScreening,
                          null,
                          patientScreeningResponse.statusSteps.id,
                          VisitSource.SCREENING);
                    } else {
                      widget.onPush(
                          NavigatorRoutes.doctorDialogue,
                          patientScreeningResponse.statusSteps.doctor,
                          patientScreeningResponse.statusSteps.id,
                          VisitSource.SCREENING);
                    }
                  } else {
                    toast(
                        context, "شما هنوز تست‌های اولیه ICA را کامل نکردید.");
                  }
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
                if (BlocProvider.of<EntityBloc>(context)
                    .state
                    .entity
                    .isPatient) {
                  if (patientScreeningResponse.statusSteps.visitStatus) {
                    widget.onPush(
                        NavigatorRoutes.myPartnerDialog,
                        patientScreeningResponse.statusSteps.doctor,
                        null,
                        VisitSource.SCREENING);
                  } else {
                    toast(context,
                        "شما هنوز درخواست ویزیتی را برای پزشک ارسال نکردید");
                  }
                }
              },
            ),
          )
        ],
      ),
    ));
  }
}
