import 'package:docup/blocs/PanelBloc.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:docup/blocs/EntityBloc.dart';
import 'package:docup/ui/start/OnBoardingPage.dart';
import 'package:docup/ui/start/SplashPage.dart';
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

//  Widget _startPage = MainPage();
//  Widget _startPage = StartPage();
  Widget _startPage = SplashPage();
//  final PanelBloc _panelBloc = PanelBloc();

//  Widget _startPage = OnBoardingPage();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
//    Crashlytics.instance.enableInDevMode = true;  // Pass all uncaught errors from the framework to Crashlytics.
    FlutterError.onError = Crashlytics.instance.recordFlutterError;

    return MultiBlocProvider(
        providers: [
          BlocProvider<PanelBloc>.value(value: PanelBloc()),
          BlocProvider<EntityBloc>.value(value: EntityBloc()),
        ],
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
