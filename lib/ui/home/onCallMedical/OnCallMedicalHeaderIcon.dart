import 'package:flutter/material.dart';

import 'package:docup/constants/colors.dart';

class OnCallMedicalHeaderIcon extends StatefulWidget {
  OnCallMedicalHeaderIcon({Key key}) : super(key: key);

  @override
  _OnCallMedicalHeaderIconState createState() {
    return _OnCallMedicalHeaderIconState();
  }
}

class _OnCallMedicalHeaderIconState extends State<OnCallMedicalHeaderIcon> {
  int newNotificationCount = 1;

  Widget _notificationIcon() {
    return Container(
        alignment: Alignment.bottomCenter,
        child: Material(
          child: InkWell(
            child: Icon(
              Icons.person,
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
