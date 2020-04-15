import 'package:docup/models/Doctor.dart';
import 'package:docup/models/Patient.dart';
import 'package:docup/ui/doctorDetail/DoctorDetailPage.dart';
import 'package:docup/ui/home/notification/NotificationPage.dart';
import 'package:docup/ui/panel/Panel.dart';
import 'package:docup/ui/panel/PanelMenu.dart';
import 'package:docup/ui/panel/chatPage/ChatPage.dart';
import 'package:docup/ui/panel/illnessPage/IllnessPage.dart';
import 'package:docup/ui/panel/searchPage/SearchPage.dart';
import 'package:docup/ui/panel/videoCallPage/VideoCallPage.dart';
import 'package:docup/ui/widgets/UploadSlider.dart';
import 'package:flutter/material.dart';

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
  final ValueChanged<String> globalOnPush;
  final Doctor _doctor = Doctor(
      3,
      "دکتر زهرا شادلو",
      "متخصص پوست",
      "اقدسیه",
      Image(
        image: AssetImage('assets/lion.jpg'),
      ),
      []);
  Patient patient;

  NavigatorView({Key key, this.index, this.navigatorKey, this.patient, this.globalOnPush})
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
          NavigatorRoutes.root: (context) => _panel(context),
          NavigatorRoutes.panelMenu: (context) => _panelMenu(context),
//          NavigatorRoutes.doctorDialogue: (context) =>
//              _doctorDetailPage(context),
          NavigatorRoutes.searchView: (context) => _searchPage(context),
        };
      case 3:
        return {};
      case 4:
        return {};
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
    Navigator.maybePop(context);
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
    globalOnPush: globalOnPush,
  );

  Widget _notifictionPage() => NotificationPage();

  Widget _panel(context) => Panel(
    doctor: _doctor,
    onPush: (direction) {
      _push(context, direction);
    },
    pages: <Widget>[
      IllnessPage(
        doctor: _doctor,
        onPush: (direction) {
          _push(context, direction);
        },
      ),
      ChatPage(
        doctor: _doctor,
        onPush: (direction) {
          _push(context, direction);
        },
      ),
      VideoCallPage(
        doctor: _doctor,
        onPush: (direction) {
          _push(context, direction);
        },
      )
    ],
  );

  Widget _doctorDetailPage(context) => DoctorDetailPage(
    doctor: _doctor,
  );

  Widget _searchPage(context) => SearchPage(
    onPush: (direction) {
      _push(context, direction);
    },
  );

  Widget _panelMenu(context) => PanelMenu(() {
    _pop(context);
  });

}
