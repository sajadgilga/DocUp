import 'dart:convert';

import 'package:Neuronio/blocs/ChatMessageBloc.dart';
import 'package:Neuronio/blocs/EntityBloc.dart';
import 'package:Neuronio/blocs/FileBloc.dart';
import 'package:Neuronio/blocs/MedicalTestListBloc.dart';
import 'package:Neuronio/blocs/PanelBloc.dart';
import 'package:Neuronio/blocs/PanelSectionBloc.dart';
import 'package:Neuronio/blocs/PatientTrackerBloc.dart';
import 'package:Neuronio/blocs/SearchBloc.dart';
import 'package:Neuronio/blocs/TabSwitchBloc.dart';
import 'package:Neuronio/blocs/VisitBloc.dart';
import 'package:Neuronio/blocs/TextPlanBloc.dart';
import 'package:Neuronio/blocs/visit_time/visit_time_bloc.dart';
import 'package:Neuronio/constants/strings.dart';
import 'package:Neuronio/models/DoctorEntity.dart';
import 'package:Neuronio/models/DoctorPlan.dart';
import 'package:Neuronio/models/PatientEntity.dart';
import 'package:Neuronio/models/TextPlan.dart';
import 'package:Neuronio/models/UserEntity.dart';
import 'package:Neuronio/ui/account/doctorProfileAndPlans/DoctorProfileMenuPage.dart';
import 'package:Neuronio/ui/account/doctorProfileAndPlans/DoctorProfilePage.dart';
import 'package:Neuronio/ui/account/doctorProfileAndPlans/EditableEventTable.dart';
import 'package:Neuronio/ui/account/doctorProfileAndPlans/VisitConfPage.dart';
import 'package:Neuronio/ui/account/patientProfile/PatientProfileMenuPage.dart';
import 'package:Neuronio/ui/account/patientProfile/PatientProfilePage.dart';
import 'package:Neuronio/ui/doctorDetail/DoctorDetailPage.dart';
import 'package:Neuronio/ui/home/notification/NotificationPage.dart';
import 'package:Neuronio/ui/medicalTest/MedicalTestPage.dart';
import 'package:Neuronio/ui/noronioClinic/NoronioService.dart';
import 'package:Neuronio/ui/panel/Panel.dart';
import 'package:Neuronio/ui/panel/healthDocument/infoPage/InfoPage.dart';
import 'package:Neuronio/ui/panel/healthFile/calander/DateCalander.dart';
import 'package:Neuronio/ui/panel/healthFile/calander/TimeCalander.dart';
import 'package:Neuronio/ui/panel/healthFile/eventPage/EventPage.dart';
import 'package:Neuronio/ui/panel/healthFile/medicinePage/MedicinePage.dart';
import 'package:Neuronio/ui/panel/myPartners/MyPartnerDialog.dart';
import 'package:Neuronio/ui/panel/myPartners/MyPartners.dart';
import 'package:Neuronio/ui/panel/panelMenu/PanelMenu.dart';
import 'package:Neuronio/ui/panel/partnerContact/chatPage/ChatPage.dart';
import 'package:Neuronio/ui/panel/partnerContact/illnessPage/IllnessPage.dart';
import 'package:Neuronio/ui/panel/partnerContact/videoOrVoiceCallPage/VideoOrVoiceCallPage.dart';
import 'package:Neuronio/ui/panel/screening/ActivateScreeningPlan.dart';
import 'package:Neuronio/ui/panel/screening/ICATestScore.dart';
import 'package:Neuronio/ui/panel/screening/PatientScreeningPage.dart';
import 'package:Neuronio/ui/panel/screening/SelectingDoctor.dart';
import 'package:Neuronio/ui/panel/searchPage/SearchPage.dart';
import 'package:Neuronio/ui/patientVisitDetail/PatientRequestPage.dart';
import 'package:Neuronio/ui/plan/PlanPage.dart';
import 'package:Neuronio/ui/visit/PhysicalVisitPage.dart';
import 'package:Neuronio/ui/visit/VirtualVisitPage.dart';
import 'package:Neuronio/ui/visit/VisitUtils.dart';
import 'package:Neuronio/ui/visitsList/PhysicalVisitListPage.dart';
import 'package:Neuronio/ui/visitsList/VirtualVisitListPage.dart';
import 'package:Neuronio/ui/visitsList/VisitRequestsListPage.dart';
import 'package:Neuronio/ui/widgets/APICallLoading.dart';
import 'package:Neuronio/ui/widgets/AutoText.dart';
import 'package:Neuronio/ui/widgets/UploadSlider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../home/Home.dart';
import 'MainPage.dart';

