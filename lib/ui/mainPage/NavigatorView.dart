import 'package:docup/blocs/EntityBloc.dart';
import 'package:docup/blocs/PanelBloc.dart';
import 'package:docup/blocs/PanelSectionBloc.dart';
import 'package:docup/blocs/TabSwitchBloc.dart';
import 'package:docup/constants/strings.dart';
import 'package:docup/models/Doctor.dart';
import 'package:docup/models/PatientEntity.dart';
import 'package:docup/ui/doctorDetail/DoctorDetailPage.dart';
import 'package:docup/ui/home/notification/NotificationPage.dart';
import 'package:docup/ui/panel/Panel.dart';
import 'package:docup/ui/panel/PanelMenu.dart';
import 'package:docup/ui/panel/chatPage/ChatPage.dart';
import 'package:docup/ui/panel/healthFile/InfoPage.dart';
import 'package:docup/ui/panel/illnessPage/IllnessPage.dart';
import 'package:docup/ui/panel/searchPage/SearchPage.dart';
import 'package:docup/ui/panel/videoCallPage/VideoCallPage.dart';
import 'package:docup/ui/widgets/UploadSlider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../home/Home.dart';

class NavigatorRoutes {
  static const String mainPage = '/mainPage';
  static const String doctorDialogue = '/doctorDialogue';
  static const String root = '/';
  static const String notificationView = '/notification';
  static const String panelMenu = '/panelMenu';
  static const String searchView = '/searchView';
  static const String uploadPicDialogue = '/uploadPicDialogue';
}

class NavigatorView extends StatelessWidget {
  final int index;
  final GlobalKey<NavigatorState> navigatorKey;
  ValueChanged<String> globalOnPush;
  final TabSwitchBloc _tabSwitchBloc = TabSwitchBloc();
  final PanelSectionBloc _panelSectionBloc = PanelSectionBloc();
  final Doctor _doctor = Doctor(
      3,
      "دکتر زهرا شادلو",
      "متخصص پوست",
      "اقدسیه",
      Image(
        image: AssetImage('assets/lion.jpg'),
      ),
      []);

//  Patient patient;

  NavigatorView({Key key, this.index, this.navigatorKey, this.globalOnPush})
      : super(key: key);

  Map<String, WidgetBuilder> _routeBuilders(BuildContext context) {
    switch (index) {
//      case -1: return {
//        NavigatorRoutes.mainPage: (context) => _mainPage(),
//        NavigatorRoutes.doctorDialogue: (context) => DoctorDetailPage()
//      };
      case 0:
        return {
          NavigatorRoutes.root: (context) => _home(context),
          NavigatorRoutes.notificationView: (context) => _notifictionPage(),
//          NavigatorRoutes.doctorDialogue: (context) =>
//              _doctorDetailPage(context),
          NavigatorRoutes.searchView: (context) => _searchPage(context),
        };
      case 1:
        return {
          NavigatorRoutes.root: (context) => _panel(context),
          NavigatorRoutes.panelMenu: (context) => _panelMenu(context),
//          NavigatorRoutes.doctorDialogue: (context) =>
//              _doctorDetailPage(context),
          NavigatorRoutes.uploadPicDialogue: (context) => UploadSlider(),
          NavigatorRoutes.searchView: (context) => _searchPage(context),
        };
      case 2:
        return {
          NavigatorRoutes.root: (context) => _empty(context),
//          NavigatorRoutes.panelMenu: (context) => _panelMenu(context),
////          NavigatorRoutes.doctorDialogue: (context) =>
////              _doctorDetailPage(context),
//          NavigatorRoutes.searchView: (context) => _searchPage(context),
        };
      case 3:
        return {
          NavigatorRoutes.root: (context) => _empty(context),
          NavigatorRoutes.panelMenu: (context) => _panelMenu(context),

        };
      case 4:
        return {
          NavigatorRoutes.root: (context) => _empty(context),
          NavigatorRoutes.panelMenu: (context) => _panelMenu(context),

        };
      default:
        return {
          NavigatorRoutes.root: (context) => _home(context),
          NavigatorRoutes.notificationView: (context) => _notifictionPage(),
          NavigatorRoutes.doctorDialogue: (context) =>
              _doctorDetailPage(context),
          NavigatorRoutes.searchView: (context) => _searchPage(context),
        };
    }
  }

