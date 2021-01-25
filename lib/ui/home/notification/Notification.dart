import 'package:Neuronio/constants/colors.dart';
import 'package:Neuronio/ui/mainPage/NavigatorView.dart';
import 'package:Neuronio/ui/widgets/AutoText.dart';
import 'package:Neuronio/utils/Utils.dart';
import 'package:flutter/material.dart';

class HomeNotification extends StatelessWidget {
  int newNotificationCount;
  final Function(String, dynamic) onPush;

  HomeNotification({Key key, this.newNotificationCount=0, @required this.onPush})
      : super(key: key);

  Widget _notificationIcon() {
    return Container(
        alignment: Alignment.bottomCenter,
        child: Material(
          child: InkWell(
            child: Icon(
              Icons.notifications,
              size: 35,
            ),
            hoverColor: Colors.white,
          ),
          color: Colors.transparent,
        ));
  }

  Widget _notificationCountCircle() {
    return Container(
        alignment: Alignment.centerRight,
        child: Wrap(children: <Widget>[
          Container(
              padding: EdgeInsets.only(left: 5, right: 5),
              child: AutoText(
                  '${replaceFarsiNumber(newNotificationCount.toString())}',
                  style: TextStyle(color: Colors.white, fontSize: 12)),
              decoration: BoxDecoration(
                  color: IColors.themeColor,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  boxShadow: [
                    BoxShadow(
                        color: IColors.themeColor,
                        offset: Offset(1, 3),
                        blurRadius: 10)
                  ])),
        ]));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onPush(NavigatorRoutes.notificationView, null);
      },
      child: Container(
          width: 50,
          height: 50,
          child: Stack(
            children: <Widget>[_notificationIcon(), _notificationCountCircle()],
          )),
    );
  }
}