class NavigatorRoutes {
  static const String mainPage = '/mainPage';
  static const String doctorDialogue = '/doctorDialogue';
  static const String selectDoctorForScreening = "/selectDoctorForScreening";
  static const String patientDialogue = '/patientDialogue';
  static const String root = '/';
  static const String notificationView = '/notification';

  // static const String panelMenu = '/panelMenu';
  static const String panel = '/panel';
  static const String myPartnerDialog = '/myPartnerDialog';
  static const String buyScreening = "/buyScreening";
  static const String patientScreening = "/patientScreening";
  static const String icaTestScoring = "/icaTestScoring";

  static const String account = '/account';
  static const String partnerSearchView = '/searchView';
  static const String visitRequestList = '/visitRequestList';
  static const String physicalVisitList = '/physicalVisitList';
  static const String virtualVisitList = '/virtualVisitList';

  static const String virtualVisitPage = '/virtualVisitPage';
  static const String physicalVisitPage = '/physicalVisitPage';

  /// TODO may we have change in label later
  static const String textPlanPage = "/textPlanPage";

  static const String uploadFileDialogue = '/uploadFileDialogue';
  static const String cognitiveTest = '/cognitiveTest';

  static const String visitConfig = '/visitConfig';
  static const String doctorTimeTable = "/doctorTimeTable";
  static const String doctorProfileMenuPage = '/doctorProfileMenuPage';
  static const String patientProfileMenuPage = '/patientProfileMenuPage';
}

class NavigatorView extends StatefulWidget {
  final int index;
  final GlobalKey<NavigatorState> navigatorKey;
  Function(String, dynamic, dynamic, dynamic, Function) pushOnBase;
  Function(int) selectPage;

  NavigatorView(
      {Key key,
      this.index,
      this.navigatorKey,
      this.pushOnBase,
      this.selectPage})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return NavigatorViewState();
  }
}

class NavigatorViewState extends State<NavigatorView> {
  final TabSwitchBloc _tabSwitchBloc = TabSwitchBloc();
  final PanelSectionBloc _panelSectionBloc = PanelSectionBloc();
  final ChatMessageBloc _chatMessageBloc = ChatMessageBloc();
  final SearchBloc _searchBloc = SearchBloc();
  final VisitBloc _visitBloc = VisitBloc();
  final FileBloc _pictureBloc = FileBloc();
  final PatientTrackerBloc _trackerBloc = PatientTrackerBloc();
  final VisitTimeBloc _visitTimeBloc = VisitTimeBloc();
  final MedicalTestListBloc _medicalTestListBloc = MedicalTestListBloc();
  final TextPlanBloc _textPlanBloc = TextPlanBloc();

  @override
  dispose() {
    try {
      _tabSwitchBloc.close();
      _panelSectionBloc.close();
      _chatMessageBloc.close();
      _searchBloc.close();
      _visitBloc.close();
      _pictureBloc.close();
      _trackerBloc.close();
      _visitTimeBloc.close();
    } catch (e) {}
    super.dispose();
  }

