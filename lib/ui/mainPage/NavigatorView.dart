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
import 'package:Neuronio/blocs/visit_time/TextPlanBloc.dart';
import 'package:Neuronio/blocs/visit_time/visit_time_bloc.dart';
import 'package:Neuronio/constants/strings.dart';
import 'package:Neuronio/models/DoctorEntity.dart';
import 'package:Neuronio/models/PatientEntity.dart';
import 'package:Neuronio/models/TextPlan.dart';
import 'package:Neuronio/models/UserEntity.dart';
import 'package:Neuronio/ui/account/DoctorProfileMenuPage.dart';
import 'package:Neuronio/ui/account/DoctorProfilePage.dart';
import 'package:Neuronio/ui/account/PatientProfileMenuPage.dart';
import 'package:Neuronio/ui/account/PatientProfilePage.dart';
import 'package:Neuronio/ui/account/VisitConfPage.dart';
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
import 'package:Neuronio/ui/panel/screening/BuyScreeningPlan.dart';
import 'package:Neuronio/ui/panel/screening/PatientScreeningPage.dart';
import 'package:Neuronio/ui/panel/screening/SelectingDoctor.dart';
import 'package:Neuronio/ui/panel/searchPage/SearchPage.dart';
import 'package:Neuronio/ui/patientVisitDetail/PatientRequestPage.dart';
import 'package:Neuronio/ui/plan/PlanPage.dart';
import 'package:Neuronio/ui/visit/PhysicalVisitPage.dart';
import 'package:Neuronio/ui/visit/VirtualVisitPage.dart';
import 'package:Neuronio/ui/visitsList/PhysicalVisitListPage.dart';
import 'package:Neuronio/ui/visitsList/VirtualVisitListPage.dart';
import 'package:Neuronio/ui/visitsList/VisitRequestsListPage.dart';
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
  static const String doctorProfileMenuPage = '/doctorProfileMenuPage';
  static const String patientProfileMenuPage = '/patientProfileMenuPage';
}

