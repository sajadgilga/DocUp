import 'package:flutter/material.dart';

import 'package:docup/constants/colors.dart';

class HomeNotification extends StatefulWidget {
  HomeNotification({Key key}) : super(key: key);

  @override
  _HomeNotificationState createState() {
    return _HomeNotificationState();
  }
}

class _HomeNotificationState extends State<HomeNotification> {
  int newNotificationCount = 15;

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
              child: Text('$newNotificationCount',
                  style: TextStyle(color: Colors.white, fontSize: 12)),
              decoration: BoxDecoration(
                  color: IColors.red,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  boxShadow: [
                    BoxShadow(
                        color: IColors.red,
                        offset: Offset(1, 3),
                        blurRadius: 10)
                  ])),
        ]));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 50,
        height: 50,
        child: Stack(
          children: <Widget>[
            _notificationIcon(),
            _notificationCountCircle()
          ],
        ));
  }
}