  Map<String, WidgetBuilder> _routeBuilders(BuildContext context,
      {param1, param2, param3}) {
    switch (widget.index) {
      case -1:
        return {
          NavigatorRoutes.root: (context) => MainPage(
                pushOnBase: (direction, p1, p2, p3, returnCallBack) {
                  push(context, direction,
                      param1: p1,
                      param2: p2,
                      param3: p3,
                      returnCallBack: returnCallBack);
                },
              ),
          NavigatorRoutes.panel: (context) => Scaffold(
              body: _panel(context, detail: param1, extraDetail: param2)),
          NavigatorRoutes.doctorDialogue: (context) =>
              _doctorDetailPage(context, param1, param2, param3),
          NavigatorRoutes.selectDoctorForScreening: (context) =>
              _screeningDoctorSelectionPage(context, param2),
          NavigatorRoutes.patientDialogue: (context) =>
              _patientDetailPage(context, param1),
          NavigatorRoutes.partnerSearchView: (context) =>
              _partnerSearchPage(context, detail: param1),
          NavigatorRoutes.cognitiveTest: (context) =>
              _cognitiveTest(context, param1),
          NavigatorRoutes.uploadFileDialogue: (context) => BlocProvider.value(
              value: _pictureBloc,
              child: UploadFileSlider(
                  listId: param1, partnerId: param2, body: param3)),
          NavigatorRoutes.visitRequestList: (context) =>
              _visitRequestPage(context),
          NavigatorRoutes.account: (context) =>
              _account(context, defaultCreditForCharge: param1),
          NavigatorRoutes.virtualVisitPage: (context) =>
              _virtualVisitPage(context, param1, param2, param3),
          NavigatorRoutes.visitConfig: (context) => _visitConf(context, param1),
          NavigatorRoutes.doctorProfileMenuPage: (context) =>
              _doctorProfileMenuPage(context, param1),
          NavigatorRoutes.patientProfileMenuPage: (context) =>
              _patientProfileMenuPage(context, param1),
          NavigatorRoutes.physicalVisitPage: (context) =>
              _physicalVisitPage(context, param1, param2, param3)
        };
      case 0:
        return {
          NavigatorRoutes.root: (context) => _home(context),
          NavigatorRoutes.notificationView: (context) => _notificationPage(),
          NavigatorRoutes.account: (context) =>
              _account(context, defaultCreditForCharge: param1),
          NavigatorRoutes.doctorDialogue: (context) =>
              _doctorDetailPage(context, param1, param2, param3),
          NavigatorRoutes.selectDoctorForScreening: (context) =>
              _screeningDoctorSelectionPage(context, param2),
          NavigatorRoutes.patientDialogue: (context) =>
              _patientDetailPage(context, param1),
          NavigatorRoutes.cognitiveTest: (context) =>
              _cognitiveTest(context, param1),
          NavigatorRoutes.partnerSearchView: (context) =>
              _partnerSearchPage(context, detail: param1),
          NavigatorRoutes.visitRequestList: (context) =>
              _visitRequestPage(context),
          NavigatorRoutes.uploadFileDialogue: (context) => BlocProvider.value(
              value: _pictureBloc,
              child: UploadFileSlider(
                listId: param1,
                partnerId: param2,
                body: param3,
              )),
          NavigatorRoutes.physicalVisitList: (context) =>
              _physicalVisitListPage(context),
          NavigatorRoutes.virtualVisitList: (context) =>
              _virtualVisitListPage(context),
          NavigatorRoutes.account: (context) =>
              _account(context, defaultCreditForCharge: param1),
          NavigatorRoutes.virtualVisitPage: (context) =>
              _virtualVisitPage(context, param1, param2, param3),
          NavigatorRoutes.visitConfig: (context) => _visitConf(context, param1),
          NavigatorRoutes.doctorProfileMenuPage: (context) =>
              _doctorProfileMenuPage(context, param1),
          NavigatorRoutes.physicalVisitPage: (context) =>
              _physicalVisitPage(context, param1, param2, param3),
          NavigatorRoutes.textPlanPage: (context) =>
              _textPlanPage(context, param1),
          NavigatorRoutes.myPartnerDialog: (context) =>
              _myPartnerDialog(context, param1),
          NavigatorRoutes.panel: (context) =>
              _panel(context, detail: param1, extraDetail: param2),
        };
      case 1:
        return {
          NavigatorRoutes.root: (context) => _myPanelsMenuList(context),
          NavigatorRoutes.myPartnerDialog: (context) =>
              _myPartnerDialog(context, param1),
          NavigatorRoutes.patientScreening: (context) =>
              _patientScreeningPage(context, partner: param1, panelId: param3),
          NavigatorRoutes.icaTestScoring: (context) =>
              _icaTestScoring(screeningStepId: param2, partner: param1),
          NavigatorRoutes.buyScreening: (context) => _buyScreeningPage(context),
          NavigatorRoutes.panel: (context) =>
              _panel(context, detail: param1, extraDetail: param2),
          NavigatorRoutes.textPlanPage: (context) =>
              _textPlanPage(context, param1),
          NavigatorRoutes.doctorDialogue: (context) =>
              _doctorDetailPage(context, param1, param2, param3),
          NavigatorRoutes.selectDoctorForScreening: (context) =>
              _screeningDoctorSelectionPage(context, param2),
          NavigatorRoutes.patientDialogue: (context) =>
              _patientDetailPage(context, param1),
          NavigatorRoutes.cognitiveTest: (context) =>
              _cognitiveTest(context, param1),
          NavigatorRoutes.uploadFileDialogue: (context) => BlocProvider.value(
              value: _pictureBloc,
              child: UploadFileSlider(
                listId: param1,
                partnerId: param2,
                body: param3,
              )),
          NavigatorRoutes.partnerSearchView: (context) =>
              _partnerSearchPage(context, detail: param1),
          NavigatorRoutes.visitRequestList: (context) =>
              _visitRequestPage(context),
          NavigatorRoutes.account: (context) =>
              _account(context, defaultCreditForCharge: param1),
          NavigatorRoutes.virtualVisitPage: (context) =>
              _virtualVisitPage(context, param1, param2, param3),
          NavigatorRoutes.visitConfig: (context) => _visitConf(context, param1),
          NavigatorRoutes.doctorProfileMenuPage: (context) =>
              _doctorProfileMenuPage(context, param1),
          NavigatorRoutes.physicalVisitPage: (context) =>
              _physicalVisitPage(context, param1, param2, param3)
        };
      case 2:
        return {
          NavigatorRoutes.root: (context) => _noronioClinic(context),
          NavigatorRoutes.partnerSearchView: (context) =>
              _partnerSearchPage(context, detail: param1),
          NavigatorRoutes.textPlanPage: (context) =>
              _textPlanPage(context, param1),
          NavigatorRoutes.physicalVisitPage: (context) =>
              _physicalVisitPage(context, param1, param2, param3),
          NavigatorRoutes.virtualVisitPage: (context) =>
              _virtualVisitPage(context, param1, param2, param3),
          NavigatorRoutes.doctorDialogue: (context) =>
              _doctorDetailPage(context, param1, param2, param3),
          NavigatorRoutes.selectDoctorForScreening: (context) =>
              _screeningDoctorSelectionPage(context, param2),
        };
      case 3:
        return {
          NavigatorRoutes.root: (context) => _account(context),
          // NavigatorRoutes.panelMenu: (context) => _panelMenu(context),
          NavigatorRoutes.visitConfig: (context) => _visitConf(context, param1),
          NavigatorRoutes.doctorTimeTable: (context) =>
              _doctorTimeTable(context, param1, param2),
          NavigatorRoutes.uploadFileDialogue: (context) => BlocProvider.value(
              value: _pictureBloc,
              child: UploadFileSlider(
                listId: param1,
                partnerId: param2,
                body: param3,
              )),
          NavigatorRoutes.doctorProfileMenuPage: (context) =>
              _doctorProfileMenuPage(context, param1),
          NavigatorRoutes.patientProfileMenuPage: (context) =>
              _patientProfileMenuPage(context, param1),
        };
      default:
        return {
          NavigatorRoutes.root: (context) => _home(context),
          NavigatorRoutes.notificationView: (context) => _notificationPage(),
          NavigatorRoutes.doctorDialogue: (context) =>
              _doctorDetailPage(context, param1, param2, param3),
          NavigatorRoutes.selectDoctorForScreening: (context) =>
              _screeningDoctorSelectionPage(context, param2),
          NavigatorRoutes.patientDialogue: (context) =>
              _patientDetailPage(context, param1),
          NavigatorRoutes.partnerSearchView: (context) =>
              _partnerSearchPage(context),
        };
    }
  }

//  void changePanelSection(int section) {
//    switch (section) {
//      case 0:
//        _panelSectionBloc.add(PanelSectionSelect(
//            patientSection: PatientPanelSection.DOCTOR_INTERFACE,
//            doctorSection: DoctorPanelSection.DOCTOR_INTERFACE,
//            section: PanelSection.PATIENT));
//        _tabSwitchBloc.add(PanelTabState.SecondTab);
//        break;
//    }
//  }

