import 'dart:async';
import 'dart:math';

import 'package:Neuronio/constants/colors.dart';
import 'package:Neuronio/utils/Utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_circular_slider/flutter_circular_slider.dart';
import 'package:rxdart/rxdart.dart';

import 'AutoText.dart';

class CircularTimeSelector extends StatefulWidget {
  Offset tappedOffset;
  StreamController<Set<int>> controller = BehaviorSubject();
  Set<int> initTimes;
  TextEditingController timeController;

  CircularTimeSelector(
      {this.tappedOffset,
      this.controller,
      this.initTimes,
      this.timeController}) {
    /// TODO amir: this part should be cleaned later
    if (this.initTimes == null || this.initTimes.isEmpty) {
      if (timeController != null && (timeController.text ?? "") != "") {
        /// TODO amir: initial time selector with start and end time
        /// in both double circular and custom painter
        this.initTimes = {12};
      } else {
        this.initTimes = {12};
      }
    }
    if (this.timeController == null) {
      this.timeController = TextEditingController()..text = "00:00-00:00";
    }
  }

  @override
  _CircularTimeSelectorState createState() => _CircularTimeSelectorState();
}

class _CircularTimeSelectorState extends State<CircularTimeSelector> {
  Set<int> selectedNumbers = Set.of([]);
  int AM_PM = 0; //0 stands for am and 1 stands for pm

  @override
  void initState() {
    selectedNumbers = widget.initTimes;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double circleDiameter = 180;
    return Container(
        height: 330,
        width: MediaQuery.of(context).size.width,
        color: Color.fromARGB(0, 0, 0, 0),
        child: Column(
          children: [
            Container(
              alignment: Alignment.center,
              child: Container(
                margin: EdgeInsets.only(right: 125.0 * 2),
                decoration: BoxDecoration(
                    color: IColors.themeColor,
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          AM_PM = 0;
                          widget.timeController.text =
                              _getTimeFromSelectedNumbers();
                        });
                      },
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        child: AutoText(
                          "AM",
                          style: TextStyle(
                              color: AM_PM == 0
                                  ? Colors.white
                                  : IColors.whiteTransparent,
                              fontWeight: AM_PM == 0
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 14),
                        ),
                      ),
                    ),
                    Container(
                      width: 2,
                      height: 10,
                      color: Colors.white,
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          AM_PM = 1;
                          widget.timeController.text =
                              _getTimeFromSelectedNumbers();
                        });
                      },
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        child: AutoText("PM",
                            style: TextStyle(
                                color: AM_PM == 1
                                    ? Colors.white
                                    : IColors.whiteTransparent,
                                fontWeight: AM_PM == 1
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize: 14)),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  painter: TimerSelectorPaint(
                    context: context,
                    tappedOffset: widget.tappedOffset,
                    AM_PM: this.AM_PM,
                    selectedNumbers: selectedNumbers,
                    callback: (c) {},
                  ),
                ),
                DoubleCircularSlider(
                  12,
                  selectedNumbers.length != 0 ? selectedNumbers.reduce(min) : 0,
                  selectedNumbers.length != 0
                      ? min(selectedNumbers.reduce(max), 12)
                      : 0,
                  width: circleDiameter,
                  height: circleDiameter,
                  baseColor: Color.fromARGB(0, 0, 0, 0),
                  selectionColor: Color.fromARGB(0, 0, 0, 0),
                  handlerColor: Color.fromARGB(0, 0, 0, 0),
                  handlerOutterRadius: 20,
                  primarySectors: 0,
                  secondarySectors: 24,
                  onSelectionChange: (a, b, c) {
                    FocusScope.of(context).unfocus();
                    int start = a;
                    int end = b;
                    List<int> res = [];
                    if (start == end) {
                      res.add(start);
                    } else if ((start - end).abs() == 1) {
                      res.add(start);
                      res.add(end);
                    } else {
                      if (end > start) {
                        do {
                          print("a");
                          if (a == 0 && start == 0) {
                            res.add(12);
                          } else {
                            res.add(start);
                          }
                          start += 1;
                          start = start;
                        } while (start != end + 1);
                      } else {
                        do {
                          print("b");
                          res.add(start % 12 == 0 ? 12 : start % 12);
                          start += 1;
                          start = start % 12;
                        } while (start != end + 1);
                      }
                    }

                    setState(() {
                      selectedNumbers = {};
                      selectedNumbers.addAll(res);
                    });
                    widget.timeController.text = _getTimeFromSelectedNumbers();
                  },
                ),
                Container(
                  width: circleDiameter / 2,
                  alignment: Alignment.center,
                  child: TextField(
                    controller: widget.timeController,
                    style: TextStyle(fontSize: 15, color: IColors.darkGrey),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(border: InputBorder.none),
                    enabled: true,
                  ),
                )
              ],
            ),
          ],
        ));
  }

  String _getTimeFromSelectedNumbers() {
    List<int> res = selectedNumbers.toList();
    int s;
    int e;
    if (AM_PM == 0) {
      if (res.first > res.last) {
        s = res.first <= 12 ? (res.first + 0) : (res.first);
        e = res.last <= 12 ? (res.last + 12) : (res.last);
      } else {
        s = res.first <= 12 ? (res.first + 0) : (res.first);
        e = res.last <= 12 ? (res.last + 0) : (res.last);
      }
    } else if (AM_PM == 1) {
      if (res.first > res.last) {
        s = res.first <= 12 ? (res.first + 12) : (res.first);
        e = res.last <= 12 ? (res.last + 0) : (res.last);
      } else {
        s = res.first <= 12 ? (res.first + 12) : (res.first);
        e = res.last <= 12 ? (res.last + 12) : (res.last);
      }
    }

    int start = s;
    int end = e;
    if (res.length != 0 && res.length != 1) {
      return (start).toString() + ":00" + "-" + (end).toString() + ":00";
    }
    return "00:00-00:00";
  }
}

