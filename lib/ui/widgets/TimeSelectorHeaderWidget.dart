import 'package:Neuronio/constants/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'AutoText.dart';

class TimeSelectorHeaderWidget extends StatefulWidget {
  final Function(bool) callback;
  bool initialTimeIsSelected;
  final bool timeDateWidgetsFlag;

  TimeSelectorHeaderWidget(
      {this.callback,
      this.initialTimeIsSelected = false,
      this.timeDateWidgetsFlag = true});

  @override
  _TimeSelectorHeaderWidgetState createState() =>
      _TimeSelectorHeaderWidgetState();
}

class _TimeSelectorHeaderWidgetState extends State<TimeSelectorHeaderWidget> {
  _TimeSelectorHeaderWidgetState();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        widget.timeDateWidgetsFlag
            ? Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(width: 20),
                  GestureDetector(
                      child: Icon(Icons.calendar_today,
                          color: widget.initialTimeIsSelected
                              ? Colors.grey
                              : IColors.themeColor),
                      onTap: () {
                        setState(() {
                          widget.initialTimeIsSelected = false;
                        });
                        widget.callback(widget.initialTimeIsSelected);
                      }),
                  SizedBox(width: 20),
                  GestureDetector(
                      child: Icon(Icons.access_time,
                          color: widget.initialTimeIsSelected
                              ? IColors.themeColor
                              : Colors.grey),
                      onTap: () {
                        setState(() {
                          widget.initialTimeIsSelected = true;
                        });
                        widget.callback(widget.initialTimeIsSelected);
                      }),
                  SizedBox(width: 20),
                ],
              )
            : SizedBox(),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: AutoText("زمان‌های ویزیت با پزشک",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  textAlign: TextAlign.right),
            ),
          ],
        ),
      ],
    );
  }
}