class NavigatorView extends StatefulWidget {
  final int index;
  final GlobalKey<NavigatorState> navigatorKey;
  Function(String, dynamic) pushOnBase;
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
      {detail, extraDetail, widgetArg}) {
    switch (widget.index) {
      case -1:
        return {
          NavigatorRoutes.root: (context) => MainPage(
                pushOnBase: (direction, entity) {
                  push(context, direction, detail: entity);
                },
              ),
          NavigatorRoutes.panel: (context) => Scaffold(
              body: _panel(context, detail: detail, extraDetail: extraDetail)),
          NavigatorRoutes.doctorDialogue: (context) =>
              _doctorDetailPage(context, detail, extraDetail),
          NavigatorRoutes.selectDoctorForScreening: (context) =>
              _screeningDoctorSelectionPage(context, extraDetail),
          NavigatorRoutes.patientDialogue: (context) =>
              _patientDetailPage(context, detail),
          NavigatorRoutes.partnerSearchView: (context) =>
              _partnerSearchPage(context, detail: detail),
          NavigatorRoutes.cognitiveTest: (context) =>
              _cognitiveTest(context, detail),
          NavigatorRoutes.uploadFileDialogue: (context) => BlocProvider.value(
              value: _pictureBloc,
              child: UploadFileSlider(
                  listId: detail, partnerId: extraDetail, body: widgetArg)),
          NavigatorRoutes.visitRequestList: (context) =>
              _visitRequestPage(context),
          NavigatorRoutes.account: (context) =>
              _account(context, defaultCreditForCharge: detail),
          NavigatorRoutes.virtualVisitPage: (context) =>
              _virtualVisitPage(context, detail, extraDetail),
          NavigatorRoutes.visitConfig: (context) => _visitConf(context, detail),
          NavigatorRoutes.doctorProfileMenuPage: (context) =>
              _doctorProfileMenuPage(context, detail),
          NavigatorRoutes.patientProfileMenuPage: (context) =>
              _patientProfileMenuPage(context, detail),
          NavigatorRoutes.physicalVisitPage: (context) =>
              _physicalVisitPage(context, detail, extraDetail)
        };
      case 0:
        return {
          NavigatorRoutes.root: (context) => _home(context),
          NavigatorRoutes.notificationView: (context) => _notificationPage(),
          NavigatorRoutes.account: (context) =>
              _account(context, defaultCreditForCharge: detail),
          NavigatorRoutes.doctorDialogue: (context) =>
              _doctorDetailPage(context, detail, extraDetail),
          NavigatorRoutes.selectDoctorForScreening: (context) =>
              _screeningDoctorSelectionPage(context, extraDetail),
          NavigatorRoutes.patientDialogue: (context) =>
              _patientDetailPage(context, detail),
          NavigatorRoutes.cognitiveTest: (context) =>
              _cognitiveTest(context, detail),
          NavigatorRoutes.partnerSearchView: (context) =>
              _partnerSearchPage(context, detail: detail),
          NavigatorRoutes.visitRequestList: (context) =>
              _visitRequestPage(context),
          NavigatorRoutes.uploadFileDialogue: (context) => BlocProvider.value(
              value: _pictureBloc,
              child: UploadFileSlider(
                listId: detail,
                partnerId: extraDetail,
                body: widgetArg,
              )),
          NavigatorRoutes.physicalVisitList: (context) =>
              _physicalVisitListPage(context),
          NavigatorRoutes.virtualVisitList: (context) =>
              _virtualVisitListPage(context),
          NavigatorRoutes.account: (context) =>
              _account(context, defaultCreditForCharge: detail),
          NavigatorRoutes.virtualVisitPage: (context) =>
              _virtualVisitPage(context, detail, extraDetail),
          NavigatorRoutes.visitConfig: (context) => _visitConf(context, detail),
          NavigatorRoutes.doctorProfileMenuPage: (context) =>
              _doctorProfileMenuPage(context, detail),
          NavigatorRoutes.physicalVisitPage: (context) =>
              _physicalVisitPage(context, detail, extraDetail),
          NavigatorRoutes.textPlanPage: (context) =>
              _textPlanPage(context, detail),
          NavigatorRoutes.myPartnerDialog: (context) =>
              _myPartnerDialog(context, detail),
          NavigatorRoutes.panel: (context) =>
              _panel(context, detail: detail, extraDetail: extraDetail),
        };
      case 1:
        return {
          NavigatorRoutes.root: (context) => _myPanelsMenuList(context),
          NavigatorRoutes.myPartnerDialog: (context) =>
              _myPartnerDialog(context, detail),
          NavigatorRoutes.buyScreening: (context) => _buyScreeningPage(context),
          NavigatorRoutes.panel: (context) =>
              _panel(context, detail: detail, extraDetail: extraDetail),
          NavigatorRoutes.textPlanPage: (context) =>
              _textPlanPage(context, detail),
          NavigatorRoutes.doctorDialogue: (context) =>
              _doctorDetailPage(context, detail, extraDetail),
          NavigatorRoutes.selectDoctorForScreening: (context) =>
              _screeningDoctorSelectionPage(context, extraDetail),
          NavigatorRoutes.patientDialogue: (context) =>
              _patientDetailPage(context, detail),
          NavigatorRoutes.cognitiveTest: (context) =>
              _cognitiveTest(context, detail),
          NavigatorRoutes.uploadFileDialogue: (context) => BlocProvider.value(
              value: _pictureBloc,
              child: UploadFileSlider(
                listId: detail,
                partnerId: extraDetail,
                body: widgetArg,
              )),
          NavigatorRoutes.partnerSearchView: (context) =>
              _partnerSearchPage(context, detail: detail),
          NavigatorRoutes.visitRequestList: (context) =>
              _visitRequestPage(context),
          NavigatorRoutes.account: (context) =>
              _account(context, defaultCreditForCharge: detail),
          NavigatorRoutes.virtualVisitPage: (context) =>
              _virtualVisitPage(context, detail, extraDetail),
          NavigatorRoutes.visitConfig: (context) => _visitConf(context, detail),
          NavigatorRoutes.doctorProfileMenuPage: (context) =>
              _doctorProfileMenuPage(context, detail),
          NavigatorRoutes.physicalVisitPage: (context) =>
              _physicalVisitPage(context, detail, extraDetail)
        };
      case 2:
        return {
          NavigatorRoutes.root: (context) => _noronioClinic(context),
          NavigatorRoutes.partnerSearchView: (context) =>
              _partnerSearchPage(context, detail: detail),
          NavigatorRoutes.physicalVisitPage: (context) =>
              _physicalVisitPage(context, detail, extraDetail),
          NavigatorRoutes.virtualVisitPage: (context) =>
              _virtualVisitPage(context, detail, extraDetail),
          NavigatorRoutes.doctorDialogue: (context) =>
              _doctorDetailPage(context, detail, extraDetail),
          NavigatorRoutes.selectDoctorForScreening: (context) =>
              _screeningDoctorSelectionPage(context, extraDetail),
        };
      case 3:
        return {
          NavigatorRoutes.root: (context) => _account(context),
          // NavigatorRoutes.panelMenu: (context) => _panelMenu(context),
          NavigatorRoutes.visitConfig: (context) => _visitConf(context, detail),
          NavigatorRoutes.uploadFileDialogue: (context) => BlocProvider.value(
              value: _pictureBloc,
              child: UploadFileSlider(
                listId: detail,
                partnerId: extraDetail,
                body: widgetArg,
              )),
          NavigatorRoutes.doctorProfileMenuPage: (context) =>
              _doctorProfileMenuPage(context, detail),
          NavigatorRoutes.patientProfileMenuPage: (context) =>
              _patientProfileMenuPage(context, detail),
        };
      default:
        return {
          NavigatorRoutes.root: (context) => _home(context),
          NavigatorRoutes.notificationView: (context) => _notificationPage(),
          NavigatorRoutes.doctorDialogue: (context) =>
              _doctorDetailPage(context, detail, extraDetail),
          NavigatorRoutes.selectDoctorForScreening: (context) =>
              _screeningDoctorSelectionPage(context, extraDetail),
          NavigatorRoutes.patientDialogue: (context) =>
              _patientDetailPage(context, detail),
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

  void push(contet, String direction,
      {detail, extraDetail, widgetArg, returnCallBack}) {
    if (detail == 'chat')
      widget.navigatorKey.currentState.popUntil((route) => route.isFirst);
    _route(RouteSettings(name: direction), context,
        detail: detail, extraDetail: extraDetail, widgetArg: widgetArg);
    widget.navigatorKey.currentState
        .push(_route(RouteSettings(name: direction), context,
            detail: detail, extraDetail: extraDetail, widgetArg: widgetArg))
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
        detail: detail, extraDetail: extraDetail, widgetArg: widgetArg);
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
            onPush: (direction, entity) {
              push(context, direction, detail: entity);
            },
            globalOnPush: widget.pushOnBase,
          ));
    } else if (entity.isPatient) {
      return Home(
        selectPage: widget.selectPage,
        onPush: (direction, entity) {
          push(context, direction, detail: entity);
        },
        globalOnPush: widget.pushOnBase,
      );
    }
  }

  Widget _account(context, {defaultCreditForCharge}) {
    var entity = BlocProvider.of<EntityBloc>(context).state.entity;
    if (entity.isDoctor) {
      return DoctorProfilePage(
        onPush: (direction, entity) {
          push(context, direction, detail: entity);
        },
      );
    } else {
      return PatientProfilePage(
        defaultCreditForCharge: defaultCreditForCharge,
        onPush: (direction, entity) {
          push(context, direction, detail: entity);
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
          push(context, direction, detail: entity);
        },
        selectPage: widget.selectPage,
        globalOnPush: widget.pushOnBase,
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
            push(context, direction, detail: entity);
          },
        ),
      );

  Widget _notificationPage() => NotificationPage(
        onPush: (direction, entity) {
          push(context, direction, detail: entity);
        },
      );

  Widget _panelPages(
      context, partner, TextPlanRemainedTraffic textPlanRemainedTraffic) {
    return BlocBuilder<EntityBloc, EntityState>(
        builder: (context, entityState) {
      return BlocBuilder<PanelSectionBloc, PanelSectionSelected>(
        builder: (context, state) {
          var entity = entityState.entity;
          entity.partnerEntity = partner;
          entity.iPanelId = entity.panelByPartnerId.id;
          Entity copyEntity = entity.copy();
          if (state.patientSection == PatientPanelSection.DOCTOR_INTERFACE) {
            _visitTimeBloc.add(VisitTimeGet(partnerId: entity.pId));
            return Panel(
              onPush: (direction, entity) {
                push(context, direction, detail: entity);
              },
              pages: [
                [
                  IllnessPage(
                    entity: copyEntity,
                    textPlanRemainedTraffic: textPlanRemainedTraffic,
                    globalOnPush: widget.pushOnBase,
                    selectPage: widget.selectPage,
                    onPush: (direction, entity) {
                      push(context, direction, detail: entity);
                    },
                  )
                ],
                [
                  ChatPage(
                    entity: copyEntity,
                    textPlanRemainedTraffic: textPlanRemainedTraffic,
                    onPush: (direction, entity) {
                      push(context, direction, detail: entity);
                    },
                  )
                ],
                [
                  VideoOrVoiceCallPage(
                    key: ValueKey("Video"),
                    entity: copyEntity,
                    onPush: (direction, entity) {
                      push(context, direction, detail: entity);
                    },
                    videoCall: true,
                  ),
                  VideoOrVoiceCallPage(
                    key: ValueKey("voice"),
                    entity: copyEntity,
                    onPush: (direction, entity) {
                      push(context, direction, detail: entity);
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
                    push(context, direction, detail: entity);
                  },
                  pages: [
                    [
                      InfoPage(
                        uploadAvailable: entity.isDoctor,
                        textPlanRemainedTraffic: textPlanRemainedTraffic,
                        entity: copyEntity,
                        onPush: (direction, listId, partnerId, widgetArg) {
                          push(context, direction,
                              detail: listId,
                              extraDetail: partnerId,
                              widgetArg: widgetArg);
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
                        textPlanRemainedTraffic: textPlanRemainedTraffic,
                        entity: copyEntity,
                        onPush: (direction, listId, partnerId, widgetArg) {
                          push(context, direction,
                              detail: listId,
                              extraDetail: partnerId,
                              widgetArg: widgetArg);
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
                        textPlanRemainedTraffic: textPlanRemainedTraffic,
                        entity: copyEntity,
                        onPush: (direction, listId, partnerId, widgetArg) {
                          push(context, direction,
                              detail: listId,
                              extraDetail: partnerId,
                              widgetArg: widgetArg);
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
                    push(context, direction, detail: entity);
                  },
                  pages: [
                    [
                      DateCalender(
                        entity: copyEntity,
                        onPush: (direction, entity) {
                          push(context, direction, detail: entity);
                        },
                      ),
                      TimeCalender(
                        entity: copyEntity,
                        onPush: (direction, entity) {
                          push(context, direction, detail: entity);
                        },
                      )
                    ],
                    [
                      EventPage(
                        entity: copyEntity,
                        onPush: (direction, entity) {
                          push(context, direction, detail: entity);
                        },
                      )
                    ],
                    [
                      MedicinePage(
                        entity: copyEntity,
                        onPush: (direction, entity) {
                          push(context, direction, detail: entity);
                        },
                      )
                    ],
                  ],
                ));
          }
          return Panel(
            onPush: (direction, entity) {
              push(context, direction, detail: entity);
            },
          ); //TODO
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
    return MultiBlocProvider(
        providers: [
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
          BlocProvider<MedicalTestListBloc>.value(value: _medicalTestListBloc)
        ],
        child: BlocBuilder<PanelBloc, PanelState>(builder: (context, state) {
          // if (state is PanelsLoaded || state is PanelLoading || true) {
          // if (state.panels.length > 0)
          return _panelPages(context, detail, extraDetail);
          // }
          // return PanelMenu(
          //   () {
          //     _pop(context);
          //   },
          //   onPush: (direction) {
          //     push(context, direction);
          //   },
          // );
        }));
  }

  Widget _screeningDoctorSelectionPage(context, extraDetail) {
    return BlocProvider.value(
      value: _searchBloc,
      child: ScreeningDoctorSelectionPage(
        onPush: (String, UserEntity) {
          push(context, String, extraDetail: UserEntity);
        },
        screeningId: extraDetail,
      ),
    );
  }

  Widget _doctorDetailPage(context, doctor, extraDetail) {
    return DoctorDetailPage(
      onPush: (direction, entity, Function() returnCallBack, screeningId) {
        push(context, direction,
            detail: entity,
            extraDetail: screeningId,
            returnCallBack: returnCallBack);
      },
      doctorEntity: doctor,
      screeningId: extraDetail,
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
//            BlocProvider<VisitBloc>.value(value: _visitBloc),
          ],
          child: PartnerSearchPage(
            clinicIdDoctorSearch: detail,
            selectPage: widget.selectPage,
            onPush: (direction, entity) {
              push(context, direction, detail: entity);
            },
          ));

  Widget _visitRequestPage(context) => MultiBlocProvider(
        providers: [
          BlocProvider<SearchBloc>.value(value: _searchBloc),
//            BlocProvider<VisitBloc>.value(value: _visitBloc),
        ],
        child: VisitRequestsPage(
          onPush: (direction, entity) {
            push(context, direction, detail: entity);
          },
        ),
      );

  Widget _virtualVisitListPage(context) => MultiBlocProvider(
        providers: [
          BlocProvider<SearchBloc>.value(value: _searchBloc),
        ],
        child: VirtualVisitList(
          onPush: (direction, entity) {
            push(context, direction, detail: entity);
          },
        ),
      );

  Widget _physicalVisitListPage(context) => MultiBlocProvider(
        providers: [
          BlocProvider<SearchBloc>.value(value: _searchBloc),
        ],
        child: PhysicalVisitList(
          onPush: (direction, entity) {
            push(context, direction, detail: entity);
          },
        ),
      );

  Widget _panelMenu(context) {
//    BlocProvider.of<PanelBloc>(context).add(GetMyPanels());
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
      child: PanelMenu(
        () {
          _pop(context);
        },
        onPush: (direction) {
          push(context, direction);
        },
      ),
    );
  }

  Widget _buyScreeningPage(context) {
    return BuyScreeningPage(onPush: (direction, entity) {
      push(context, direction, detail: entity);
    });
  }

  Widget _myPanelsMenuList(context) {
    var entity = BlocProvider.of<EntityBloc>(context).state.entity;
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
      child: entity.isDoctor
          ? MyPartners(
              onPush: (direction, entity) {
                push(context, direction, detail: entity);
              },
            )
          : PatientScreeningPage(
              onPush: (direction, entity, screeningId) {
                push(context, direction,
                    detail: entity, extraDetail: screeningId);
              },
              globalOnPush: widget.pushOnBase,
            ),
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
        onPush: (direction, entity, remainedTraffic, returnCallBack) {
          push(context, direction,
              detail: entity,
              extraDetail: remainedTraffic,
              returnCallBack: returnCallBack);
        },
      ),
    );
  }

  Widget _empty(context) {
    return InStructure();
  }

  _virtualVisitPage(BuildContext context, entity, extraDetail) {
    return VirtualVisitPage(
      doctorEntity: (entity as DoctorEntity),
      onPush: (direction, entity) {
        push(context, direction);
      },
      screeningId: extraDetail,
    );
  }

  _visitConf(BuildContext context, entity) {
    return VisitConfPage(
      doctorId: (entity as DoctorEntity).id,
      onPush: (direction, entity) {
        push(context, direction);
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

  _physicalVisitPage(BuildContext context, entity, extraDetail) {
    return PhysicalVisitPage(
      doctorEntity: (entity as DoctorEntity),
      onPush: (direction, entity) {
        push(context, direction);
      },
      screeningId: extraDetail,
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