class TimerSelectorPaint extends CustomPainter {
  final Offset tappedOffset;
  final BuildContext context;
  final Function(int) callback;
  final Set<int> selectedNumbers;
  final double upShift = 3;
  final double rightShift = 3;
  int AM_PM = 0; //0 stands for am and 1 stands for pm
  TimerSelectorPaint(
      {this.context,
      this.selectedNumbers,
      this.tappedOffset,
      this.callback,
      this.AM_PM});

  final Map<int, Offset> numbers = {
    1: Offset(40, -69.282),
    2: Offset(69.282, -40),
    3: Offset(80, 0),
    4: Offset(69.282, 40),
    5: Offset(40, 69.282),
    6: Offset(0, 80),
    7: Offset(-40, 69.282),
    8: Offset(-69.282, 40),
    9: Offset(-80, 0),
    10: Offset(-69.282, -40),
    11: Offset(-40, -69.282),
    12: Offset(0, -80)
  };
  final double xOffset = 0;
  final double yOffset = 0;

  int selectedNumber = -1;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();
    paint.color = Colors.white;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 50;

    canvas.drawCircle(Offset(xOffset, yOffset), 80.0, paint);

    Offset localOffset;
    if (tappedOffset != null) {
      RenderBox getBox = context.findRenderObject();
      localOffset = getBox.globalToLocal(tappedOffset);
    }

    numbers.forEach((key, value) {
      paintNumber(canvas, key + this.AM_PM * 12, value, localOffset);
    });
    if (selectedNumber != -1) {
      callback(selectedNumber);
    }
  }

  void paintNumber(
      Canvas canvas, int number, Offset position, Offset localOffset) {
    int numberStatus = -1;

    /// -1 as number not selected, 0 as border of selected numbers,1 as middle
    if (selectedNumbers != null) {
      if (selectedNumbers.contains(number) &&
          isPointInside(position, localOffset)) {
        if (selectedNumbers.first == number || selectedNumbers.last == number) {
          numberStatus = 0;
        } else {
          numberStatus = 1;
        }
        Paint paint = Paint();
        paint.color = numberStatus == 0 ? Colors.white : IColors.themeColor;
        paint.style = PaintingStyle.fill;
        paint.strokeWidth = 2;

        canvas.drawCircle(
            Offset(position.dx + xOffset, position.dy + yOffset), 20, paint);
      }
    }
    final textStyle = TextStyle(
        color: numberStatus == 0
            ? IColors.themeColor
            : (numberStatus == 1 ? Colors.white : IColors.darkGrey),
        fontSize: 20,
        fontFamily: 'iransans',
        fontWeight: FontWeight.bold);
    final textSpan = TextSpan(
      text: replaceFarsiNumber('$number'),
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
        canvas, Offset(position.dx + xOffset - 8, position.dy + yOffset - 13));

    if (isPointInside(position, localOffset)) {
      selectedNumber = number;
    }
  }

  bool isPointInside(Offset point, Offset localOffset) {
    return true;
    if (localOffset == null) return false;
    return pow(point.dx + xOffset - localOffset.dx, 2) +
            pow(point.dy + yOffset - localOffset.dy, 2) <
        pow(20, 2);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
