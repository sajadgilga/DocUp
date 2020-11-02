import 'dart:convert';

import 'package:docup/blocs/ChatMessageBloc.dart';
import 'package:docup/blocs/EntityBloc.dart';
import 'package:docup/blocs/MedicalTestListBloc.dart';
import 'package:docup/blocs/PanelBloc.dart';
import 'package:docup/blocs/PanelSectionBloc.dart';
import 'package:docup/blocs/PatientTrackerBloc.dart';
import 'package:docup/blocs/PictureBloc.dart';
import 'package:docup/blocs/SearchBloc.dart';
import 'package:docup/blocs/TabSwitchBloc.dart';
import 'package:docup/blocs/VisitBloc.dart';
import 'package:docup/blocs/visit_time/visit_time_bloc.dart';
import 'package:docup/constants/strings.dart';
import 'package:docup/models/DoctorEntity.dart';
import 'package:docup/models/PatientEntity.dart';
import 'package:docup/ui/account/DoctorProfileMenuPage.dart';
import 'package:docup/ui/account/DoctorProfilePage.dart';
import 'package:docup/ui/account/PatientProfileMenuPage.dart';
import 'package:docup/ui/account/PatientProfilePage.dart';
import 'package:docup/ui/account/VisitConfPage.dart';
import 'package:docup/ui/doctorDetail/DoctorDetailPage.dart';
import 'package:docup/ui/home/notification/NotificationPage.dart';
import 'package:docup/ui/medicalTest/MedicalTestPage.dart';
import 'package:docup/ui/noronioClinic/NoronioService.dart';
import 'package:docup/ui/panel/MyPartners/MyPartnerDialog.dart';
import 'package:docup/ui/panel/MyPartners/MyPartners.dart';
import 'package:docup/ui/panel/Panel.dart';
import 'package:docup/ui/panel/healthDocument/infoPage/InfoPage.dart';
import 'package:docup/ui/panel/healthFile/calander/DateCalander.dart';
import 'package:docup/ui/panel/healthFile/calander/TimeCalander.dart';
import 'package:docup/ui/panel/healthFile/eventPage/EventPage.dart';
import 'package:docup/ui/panel/healthFile/medicinePage/MedicinePage.dart';
import 'package:docup/ui/panel/panelMenu/PanelMenu.dart';
import 'package:docup/ui/panel/partnerContact/chatPage/ChatPage.dart';
import 'package:docup/ui/panel/partnerContact/illnessPage/IllnessPage.dart';
import 'package:docup/ui/panel/partnerContact/videoCallPage/VideoCallPage.dart';
import 'package:docup/ui/panel/searchPage/SearchPage.dart';
import 'package:docup/ui/patientDetail/PatientRequestPage.dart';
import 'package:docup/ui/visit/PhysicalVisitPage.dart';
import 'package:docup/ui/visit/VirtualVisitPage.dart';
import 'package:docup/ui/visitsList/PhysicalVisitListPage.dart';
import 'package:docup/ui/visitsList/VirtualVisitListPage.dart';
import 'package:docup/ui/visitsList/VisitRequestsListPage.dart';
import 'package:docup/ui/widgets/AutoText.dart';
import 'package:docup/ui/widgets/UploadSlider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../home/Home.dart';
import 'MainPage.dart';

class NavigatorRoutes {
  static const String mainPage = '/mainPage';
  static const String doctorDialogue = '/doctorDialogue';
  static const String patientDialogue = '/patientDialogue';
  static const String root = '/';
  static const String notificationView = '/notification';
  static const String panelMenu = '/panelMenu';
  static const String panel = '/panel';
  static const String myPartnerDialog = '/myPartnerDialog';

  static const String account = '/account';
  static const String partnerSearchView = '/searchView';
  static const String visitRequestList = '/visitRequestList';
  static const String physicalVisitList = '/physicalVisitList';
  static const String virtualVisitList = '/virtualVisitList';

  static const String virtualVisitPage = '/virtualVisitPage';
  static const String physicalVisitPage = '/physicalVisitPage';
  static const String uploadFileDialogue = '/uploadFileDialogue';
  static const String uploadUserProfileDialogue = '/uploadUserProfileDialogue';
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
  final PictureBloc _pictureBloc = PictureBloc();
  final PatientTrackerBloc _trackerBloc = PatientTrackerBloc();
  final VisitTimeBloc _visitTimeBloc = VisitTimeBloc();
  MedicalTestListBloc _medicalTestListBloc = MedicalTestListBloc();