  void push(buildContext, String direction,
      {param1, param2, param3, returnCallBack}) {
    if (param1 == 'chat')
      widget.navigatorKey.currentState.popUntil((route) => route.isFirst);
    _route(RouteSettings(name: direction), context,
        detail: param1, extraDetail: param2, widgetArg: param3);
    widget.navigatorKey.currentState
        .push(_route(RouteSettings(name: direction), context,
            detail: param1, extraDetail: param2, widgetArg: param3))
        .then((value) {
      if (returnCallBack != null) {
        returnCallBack();
      }
    });
  }

  void _pop(BuildContext context) {
    Navigator.pop(context);
  }

  Route<dynamic> _route(RouteSettings settings, BuildContext context,
      {detail, extraDetail, widgetArg}) {
    var routeBuilders = _routeBuilders(context,
        param1: detail, param2: extraDetail, param3: widgetArg);
    return MaterialPageRoute(
        settings: settings,
        builder: (BuildContext context) {
          return routeBuilders[settings.name](context);
        });
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: widget.navigatorKey,
      initialRoute: NavigatorRoutes.root,
      observers: <NavigatorObserver>[HeroController()],
      onGenerateRoute: (settings) => _route(settings, context),
    );
  }

  Widget _home(context) {
    var entity = BlocProvider.of<EntityBloc>(context).state.entity;
    if (entity.isDoctor) {
      return MultiBlocProvider(
          providers: [
            BlocProvider<PatientTrackerBloc>.value(
              value: _trackerBloc,
            ),
          ],
          child: Home(
            selectPage: widget.selectPage,
            onPush: (direction, p1, p2, p3, returnCallBack) {
              push(context, direction,
                  param1: p1,
                  param2: p2,
                  param3: p3,
                  returnCallBack: returnCallBack);
            },
            globalOnPush: (string, entity) {
              widget.pushOnBase(string, entity, null, null, null);
            },
          ));
    } else if (entity.isPatient) {
      return Home(
        selectPage: widget.selectPage,
        onPush: (direction, p1, p2, p3, returnCallBack) {
          push(context, direction,
              param1: p1,
              param2: p2,
              param3: p3,
              returnCallBack: returnCallBack);
        },
        globalOnPush: (string, entity) {
          widget.pushOnBase(string, entity, null, null, null);
        },
      );
    }
  }

  Widget _account(context, {defaultCreditForCharge}) {
    var entity = BlocProvider.of<EntityBloc>(context).state.entity;
    if (entity.isDoctor) {
      return DoctorProfilePage(
        onPush: (direction, entity) {
          push(context, direction, param1: entity);
        },
      );
    } else {
      return PatientProfilePage(
        defaultCreditForCharge: defaultCreditForCharge,
        onPush: (direction, entity) {
          push(context, direction, param1: entity);
        },
      );
    }
  }

  Widget _noronioClinic(context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SearchBloc>.value(
          value: _searchBloc,
        ),
        BlocProvider<MedicalTestListBloc>.value(value: _medicalTestListBloc)
      ],
      child: NoronioServicePage(
        onPush: (direction, entity) {
          push(context, direction, param1: entity);
        },
        selectPage: widget.selectPage,
        globalOnPush: (string, entity) {
          widget.pushOnBase(string, entity, null, null, null);
        },
      ),
    );
  }

  Widget _cognitiveTest(context, detail) => MultiBlocProvider(
        providers: [
          BlocProvider<SearchBloc>.value(
            value: _searchBloc,
          ),
          BlocProvider<MedicalTestListBloc>.value(value: _medicalTestListBloc)
        ],
        child: MedicalTestPage(
          testPageInitData: detail,
          onPush: (direction, entity) {
            push(context, direction, param1: entity);
          },
        ),
      );

  Widget _notificationPage() => NotificationPage(
        onPush: (direction, param1, param2, param3, returnCallBack) {
          push(context, direction,
              param1: param1,
              param2: param2,
              param3: param3,
              returnCallBack: returnCallBack);
        },
      );

  Widget _panelPages(context, partner, PatientTextPlan patientTextPlan) {
    return BlocBuilder<EntityBloc, EntityState>(
        builder: (context, entityState) {
      return BlocBuilder<PanelSectionBloc, PanelSectionSelected>(
        builder: (context, state) {
          var entity = entityState.entity;
          entity.partnerEntity = partner;
          entity.iPanelId = entity.panelByPartnerId?.id;
          Entity copyEntity = entity.copy();
          if (state.patientSection == PatientPanelSection.DOCTOR_INTERFACE) {
            /// TODO cleaning
            // _visitTimeBloc.add(VisitTimeGet(partnerId: entity.pId));
            return Panel(
              onPush: (direction, entity) {
                push(context, direction, param1: entity);
              },
              pages: [
                [
                  IllnessPage(
                    entity: copyEntity,
                    textPlanRemainedTraffic: patientTextPlan,
                    globalOnPush: (string, entity) {
                      widget.pushOnBase(string, entity, null, null, null);
                    },
                    selectPage: widget.selectPage,
                    onPush: (direction, entity) {
                      push(context, direction, param1: entity);
                    },
                  )
                ],
                [
                  ChatPage(
                    entity: copyEntity,
                    patientTextPlan: patientTextPlan,
                    onPush: (direction, entity, screeningId, visitSource) {
                      push(context, direction,
                          param1: entity,
                          param2: screeningId,
                          param3: visitSource);
                    },
                  )
                ],
                [
                  VideoOrVoiceCallPage(
                    key: ValueKey("Video"),
                    entity: copyEntity,
                    onPush: (direction, entity, screening, visitSource) {
                      push(context, direction,
                          param1: entity,
                          param2: screening,
                          param3: visitSource);
                    },
                    videoCall: true,
                  ),
                  VideoOrVoiceCallPage(
                    key: ValueKey("voice"),
                    entity: copyEntity,
                    onPush: (direction, entity, screening, visitSource) {
                      push(context, direction,
                          param1: entity,
                          param2: screening,
                          param3: visitSource);
                    },
                    videoCall: false,
                  )
                ]
              ],
            );
          } else if (state.patientSection == PatientPanelSection.HEALTH_FILE) {
            return BlocProvider.value(
                value: _pictureBloc,
                child: Panel(
                  onPush: (direction, entity) {
                    push(context, direction, param1: entity);
                  },
                  pages: [
                    [
                      InfoPage(
                        uploadAvailable: entity.isDoctor,
                        textPlanRemainedTraffic: patientTextPlan,
                        entity: copyEntity,
                        onPush: (direction, listId, partnerId, widgetArg) {
                          push(context, direction,
                              param1: listId,
                              param2: partnerId,
                              param3: widgetArg);
                        },
                        pageName: Strings.doctorAdvice,
                        picListLabel: Strings.panelDoctorAdvicePicLabel,
                        lastPicsLabel: Strings.panelDoctorAdvicePicListLabel,
                        emptyFilesLabel: Strings.emptyPanelDoctorAdviceFiles,
                        uploadLabel: Strings.panelDoctorAdvicePicUploadLabel,
                      )
                    ],
                    [
                      InfoPage(
                        uploadAvailable: entity.isDoctor,
                        textPlanRemainedTraffic: patientTextPlan,
                        entity: copyEntity,
                        onPush: (direction, listId, partnerId, widgetArg) {
                          push(context, direction,
                              param1: listId,
                              param2: partnerId,
                              param3: widgetArg);
                        },
                        pageName: Strings.prescriptions,
                        picListLabel: Strings.panelPrescriptionsPicLabel,
                        lastPicsLabel: Strings.panelPrescriptionsPicListLabel,
                        emptyFilesLabel: Strings.emptyPrescriptionFiles,
                        uploadLabel: Strings.panelPrescriptionsUploadLabel,
                      )
                    ],
                    [
                      InfoPage(
                        uploadAvailable: entity.isDoctor || entity.isPatient,
                        textPlanRemainedTraffic: patientTextPlan,
                        entity: copyEntity,
                        onPush: (direction, listId, partnerId, widgetArg) {
                          push(context, direction,
                              param1: listId,
                              param2: partnerId,
                              param3: widgetArg);
                        },
                        pageName: Strings.testResults,
                        picListLabel: Strings.panelTestResultsPicLabel,
                        lastPicsLabel: Strings.panelTestResultsPicListLabel,
                        emptyFilesLabel: Strings.emptyTestFiles,
                        uploadLabel: Strings.panelTestResultsPicUploadLabel,
                      )
                    ],
                  ],
                ));
          } else if (state.patientSection ==
              PatientPanelSection.HEALTH_CALENDAR) {
            return BlocProvider.value(
                value: _pictureBloc,
                child: Panel(
                  onPush: (direction, entity) {
                    push(context, direction, param1: entity);
                  },
                  pages: [
                    [
                      DateCalender(
                        entity: copyEntity,
                        onPush: (direction, entity) {
                          push(context, direction, param1: entity);
                        },
                      ),
                      TimeCalender(
                        entity: copyEntity,
                        onPush: (direction, entity) {
                          push(context, direction, param1: entity);
                        },
                      )
                    ],
                    [
                      EventPage(
                        entity: copyEntity,
                        onPush: (direction, entity) {
                          push(context, direction, param1: entity);
                        },
                      )
                    ],
                    [
                      MedicinePage(
                        entity: copyEntity,
                        onPush: (direction, entity) {
                          push(context, direction, param1: entity);
                        },
                      )
                    ],
                  ],
                ));
          }
          return DocUpAPICallLoading2();
        },
      );
    });
  }

  Widget _panel(context, {incomplete, detail, extraDetail}) {
    if (detail != null)
      switch (detail) {
        case "chat":
          _panelSectionBloc.add(PanelSectionSelect(
              patientSection: PatientPanelSection.DOCTOR_INTERFACE));
          _tabSwitchBloc.add(tabs['chat']);
//          _tabSwitchBloc.add(PanelTabState.SecondTab);
          break;
        default:
          break;
      }
    return MultiBlocProvider(providers: [
      BlocProvider<TabSwitchBloc>.value(
        value: _tabSwitchBloc,
      ),
      BlocProvider<PanelSectionBloc>.value(
        value: _panelSectionBloc,
      ),
      BlocProvider<ChatMessageBloc>.value(
        value: _chatMessageBloc,
      ),
      BlocProvider<VisitTimeBloc>.value(
        value: _visitTimeBloc,
      ),
      BlocProvider<SearchBloc>.value(
        value: _searchBloc,
      ),
      BlocProvider<TextPlanBloc>.value(
        value: _textPlanBloc,
      ),
      BlocProvider<MedicalTestListBloc>.value(value: _medicalTestListBloc)
    ], child: _panelPages(context, detail, extraDetail));
  }

  Widget _screeningDoctorSelectionPage(context, extraDetail) {
    return BlocProvider.value(
      value: _searchBloc,
      child: ScreeningDoctorSelectionPage(
        onPush: (String, UserEntity, screeningId, visitSource) {
          push(context, String,
              param1: UserEntity, param2: screeningId, param3: visitSource);
        },
        screeningId: extraDetail,
      ),
    );
  }

  Widget _doctorDetailPage(
      context, DoctorEntity param1, int param2, VisitSource param3) {
    return DoctorDetailPage(
      onPush: (direction, entity, Function() returnCallBack, screeningId,
          visitSource) {
        push(context, direction,
            param1: entity,
            param2: screeningId,
            param3: visitSource,
            returnCallBack: returnCallBack);
      },
      doctorEntity: param1,
      screeningId: param2,
      type: param3,
    );
  }

  Widget _patientDetailPage(context, patient) {
    PatientEntity _patient = patient;
    try {
      _patient.user.name = utf8.decode(_patient.user.name.codeUnits);
    } catch (_) {}
    return MultiBlocProvider(
        providers: [
          BlocProvider<SearchBloc>.value(value: _searchBloc),
          BlocProvider<FileBloc>.value(value: _pictureBloc),
        ],
        child: PatientRequestPage(
          patientEntity: _patient,
        ));
  }

  Widget _partnerSearchPage(context, {isRequests = false, detail = null}) =>
      MultiBlocProvider(
          providers: [
            BlocProvider<SearchBloc>.value(value: _searchBloc),
          ],
          child: PartnerSearchPage(
            clinicIdDoctorSearch: detail,
            selectPage: widget.selectPage,
            onPush: (direction, entity, screeningId, visitSource) {
              push(context, direction,
                  param1: entity, param2: screeningId, param3: visitSource);
            },
          ));

  Widget _visitRequestPage(context) => MultiBlocProvider(
        providers: [
          BlocProvider<SearchBloc>.value(value: _searchBloc),
//            BlocProvider<VisitBloc>.value(value: _visitBloc),
        ],
        child: VisitRequestsPage(
          onPush: (direction, entity) {
            push(context, direction, param1: entity);
          },
        ),
      );

  Widget _virtualVisitListPage(context) => MultiBlocProvider(
        providers: [
          BlocProvider<SearchBloc>.value(value: _searchBloc),
        ],
        child: VirtualVisitList(
          onPush: (direction, entity) {
            push(context, direction, param1: entity);
          },
        ),
      );

  Widget _physicalVisitListPage(context) => MultiBlocProvider(
        providers: [
          BlocProvider<SearchBloc>.value(value: _searchBloc),
        ],
        child: PhysicalVisitList(
          onPush: (direction, entity) {
            push(context, direction, param1: entity);
          },
        ),
      );

