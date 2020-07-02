import 'dart:convert';

import 'package:docup/blocs/ChatMessageBloc.dart';
import 'package:docup/blocs/EntityBloc.dart';
import 'package:docup/blocs/NotificationBloc.dart';
import 'package:docup/blocs/PanelBloc.dart';
import 'package:docup/blocs/PanelSectionBloc.dart';
import 'package:docup/blocs/PatientTrackerBloc.dart';
import 'package:docup/blocs/PictureBloc.dart';
import 'package:docup/blocs/SearchBloc.dart';
import 'package:docup/blocs/TabSwitchBloc.dart';
import 'package:docup/blocs/visit_time/visit_time_bloc.dart';
import 'package:docup/blocs/VisitBloc.dart';
import 'package:docup/constants/strings.dart';
import 'package:docup/models/DoctorEntity.dart';
import 'package:docup/models/PatientEntity.dart';
import 'package:docup/models/UserEntity.dart';
import 'package:docup/models/VisitTime.dart';
import 'package:docup/ui/account/DoctorProfilePage.dart';
import 'package:docup/ui/account/PatientProfilePage.dart';
import 'package:docup/ui/account/ProfileMenuPage.dart';
import 'package:docup/ui/account/VisitConfPage.dart';
import 'package:docup/ui/cognitiveTest/MedicalTestPage.dart';
import 'package:docup/ui/doctorDetail/DoctorDetailPage.dart';
import 'package:docup/ui/panel/healthDocument/infoPage/InfoPage.dart';
import 'package:docup/ui/panel/healthFile/eventPage/EventPage.dart';
import 'package:docup/ui/panel/healthFile/medicinePage/MedicinePage.dart';
import 'package:docup/ui/panel/partnerContact/chatPage/ChatPage.dart';
import 'package:docup/ui/panel/partnerContact/illnessPage/IllnessPage.dart';
import 'package:docup/ui/panel/partnerContact/videoCallPage/VideoCallPage.dart';
import 'package:docup/ui/visit/PhysicalVisitPage.dart';
import 'package:docup/ui/visit/VirtualVisitPage.dart';
import 'package:docup/ui/home/notification/NotificationPage.dart';
import 'package:docup/ui/mainPage/MainPage.dart';
import 'package:docup/ui/panel/Panel.dart';
import 'package:docup/ui/panel/panelMenu/PanelMenu.dart';
import 'package:docup/ui/panel/searchPage/SearchPage.dart';
import 'package:docup/ui/patientDetail/PatientRequestPage.dart';
import 'package:docup/ui/visitRequests/VisitRequestsPage.dart';
import 'package:docup/ui/widgets/UploadSlider.dart';
import 'package:docup/utils/Utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../home/Home.dart';

class NavigatorRoutes {
  static const String mainPage = '/mainPage';
  static const String doctorDialogue = '/doctorDialogue';
  static const String patientDialogue = '/patientDialogue';
  static const String root = '/';
  static const String notificationView = '/notification';
  static const String panelMenu = '/panelMenu';
  static const String panel = '/panel';

  static const String account = '/account';
  static const String searchView = '/searchView';
  static const String requestsView = '/requestsView';
  static const String virtualVisitPage = '/virtualVisitPage';
  static const String physicalVisitPage = '/physicalVisitPage';
  static const String uploadPicDialogue = '/uploadPicDialogue';
  static const String cognitiveTest = '/cognitiveTest';

  static const String visitConfig = '/visitConfig';
  static const String profileMenuPage = '/profileMenuPage';
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
  final NotificationBloc _notificationBloc = NotificationBloc();
  final VisitTimeBloc _visitTimeBloc = VisitTimeBloc();

