import 'package:docup/blocs/EntityBloc.dart';
import 'package:docup/ui/start/StartPage.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'constants/colors.dart';
import 'constants/strings.dart';

import 'ui/mainPage/MainPage.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  static GlobalKey<NavigatorState> globalNavigator =
      GlobalKey<NavigatorState>();
  Widget _startPage = MainPage();
//  Widget _startPage = StartPage();


  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays ([SystemUiOverlay.bottom]);
    return BlocProvider<EntityBloc>(
        create: (context) => EntityBloc(),
        child: MaterialApp(
          title: Strings.appTitle,
          theme: ThemeData(
            fontFamily: 'iransans',
            primarySwatch: MaterialColor(IColors.themeColor.value, swatch),
          ),
//      home: MainPage(),
          home: _startPage,
        ));
  }
}
