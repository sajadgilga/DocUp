import 'package:docup/ui/start/StartPage.dart';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'constants/colors.dart';
import 'constants/strings.dart';

import 'ui/mainPage/MainPage.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Strings.appTitle,
      theme: ThemeData(
        fontFamily: 'iransans',
        primarySwatch: MaterialColor(IColors.themeColor.value, swatch),
      ),
      home: MainPage(),
//      home: StartPage(),
    );
  }
}