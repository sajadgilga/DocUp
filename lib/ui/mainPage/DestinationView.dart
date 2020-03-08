import 'package:docup/models/Doctor.dart';
import 'package:docup/ui/panel/Panel.dart';
import 'package:docup/ui/panel/PanelMenu.dart';
import 'package:flutter/material.dart';

import 'package:docup/ui/mainPage/navigator_destination.dart';
import 'MainPage.dart';
import '../home/Home.dart';

class DestinationView extends StatefulWidget {
  final int index;
  final VoidCallback onNavigation;
  List<Widget> _children = [
    Home(),
    Panel(
      doctor: Doctor(
          "دکتر زهرا شادلو",
          "متخصص پوست",
          "اقدسیه",
          Image(
            image: AssetImage('assets/lion.jpg'),
          ),
          []),
    )
  ];

  DestinationView({Key key, this.index, this.onNavigation}) : super(key: key);

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
              return widget._children[widget.index];
            case '/panelMenu':
              return PanelMenu();
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
