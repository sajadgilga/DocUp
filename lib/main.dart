import 'package:docup/blocs/EntityBloc.dart';
import 'package:docup/blocs/PanelBloc.dart';
import 'package:docup/ui/start/SplashPage.dart';
import 'package:docup/utils/dateTimeService.dart';

// import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:syncfusion_localizations/syncfusion_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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

class MyApp extends StatelessWidget {
  static GlobalKey<NavigatorState> globalNavigator =
      GlobalKey<NavigatorState>();

  Widget _startPage = SplashPage();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    //   statusBarColor: Color.fromARGB(100, 180, 180, 180),
    // ));
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
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            // ... app-specific localization delegate[s] here
            SfGlobalLocalizations.delegate
          ],
          supportedLocales: [
            const Locale('en'),
            const Locale('fa'),
            // ... other locales the app supports
          ],
          locale: const Locale('fa'),
          theme: ThemeData(
            fontFamily: 'iransans',
            primarySwatch: MaterialColor(IColors.themeColor.value, swatch),
          ),
//      home: MainPage(),
          home: _startPage,
        ));
  }
}
