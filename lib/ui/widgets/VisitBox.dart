import 'package:Neuronio/constants/colors.dart';
import 'package:Neuronio/models/VisitTime.dart';
import 'package:flutter/material.dart';

import 'AutoText.dart';

class VisitBox extends StatefulWidget {
  final List<VisitTime> visitTimes;

  VisitBox({Key key, this.visitTimes}) : super(key: key);

  @override
  _VisitBoxState createState() => _VisitBoxState();
}

class _VisitBoxState extends State<VisitBox> {
  Widget _visitTime(VisitTime time) {
    return Container(
        margin: EdgeInsets.only(top: 10, bottom: 10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(15)),
            border: (time.isNear
                ? Border.all(width: 2, color: IColors.themeColor)
                : Border.all(width: 0, color: Colors.transparent))),
        child: Container(
          padding: EdgeInsets.all(3),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              AutoText(
                time.day,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: (time.isNear ? IColors.themeColor : Colors.black54)),
              ),
              AutoText(
                time.month.name,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.normal,
                    color: (time.isNear ? IColors.themeColor : Colors.black54)),
              )
            ],
          ),
        ));
  }

  Widget _visitTimeList(times) => Expanded(
      flex: 2,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: times,
      ));

  Widget _visitBoxLabel() => Container(
        margin: EdgeInsets.only(left: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(bottom: 10),
              padding: EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
              decoration: BoxDecoration(
                  color: IColors.themeColor,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10))),
              child: AutoText(
                ' ویزیت ها ',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
            AutoText(
              '۱۳۹۸',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: IColors.themeColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 10),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    List<Widget> times = [];
    for (var visitTime in widget.visitTimes) {
      times.add(_visitTime(visitTime));
    }
    return Container(
      padding: EdgeInsets.only(left: 25, right: 25),
      constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width - 50,
          maxWidth: MediaQuery.of(context).size.width - 50),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(10))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[_visitTimeList(times), _visitBoxLabel()],
      ),
    );
  }
}
