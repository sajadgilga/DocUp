import 'package:Neuronio/blocs/NotificationBloc.dart';
import 'package:Neuronio/ui/mainPage/NavigatorView.dart';
import 'package:Neuronio/utils/WebsocketHelper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BasePage extends StatefulWidget {
  @override
  _BasePageState createState() => _BasePageState();
}

class _BasePageState extends State<BasePage> with WidgetsBindingObserver {
  final NotificationBloc _notificationBloc = NotificationBloc();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      SocketHelper().appIsPaused = false;
    } else if (state == AppLifecycleState.paused) {
      SocketHelper().appIsPaused = true;
    }
    // setState(() {});
    print("Base Page => App State Changed: " + state.toString());
  }

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    try {
      WidgetsBinding.instance.removeObserver(this);
    } catch (e) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _notificationBloc.add(GetNewestNotifications());
    var nav = GlobalKey<NavigatorState>();
    return MultiBlocProvider(
        providers: [
          BlocProvider<NotificationBloc>.value(
            value: _notificationBloc,
          )
        ],
        child: WillPopScope(
            child: NavigatorView(
              index: -1,
              navigatorKey: nav,
            ),
            onWillPop: () async {
              final isMain = !await nav.currentState.maybePop();
              return isMain;
            }));
  }
}