  void _push(BuildContext context, String direction) {
    _route(RouteSettings(name: direction), context);
    Navigator.push(context, _route(RouteSettings(name: direction), context));
  }

  void _pop(BuildContext context) {
    Navigator.pop(context);
  }

  Route<dynamic> _route(RouteSettings settings, BuildContext context) {
    var routeBuilders = _routeBuilders(context);
    return MaterialPageRoute(
        settings: settings,
        builder: (BuildContext context) {
          return routeBuilders[settings.name](context);
        });
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      initialRoute: NavigatorRoutes.root,
      observers: <NavigatorObserver>[HeroController()],
      onGenerateRoute: (settings) => _route(settings, context),
    );
  }

  Widget _home(context) => Home(
        onPush: (direction) {
          _push(context, direction);
        },
        globalOnPush: (direction) {
          _push(context, direction);
        },
      );

  Widget _notifictionPage() => NotificationPage();

  Widget _panelPages(context) {
    var entity = BlocProvider.of<EntityBloc>(context).state.entity;
    return BlocBuilder<PanelSectionBloc, PanelSectionSelected>(
      builder: (context, state) {
        if (state.section == PanelSection.DOCTOR_INTERFACE) {
          return Panel(
            doctor: _doctor,
            onPush: (direction) {
              _push(context, direction);
            },
            pages: <Widget>[
              IllnessPage(
                doctor: entity.partnerEntity,
                onPush: (direction) {
                  _push(context, direction);
                },
              ),
              ChatPage(
                doctor: entity.partnerEntity,
                onPush: (direction) {
                  _push(context, direction);
                },
              ),
              VideoCallPage(
                doctor: entity.partnerEntity,
                onPush: (direction) {
                  _push(context, direction);
                },
              )
            ],
          );
        } else if (state.section == PanelSection.HEALTH_FILE) {
          return Panel(
            doctor: _doctor,
            onPush: (direction) {
              _push(context, direction);
            },
            pages: <Widget>[
              InfoPage(
                doctor: entity.partnerEntity,
                onPush: (direction) {
                  _push(context, direction);
                },
                picListLabel: Strings.panelDocumentsPicLabel,
                lastPicsLabel: Strings.panelDocumentsPicListLabel,
              ),
              InfoPage(
                doctor: entity.partnerEntity,
                onPush: (direction) {
                  _push(context, direction);
                },
                picListLabel: Strings.panelPrescriptionsPicLabel,
                lastPicsLabel: Strings.panelPrescriptionsPicListLabel,
              ),
              InfoPage(
                doctor: entity.partnerEntity,
                onPush: (direction) {
                  _push(context, direction);
                },
                picListLabel: Strings.panelTestResultsPicLabel,
                lastPicsLabel: Strings.panelTestResultsPicListLabel,
              ),
            ],
          );
        }
        return Panel(); //TODO
      },
    );
  }

  Widget _panel(context, {incomplete}) {
    return MultiBlocProvider(
        providers: [
          BlocProvider<TabSwitchBloc>.value(
            value: _tabSwitchBloc,
          ),
          BlocProvider<PanelSectionBloc>.value(
            value: _panelSectionBloc,
          )
        ],
        child: BlocBuilder<PanelBloc, PanelState>(builder: (context, state) {
          if (state is PanelsLoaded) {
            if (state.panels.length > 0) return _panelPages(context);
          }
          return PanelMenu(() {
            _pop(context);
          });
        }));
  }

  Widget _doctorDetailPage(context) => DoctorDetailPage(
        doctor: _doctor,
      );

  Widget _searchPage(context) => SearchPage(
        onPush: (direction) {
          _push(context, direction);
        },
      );

  Widget _panelMenu(context) => MultiBlocProvider(
          providers: [
            BlocProvider<TabSwitchBloc>.value(
              value: _tabSwitchBloc,
            ),
            BlocProvider<PanelSectionBloc>.value(
              value: _panelSectionBloc,
            )
          ],
          child: PanelMenu(() {
            _pop(context);
          }));

  Widget _empty(context) {
    return Container();
  }
}