//   Widget _panelMenu(context) {
// //    BlocProvider.of<PanelBloc>(context).add(GetMyPanels());
//     return MultiBlocProvider(
//       providers: [
//         BlocProvider<TabSwitchBloc>.value(
//           value: _tabSwitchBloc,
//         ),
//         BlocProvider<PanelSectionBloc>.value(
//           value: _panelSectionBloc,
//         ),
//         BlocProvider<SearchBloc>.value(value: _searchBloc),
//         BlocProvider<VisitTimeBloc>.value(
//           value: _visitTimeBloc,
//         ),
//       ],
//       child: PanelMenu(
//         () {
//           _pop(context);
//         },
//         onPush: (direction) {
//           push(context, direction);
//         },
//       ),
//     );
//   }

  Widget _buyScreeningPage(context) {
    return ActivateScreeningPage(onPush: (direction, entity) {
      push(context, direction, param1: entity);
    });
  }

  Widget _myPanelsMenuList(context) {
    var entity = BlocProvider.of<EntityBloc>(context).state.entity;
    if (entity.isDoctor) {
      return _myPartnersList(context);
    } else {
      return _patientScreeningPage(context);
    }
  }

  Widget _myPartnersList(context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<TabSwitchBloc>.value(
          value: _tabSwitchBloc,
        ),
        BlocProvider<PanelSectionBloc>.value(
          value: _panelSectionBloc,
        ),
        BlocProvider<SearchBloc>.value(value: _searchBloc),
        BlocProvider<VisitTimeBloc>.value(
          value: _visitTimeBloc,
        ),
      ],
      child: MyPartners(
        onPush: (direction, entity) {
          push(context, direction, param1: entity);
        },
      ),
    );
  }

  Widget _patientScreeningPage(context, {UserEntity partner, int panelId}) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<TabSwitchBloc>.value(
          value: _tabSwitchBloc,
        ),
        BlocProvider<PanelSectionBloc>.value(
          value: _panelSectionBloc,
        ),
        BlocProvider<SearchBloc>.value(value: _searchBloc),
        BlocProvider<VisitTimeBloc>.value(
          value: _visitTimeBloc,
        ),
      ],
      child: PatientScreeningPage(
        onPush: (direction, entity, screeningId, visitSource) {
          push(context, direction,
              param1: entity, param2: screeningId, param3: visitSource);
        },
        panelId: panelId,
        partner: partner,
        globalOnPush: (string, entity) {
          widget.pushOnBase(string, entity, null, null, null);
        },
      ),
    );
  }

  Widget _icaTestScoring({UserEntity partner, int screeningStepId}) {
    return ICATestScoring(
      partner: partner,
      screeningStepId: screeningStepId,
    );
  }

  Widget _myPartnerDialog(context, detail) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<TabSwitchBloc>.value(
          value: _tabSwitchBloc,
        ),
        BlocProvider<PanelSectionBloc>.value(
          value: _panelSectionBloc,
        ),
        BlocProvider<SearchBloc>.value(value: _searchBloc),
        BlocProvider<VisitTimeBloc>.value(
          value: _visitTimeBloc,
        ),
        BlocProvider<TextPlanBloc>.value(
          value: _textPlanBloc,
        ),
      ],
      child: MyPartnerDialog(
        partner: detail,
        onPush: (direction, entity, PatientTextPlan remainedTraffic,
            int panelId, Function returnCallBack) {
          push(context, direction,
              param1: entity,
              param2: remainedTraffic,
              param3: panelId,
              returnCallBack: returnCallBack);
        },
      ),
    );
  }

  Widget _empty(context) {
    return InStructure();
  }

  _doctorTimeTable(
      BuildContext context, List<int> availableVisitTypes, DoctorPlan plan) {
    return EditableDoctorPlanEventTable(
      plan,
      availableVisitTypes,
      showEventTitle: false,
    );
  }

  _visitConf(BuildContext context, entity) {
    return VisitConfPage(
      doctorId: (entity as DoctorEntity).id,
      onPush: (direction, visitTypes, plan, returnCallBack) {
        push(context, direction,
            param1: visitTypes, param2: plan, returnCallBack: returnCallBack);
      },
    );
  }

  _doctorProfileMenuPage(BuildContext context, entity) {
    return DoctorProfileMenuPage(
      doctorEntity: (entity as DoctorEntity),
      onPush: (direction, entity) {
        push(context, direction);
      },
    );
  }

  _patientProfileMenuPage(BuildContext context, entity) {
    return PatientProfileMenuPage(
      patientEntity: (entity as PatientEntity),
      onPush: (direction, entity) {
        push(context, direction);
      },
    );
  }

  _virtualVisitPage(BuildContext context, DoctorEntity param1, int param2,
      VisitSource param3) {
    return VirtualVisitPage(
      doctorEntity: (param1 as DoctorEntity),
      onPush: (direction, entity) {
        push(context, direction);
      },
      screeningId: param2,
      type: param3,
    );
  }

  _physicalVisitPage(BuildContext context, DoctorEntity param1, int param2,
      VisitSource param3) {
    return PhysicalVisitPage(
      doctorEntity: (param1 as DoctorEntity),
      onPush: (direction, entity) {
        push(context, direction);
      },
      screeningId: param2,
      type: param3,
    );
  }

  _textPlanPage(BuildContext context, entity) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<TextPlanBloc>.value(
          value: _textPlanBloc,
        ),
      ],
      child: TextPlanPage(
        doctorEntity: (entity as DoctorEntity),
        onPush: (direction, entity) {
          push(context, direction);
        },
      ),
    );
  }
}

class InStructure extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return InStructureState();
  }
}

class InStructureState extends State<InStructure> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AutoText(
              "منتظر ما باشید",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            AutoText("این امکان در نسخه‌های بعدی اضافه خواهد شد",
                textAlign: TextAlign.right, style: TextStyle(fontSize: 12)),
            SizedBox(
              height: 20,
            ),
            Image.asset(
              "assets/loading.gif",
              width: 70,
              height: 70,
            ),
          ],
        ),
      ),
    );
  }
}
