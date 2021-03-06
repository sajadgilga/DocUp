import 'package:Neuronio/constants/assets.dart';
import 'package:Neuronio/constants/colors.dart';
import 'package:Neuronio/ui/widgets/AutoText.dart';
import 'package:Neuronio/utils/CrossPlatformSvg.dart';
import 'package:flutter/material.dart';

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
            child: CrossPlatformSvg.asset(
              Assets.onCallMedicalIcon,
              width: 35,
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
              child: AutoText('$newNotificationCount',
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
          children: <Widget>[_notificationIcon(), _notificationCountCircle()],
        ));
  }
}
