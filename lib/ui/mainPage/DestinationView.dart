import 'package:docup/ui/panel/Panel.dart';
import 'package:flutter/material.dart';

import 'package:docup/ui/mainPage/navigator_destination.dart';
import 'MainPage.dart';
import '../home/Home.dart';

class DestinationView extends StatefulWidget {
  final Destination destination;
  final VoidCallback onNavigation;

  DestinationView({Key key, this.destination, this.onNavigation})
      : super(key: key);

  @override
  DestinationViewState createState() {
    return DestinationViewState();
  }
}

class DestinationViewState extends State<DestinationView> {
  Route<dynamic> _route(RouteSettings settings) {
    return MaterialPageRoute(
        settings: settings,
        builder: (BuildContext context) {
          switch (settings.name) {
            case '/':
              return Home();
            case '/panel':
              return Panel();
            default:
              return MainPage();
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      observers: <NavigatorObserver>[],
      onGenerateRoute: _route,
    );
  }
}