  @override
  dispose() {
    _tabSwitchBloc.close();
    _panelSectionBloc.close();
    _chatMessageBloc.close();
    _searchBloc.close();
    _visitBloc.close();
    _pictureBloc.close();
    _trackerBloc.close();
    _visitTimeBloc.close();
    super.dispose();
  }

  Map<String, WidgetBuilder> _routeBuilders(BuildContext context,
      {detail, widgetArg}) {
    switch (widget.index) {
      case -1:
        return {
          NavigatorRoutes.root: (context) => MainPage(
                pushOnBase: (direction, entity) {
                  push(context, direction, detail: entity);
                },
              ),
          NavigatorRoutes.doctorDialogue: (context) =>
              _doctorDetailPage(context, detail),
          NavigatorRoutes.patientDialogue: (context) =>
              _patientDetailPage(context, detail),
          NavigatorRoutes.partnerSearchView: (context) =>
              _partnerSearchPage(context, detail: detail),
          NavigatorRoutes.cognitiveTest: (context) =>
              _cognitiveTest(context, detail),
          NavigatorRoutes.uploadFileDialogue: (context) => BlocProvider.value(
              value: _pictureBloc,
              child: UploadFileSlider(listId: detail, body: widgetArg)),
          NavigatorRoutes.visitRequestList: (context) =>
              _visitRequestPage(context),
          NavigatorRoutes.account: (context) =>
              _account(context, defaultCreditForCharge: detail),
          NavigatorRoutes.virtualVisitPage: (context) =>
              _virtualVisitPage(context, detail),
          NavigatorRoutes.visitConfig: (context) => _visitConf(context, detail),
          NavigatorRoutes.doctorProfileMenuPage: (context) =>
              _doctorProfileMenuPage(context, detail),
          NavigatorRoutes.patientProfileMenuPage: (context) =>
              _patientProfileMenuPage(context, detail),
          NavigatorRoutes.physicalVisitPage: (context) =>
              _physicalVisitPage(context, detail)
        };
      case 0:
        return {
          NavigatorRoutes.root: (context) => _home(context),
          NavigatorRoutes.notificationView: (context) => _notificationPage(),
          NavigatorRoutes.account: (context) =>
              _account(context, defaultCreditForCharge: detail),
          NavigatorRoutes.doctorDialogue: (context) =>
              _doctorDetailPage(context, detail),
          NavigatorRoutes.patientDialogue: (context) =>
              _patientDetailPage(context, detail),
          NavigatorRoutes.partnerSearchView: (context) =>
              _partnerSearchPage(context, detail: detail),
          NavigatorRoutes.visitRequestList: (context) =>
              _visitRequestPage(context),
          NavigatorRoutes.physicalVisitList: (context) =>
              _physicalVisitListPage(context),
          NavigatorRoutes.virtualVisitList: (context) =>
              _virtualVisitListPage(context),
          NavigatorRoutes.account: (context) =>
              _account(context, defaultCreditForCharge: detail),
          NavigatorRoutes.virtualVisitPage: (context) =>
              _virtualVisitPage(context, detail),
          NavigatorRoutes.visitConfig: (context) => _visitConf(context, detail),
          NavigatorRoutes.doctorProfileMenuPage: (context) =>
              _doctorProfileMenuPage(context, detail),
          NavigatorRoutes.physicalVisitPage: (context) =>
              _physicalVisitPage(context, detail),
          NavigatorRoutes.myPartnerDialog: (context) =>
              _myPartnerDialog(context, detail),
          NavigatorRoutes.panel: (context) => _panel(context, detail: detail),
        };
//      case 1:
//        return {
//          NavigatorRoutes.root: (context) => _empty(context),
////          NavigatorRoutes.panelMenu: (context) => _panelMenu(context),
//          NavigatorRoutes.doctorDialogue: (context) =>
//              _doctorDetailPage(context, detail),
//          NavigatorRoutes.patientDialogue: (context) =>
//              _patientDetailPage(context, detail),
//          NavigatorRoutes.searchView: (context) => _searchPage(context),
//        };
      case 1:
        return {
          NavigatorRoutes.root: (context) => _myDoctorsList(context),
          NavigatorRoutes.myPartnerDialog: (context) =>
              _myPartnerDialog(context, detail),
          NavigatorRoutes.panelMenu: (context) => _panelMenu(context),
          NavigatorRoutes.panel: (context) => _panel(context, detail: detail),
          NavigatorRoutes.doctorDialogue: (context) =>
              _doctorDetailPage(context, detail),
          NavigatorRoutes.patientDialogue: (context) =>
              _patientDetailPage(context, detail),
          NavigatorRoutes.cognitiveTest: (context) =>
              _cognitiveTest(context, detail),
          NavigatorRoutes.uploadFileDialogue: (context) => BlocProvider.value(
              value: _pictureBloc,
              child: UploadFileSlider(
                listId: detail,
                body: widgetArg,
              )),
          NavigatorRoutes.partnerSearchView: (context) =>
              _partnerSearchPage(context, detail: detail),
          NavigatorRoutes.visitRequestList: (context) =>
              _visitRequestPage(context),
          NavigatorRoutes.account: (context) =>
              _account(context, defaultCreditForCharge: detail),
          NavigatorRoutes.virtualVisitPage: (context) =>
              _virtualVisitPage(context, detail),
          NavigatorRoutes.visitConfig: (context) => _visitConf(context, detail),
          NavigatorRoutes.doctorProfileMenuPage: (context) =>
              _doctorProfileMenuPage(context, detail),
          NavigatorRoutes.physicalVisitPage: (context) =>
              _physicalVisitPage(context, detail)
        };
      case 2:
        return {
          NavigatorRoutes.root: (context) => _noronioClinic(context),
          NavigatorRoutes.panelMenu: (context) => _panelMenu(context),
          NavigatorRoutes.partnerSearchView: (context) =>
              _partnerSearchPage(context, detail: detail),
          NavigatorRoutes.physicalVisitPage: (context) =>
              _physicalVisitPage(context, detail),
          NavigatorRoutes.virtualVisitPage: (context) =>
              _virtualVisitPage(context, detail),
          NavigatorRoutes.doctorDialogue: (context) =>
              _doctorDetailPage(context, detail),
        };
      case 3:
        return {
          NavigatorRoutes.root: (context) => _account(context),
          NavigatorRoutes.panelMenu: (context) => _panelMenu(context),
          NavigatorRoutes.visitConfig: (context) => _visitConf(context, detail),
          NavigatorRoutes.uploadFileDialogue: (context) => BlocProvider.value(
              value: _pictureBloc,
              child: UploadFileSlider(
                listId: detail,
                body: widgetArg,
              )),
          NavigatorRoutes.uploadUserProfileDialogue: (context) =>
              BlocProvider.value(
                  value: _pictureBloc, child: UploadUserProfileSlider()),
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
              _doctorDetailPage(context, detail),
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

  void push(contet, String direction, {detail, widgetArg}) {
    if (detail == 'chat')
      widget.navigatorKey.currentState.popUntil((route) => route.isFirst);
    _route(RouteSettings(name: direction), context,
        detail: detail, widgetArg: widgetArg);
    widget.navigatorKey.currentState.push(_route(
        RouteSettings(name: direction), context,
        detail: detail, widgetArg: widgetArg));
  }

  void _pop(BuildContext context) {
    Navigator.pop(context);
  }

  Route<dynamic> _route(RouteSettings settings, BuildContext context,
      {detail, widgetArg}) {
    var routeBuilders =
        _routeBuilders(context, detail: detail, widgetArg: widgetArg);
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
        globalOnPush: widget.pushOnBase,
      ),
    );
  }

  Widget _cognitiveTest(context, detail) => BlocProvider.value(
        value: _searchBloc,
        child: MedicalTestPage(
          emptyMedicalTest: detail,
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

  Widget _panelPages(context, partner) {
    return BlocBuilder<EntityBloc, EntityState>(
        builder: (context, entityState) {
      return BlocBuilder<PanelSectionBloc, PanelSectionSelected>(
        builder: (context, state) {
          var entity = entityState.entity;
          entity.partnerEntity = partner;
          entity.iPanelId = entity.panelByPartnerId.id;
          _visitTimeBloc.add(VisitTimeGet(partnerId: entity.pId));
          if (state.patientSection == PatientPanelSection.DOCTOR_INTERFACE) {
            return Panel(
              onPush: (direction, entity) {
                push(context, direction, detail: entity);
              },
              pages: [
                [
                  IllnessPage(
                    entity: entity,
                    globalOnPush: widget.pushOnBase,
                    selectPage: widget.selectPage,
                    onPush: (direction, entity) {
                      push(context, direction, detail: entity);
                    },
                  )
                ],
                [
                  ChatPage(
                    entity: entity,
                    onPush: (direction, entity) {
                      push(context, direction, detail: entity);
                    },
                  )
                ],
                [
                  VideoCallPage(
                    entity: entity,
                    onPush: (direction, entity) {
                      push(context, direction, detail: entity);
                    },
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
                        uploadAvailable: entity.isPatient,
                        entity: entity,
                        onPush: (direction, entity, widgetArg) {
                          push(context, direction,
                              detail: entity, widgetArg: widgetArg);
                        },
                        pageName: Strings.documents,
                        picListLabel: Strings.panelDocumentsPicLabel,
                        lastPicsLabel: Strings.panelDocumentsPicListLabel,
                        uploadLabel: Strings.panelDocumentsPicUploadLabel,
                      )
                    ],
                    [
                      InfoPage(
                        uploadAvailable: entity.isDoctor,
                        entity: entity,
                        onPush: (direction, entity, widgetArg) {
                          push(context, direction,
                              detail: entity, widgetArg: widgetArg);
                        },
                        pageName: Strings.prescriptions,
                        picListLabel: Strings.panelPrescriptionsPicLabel,
                        lastPicsLabel: Strings.panelPrescriptionsPicListLabel,
                        uploadLabel: Strings.panelPrescriptionsUploadLabel,
                      )
                    ],
                    [
                      InfoPage(
                        uploadAvailable: entity.isPatient,
                        entity: entity,
                        onPush: (direction, entity, widgetArg) {
                          push(context, direction,
                              detail: entity, widgetArg: widgetArg);
                        },
                        pageName: Strings.testResults,
                        picListLabel: Strings.panelTestResultsPicLabel,
                        lastPicsLabel: Strings.panelTestResultsPicListLabel,
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
                        entity: entity,
                        onPush: (direction, entity) {
                          push(context, direction, detail: entity);
                        },
                      ),
                      TimeCalender(
                        entity: entity,
                        onPush: (direction, entity) {
                          push(context, direction, detail: entity);
                        },
                      )
                    ],
                    [
                      EventPage(
                        entity: entity,
                        onPush: (direction, entity) {
                          push(context, direction, detail: entity);
                        },
                      )
                    ],
                    [
                      MedicinePage(
                        entity: entity,
                        onPush: (direction, entity) {
                          push(context, direction, detail: entity);
                        },
                      )
                    ],
                  ],
                ));
          }
          return Panel(); //TODO
        },
      );
    });
  }

  Widget _panel(context, {incomplete, detail}) {
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
          if (state is PanelsLoaded || state is PanelLoading) {
            // if (state.panels.length > 0)
            return _panelPages(context, detail);
          }
          return PanelMenu(
            () {
              _pop(context);
            },
            onPush: (direction) {
              push(context, direction);
            },
          );
        }));
  }

  Widget _doctorDetailPage(context, doctor) {
    return DoctorDetailPage(
      onPush: (direction, entity) {
        push(context, direction, detail: entity);
      },
      doctorEntity: doctor,
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
//            BlocProvider<VisitBloc>.value(value: _visitBloc),
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

  Widget _myDoctorsList(context) {
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
          push(context, direction, detail: entity);
        },
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
      ],
      child: MyPartnerDialog(
        isRequestPage: false,
        partner: detail,
        onPush: (direction, entity) {
          push(context, direction, detail: entity);
        },
      ),
    );
  }

  Widget _empty(context) {
    return InStructure();
  }

  _virtualVisitPage(BuildContext context, entity) {
    return VirtualVisitPage(
      doctorEntity: (entity as DoctorEntity),
      onPush: (direction, entity) {
        push(context, direction);
      },
    );
  }

  _visitConf(BuildContext context, entity) {
    return VisitConfPage(
      doctorEntity: (entity as DoctorEntity),
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

  _physicalVisitPage(BuildContext context, entity) {
    return PhysicalVisitPage(
      doctorEntity: (entity as DoctorEntity),
      onPush: (direction, entity) {
        push(context, direction);
      },
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
