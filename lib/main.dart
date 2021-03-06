import 'package:Neuronio/blocs/EntityBloc.dart';
import 'package:Neuronio/blocs/PanelBloc.dart';
import 'package:Neuronio/blocs/ScreenginBloc.dart';
import 'package:Neuronio/ui/start/SplashPage.dart';
import 'package:Neuronio/utils/CrossPlatformDeviceDetection.dart';
import 'package:Neuronio/utils/DateTimeService.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

import 'constants/colors.dart';
import 'constants/strings.dart';

void main() async {
  // /// to initialize shared preference after cleaning packages.
  // SharedPreferences.setMockInitialValues({});
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();

  /// initializing datetime and load datetime from ntp package
  DateTimeService.loadCurrentDateTimes();

  runApp(Phoenix(child: MyApp()));
}

class MyApp extends StatefulWidget {
  static GlobalKey<NavigatorState> globalNavigator =
      GlobalKey<NavigatorState>();

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget _startPage = SplashPage();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Color.fromARGB(80, 0, 0, 0)));
    // SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    if (CrossPlatformDeviceDetection.isAndroid ||
        CrossPlatformDeviceDetection.isIOS) {
      //    Crashlytics.instance.enableInDevMode = true;  // Pass all uncaught errors from the framework to Crashlytics.
      FlutterError.onError = Crashlytics.instance.recordFlutterError;
    }
    return MultiBlocProvider(
        providers: [
          BlocProvider<PanelBloc>.value(value: PanelBloc()),
          BlocProvider<EntityBloc>.value(value: EntityBloc()),
          BlocProvider<ScreeningBloc>.value(value: ScreeningBloc()),
        ],
        child: MaterialApp(
          title: InAppStrings.appTitle,
          theme: ThemeData(
            fontFamily: 'iransans',
            primarySwatch: MaterialColor(IColors.themeColor.value, swatch),
          ),
//      home: MainPage(),
          home: Scaffold(
            body: _startPage,
            backgroundColor: Colors.white,
          ),
        ));
  }
}
