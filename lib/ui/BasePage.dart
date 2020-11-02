import 'package:docup/blocs/NotificationBloc.dart';
import 'package:docup/ui/mainPage/NavigatorView.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BasePage extends StatelessWidget {
  final NotificationBloc _notificationBloc = NotificationBloc();

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