  @override
  dispose() {
    _tabSwitchBloc.close();
    _panelSectionBloc.close();
    _chatMessageBloc.close();
    _searchBloc.close();
    _visitBloc.close();
    _pictureBloc.close();
    _trackerBloc.close();
    _notificationBloc.close();
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
          NavigatorRoutes.searchView: (context) => _searchPage(context),
          NavigatorRoutes.cognitiveTest: (context) =>
              _cognitiveTest(context, detail),
          NavigatorRoutes.uploadPicDialogue: (context) => BlocProvider.value(
              value: _pictureBloc,
              child: UploadSlider(listId: detail, body: widgetArg)),
          NavigatorRoutes.requestsView: (context) =>
              _visitRequestPage(context),
          NavigatorRoutes.account: (context) =>
              _account(context, defaultCreditForCharge: detail),
          NavigatorRoutes.virtualVisitPage: (context) =>
              _virtualVisitPage(context, detail),
          NavigatorRoutes.visitConfig: (context) => _visitConf(context, detail),
          NavigatorRoutes.profileMenuPage: (context) =>
              _profileMenuPage(context, detail),
          NavigatorRoutes.physicalVisitPage: (context) =>
              _physicalVisitPage(context, detail)
        };
      case 0:
        return {
          NavigatorRoutes.root: (context) => _home(context),
          NavigatorRoutes.notificationView: (context) => _notifictionPage(),
          NavigatorRoutes.account: (context) =>
              _account(context, defaultCreditForCharge: detail),
          NavigatorRoutes.doctorDialogue: (context) =>
              _doctorDetailPage(context, detail),
          NavigatorRoutes.patientDialogue: (context) =>
              _patientDetailPage(context, detail),
          NavigatorRoutes.searchView: (context) => _searchPage(context),
          NavigatorRoutes.requestsView: (context) =>
              _visitRequestPage(context),
          NavigatorRoutes.account: (context) =>
              _account(context, defaultCreditForCharge: detail),
          NavigatorRoutes.virtualVisitPage: (context) =>
              _virtualVisitPage(context, detail),
          NavigatorRoutes.visitConfig: (context) => _visitConf(context, detail),
          NavigatorRoutes.profileMenuPage: (context) =>
              _profileMenuPage(context, detail),
          NavigatorRoutes.physicalVisitPage: (context) =>
              _physicalVisitPage(context, detail)
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
          NavigatorRoutes.root: (context) => _panelMenu(context),
          NavigatorRoutes.panelMenu: (context) => _panelMenu(context),
          NavigatorRoutes.panel: (context) => _panel(context, detail: detail),
          NavigatorRoutes.doctorDialogue: (context) =>
              _doctorDetailPage(context, detail),
          NavigatorRoutes.patientDialogue: (context) =>
              _patientDetailPage(context, detail),
          NavigatorRoutes.cognitiveTest: (context) =>
              _cognitiveTest(context, detail),
          NavigatorRoutes.uploadPicDialogue: (context) => BlocProvider.value(
              value: _pictureBloc,
              child: UploadSlider(
                listId: detail,
                body: widgetArg,
              )),
          NavigatorRoutes.searchView: (context) => _searchPage(context),
          NavigatorRoutes.requestsView: (context) =>
              _visitRequestPage(context),
          NavigatorRoutes.account: (context) =>
              _account(context, defaultCreditForCharge: detail),
          NavigatorRoutes.virtualVisitPage: (context) =>
              _virtualVisitPage(context, detail),
          NavigatorRoutes.visitConfig: (context) => _visitConf(context, detail),
          NavigatorRoutes.profileMenuPage: (context) =>
              _profileMenuPage(context, detail),
          NavigatorRoutes.physicalVisitPage: (context) =>
              _physicalVisitPage(context, detail)
        };
      case 2:
        return {
          NavigatorRoutes.root: (context) => _empty(context),
          NavigatorRoutes.panelMenu: (context) => _panelMenu(context),
        };
      case 3:
        return {
          NavigatorRoutes.root: (context) => _account(context),
          NavigatorRoutes.panelMenu: (context) => _panelMenu(context),
          NavigatorRoutes.visitConfig: (context) => _visitConf(context, detail),
          NavigatorRoutes.profileMenuPage: (context) =>
              _profileMenuPage(context, detail),
        };
      default:
        return {
          NavigatorRoutes.root: (context) => _home(context),
          NavigatorRoutes.notificationView: (context) => _notifictionPage(),
          NavigatorRoutes.doctorDialogue: (context) =>
              _doctorDetailPage(context, detail),
          NavigatorRoutes.patientDialogue: (context) =>
              _patientDetailPage(context, detail),
          NavigatorRoutes.searchView: (context) => _searchPage(context),
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
    _notificationBloc.add(GetNewestNotifications());
    if (entity.isDoctor) {
      return MultiBlocProvider(
          providers: [
            BlocProvider<PatientTrackerBloc>.value(
              value: _trackerBloc,
            ),
            BlocProvider<NotificationBloc>.value(
              value: _notificationBloc,
            )
          ],
          child: Home(
            selectPage: widget.selectPage,
            onPush: (direction, entity) {
              push(context, direction, detail: entity);
            },
            globalOnPush: widget.pushOnBase,
          ));
    } else if (entity.isPatient) {
      return MultiBlocProvider(
          providers: [
            BlocProvider<NotificationBloc>.value(
              value: _notificationBloc,
            )
          ],
          child: Home(
            selectPage: widget.selectPage,
            onPush: (direction, entity) {
              push(context, direction, detail: entity);
            },
            globalOnPush: widget.pushOnBase,
          ));
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
        onPush: (direction) {
          push(context, direction);
        },
      );
    }
  }

  Widget _cognitiveTest(context, UserEntity entity) => MedicalTestPage(
        onPush: (direction, entity) {
          push(context, direction, detail: entity);
        },
      );

  Widget _notifictionPage() => NotificationPage();

  Widget _panelPages(context) {
//    var entity = BlocProvider.of<EntityBloc>(context).state.entity;
    return BlocBuilder<EntityBloc, EntityState>(
        builder: (context, entityState) {
      return BlocBuilder<PanelSectionBloc, PanelSectionSelected>(
        builder: (context, state) {
          var entity = entityState.entity;
          if (state.patientSection == PatientPanelSection.DOCTOR_INTERFACE) {
            return Panel(
              onPush: (direction, entity) {
                push(context, direction, detail: entity);
              },
              pages: [
                [
                  IllnessPage(
                    entity: entity,
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
                      EventPage(
                        entity: entity,
                        onPush: (direction, entity) {
                          push(context, direction, detail: entity);
                        },
                      ),
                      MedicinePage(
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
    var entity = BlocProvider.of<EntityBloc>(context).state.entity;
    _visitTimeBloc.add(VisitTimeGet(partnerId: entity.pId));
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
        ],
        child: BlocBuilder<PanelBloc, PanelState>(builder: (context, state) {
          if (state is PanelsLoaded || state is PanelLoading) {
            if (state.panels.length > 0) return _panelPages(context);
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

  Widget _searchPage(context, {isRequests = false}) => MultiBlocProvider(
          providers: [
            BlocProvider<SearchBloc>.value(value: _searchBloc),
//            BlocProvider<VisitBloc>.value(value: _visitBloc),
          ],
          child: SearchPage(
            isRequestPage: isRequests,
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
          ));

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
        ));
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

  _profileMenuPage(BuildContext context, entity) {
    return ProfileMenuPage(
      doctorEntity: (entity as DoctorEntity),
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
            Text(
              "منتظر ما باشید",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text("این امکان در نسخه‌های بعدی اضافه خواهد شد",
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
