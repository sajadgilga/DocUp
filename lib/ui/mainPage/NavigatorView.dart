import 'package:docup/models/Doctor.dart';
import 'package:docup/ui/doctorDetail/DoctorDetailPage.dart';
import 'package:docup/ui/home/notification/NotificationPage.dart';
import 'package:docup/ui/panel/Panel.dart';
import 'package:docup/ui/panel/PanelMenu.dart';
import 'package:docup/ui/panel/searchPage/SearchPage.dart';
import 'package:flutter/material.dart';

import '../home/Home.dart';

class NavigatorRoutes {
  static const String root = '/';
  static const String notificationView = '/notification';
  static const String panelMenu = '/panelMenu';
  static const String searchView = '/searchView';
  static const String doctorDialogue = '/doctorDialogue';
}

class NavigatorView extends StatelessWidget {
  final int index;
  final GlobalKey<NavigatorState> navigatorKey;
  final Doctor _doctor = Doctor(
      "دکتر زهرا شادلو",
      "متخصص پوست",
      "اقدسیه",
      Image(
        image: AssetImage('assets/lion.jpg'),
      ),
      []);

  NavigatorView({Key key, this.index, this.navigatorKey}) : super(key: key);

  Map<String, WidgetBuilder> _routeBuilders(BuildContext context) {
    switch (index) {
      case 0:
        return {
          NavigatorRoutes.root: (context) => Home(
                onPush: (direction) {
                  _push(context, direction);
                },
              ),
          NavigatorRoutes.notificationView: (context) => NotificationPage(),
          NavigatorRoutes.doctorDialogue: (context) => DoctorDetailPage(
                doctor: _doctor,
              ),
          NavigatorRoutes.searchView: (context) => SearchPage(onPush: (direction) {
            _push(context, direction);
          },),
        };
      case 1:
        return {
          NavigatorRoutes.root: (context) => Panel(
              doctor: _doctor,
              onPush: (direction) {
                _push(context, direction);
              }),
          NavigatorRoutes.panelMenu: (context) => PanelMenu((){_pop(context);}),
          NavigatorRoutes.doctorDialogue: (context) => DoctorDetailPage(
                doctor: _doctor,
              ),
          NavigatorRoutes.searchView: (context) => SearchPage(onPush: (direction) {
            _push(context, direction);
          },),
        };
      case 2:
        return {};
      case 3:
        return {};
      default:
        return {
          NavigatorRoutes.root: (context) => Home(
                onPush: (direction) {
                  _push(context, direction);
                },
              ),
          NavigatorRoutes.notificationView: (context) => NotificationPage(),
          NavigatorRoutes.doctorDialogue: (context) => DoctorDetailPage(),
          NavigatorRoutes.searchView: (context) => SearchPage(onPush: (direction) {
            _push(context, direction);
          },),
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
}
