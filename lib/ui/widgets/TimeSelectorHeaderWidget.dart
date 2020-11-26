import 'package:docup/constants/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'AutoText.dart';

class TimeSelectorHeaderWidget extends StatefulWidget {
  final Function(bool) callback;
  final bool initialTimeIsSelected;
  final bool timeDateWidgetsFlag;

  TimeSelectorHeaderWidget({this.callback, this.initialTimeIsSelected=false,this.timeDateWidgetsFlag=true});

  @override
  _TimeSelectorHeaderWidgetState createState() =>
      _TimeSelectorHeaderWidgetState(
          timeIsSelected: this.initialTimeIsSelected);
}

class _TimeSelectorHeaderWidgetState extends State<TimeSelectorHeaderWidget> {
  bool timeIsSelected = false;

  _TimeSelectorHeaderWidgetState({this.timeIsSelected = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        widget.timeDateWidgetsFlag?Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(width: 20),
            GestureDetector(
                child: Icon(Icons.calendar_today,
                    color: timeIsSelected ? Colors.grey : IColors.themeColor),
                onTap: () {
                  setState(() {
                    timeIsSelected = false;
                  });
                  widget.callback(timeIsSelected);
                }),
            SizedBox(width: 20),
            GestureDetector(
                child: Icon(Icons.access_time,
                    color: timeIsSelected ? IColors.themeColor : Colors.grey),
                onTap: () {
                  setState(() {
                    timeIsSelected = true;
                  });
                  widget.callback(timeIsSelected);
                }),
            SizedBox(width: 20),
          ],
        ):SizedBox(),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: AutoText("زمان برگزاری",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  textAlign: TextAlign.right),
            ),
          ],
        ),
      ],
    );
  }
}
