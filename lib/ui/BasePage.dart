import 'package:DocUp/ui/mainPage/NavigatorView.dart';
import 'package:flutter/cupertino.dart';

class BasePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var nav = GlobalKey<NavigatorState>();
    return WillPopScope(
        child: NavigatorView(
          index: -1,
          navigatorKey: nav,
        ),
        onWillPop: () async {
        final isMain = !await nav.currentState.maybePop();
          return isMain;
        });
  }
}
