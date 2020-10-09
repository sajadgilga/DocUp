import 'dart:async';
import 'dart:math';

import 'package:docup/constants/colors.dart';
import 'package:docup/utils/Utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_circular_slider/flutter_circular_slider.dart';
import 'package:rxdart/rxdart.dart';

class TimeSelectorWidget extends StatefulWidget {
  Offset tappedOffset;
  StreamController<Set<int>> controller = BehaviorSubject();
  final Set<int> initTimes;

  TimeSelectorWidget({this.tappedOffset, this.controller, this.initTimes});

  @override
  _TimeSelectorWidgetState createState() => _TimeSelectorWidgetState();
}

class _TimeSelectorWidgetState extends State<TimeSelectorWidget> {
  Set<int> selectedNumbers = Set.of([]);

  @override
  void initState() {
    selectedNumbers = widget.initTimes;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 250,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              painter: TimerSelectorPaint(
                  context: context,
                  tappedOffset: widget.tappedOffset,
                  selectedNumbers: selectedNumbers,
                  callback: (number) {
                    setState(() {
                      if (selectedNumbers.contains(number)) {
                        selectedNumbers.remove(number);
                      } else {
                        selectedNumbers.add(number);
                      }
                      widget.controller.add(selectedNumbers);
                    });
                  }),
            ),
            DoubleCircularSlider(
              12,
              0,
              0,
              width: 180,
              height: 180,
              baseColor: Color.fromARGB(0, 0, 0, 0),
              selectionColor: Colors.red,
            ),
          ],
        ));
  }
}

class TimerSelectorPaint extends CustomPainter {
  final Offset tappedOffset;
  final BuildContext context;
  final Function(int) callback;
  final Set<int> selectedNumbers;
  final double upShift = 3;
  final double rightShift = 3;

  TimerSelectorPaint(
      {this.context, this.selectedNumbers, this.tappedOffset, this.callback});

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
      paintNumber(canvas, key, value, localOffset);
    });
    if (selectedNumber != -1) {
      callback(selectedNumber);
    }
  }

  void paintNumber(
      Canvas canvas, int number, Offset position, Offset localOffset) {
    final textStyle = TextStyle(
        color: IColors.darkGrey,
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
    if (selectedNumbers != null) {
      if (selectedNumbers.contains(number) &&
          isPointInside(position, localOffset)) {
        Paint paint = Paint();
        paint.color = IColors.themeColor;
        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = 2;
        canvas.drawCircle(
            Offset(position.dx + xOffset, position.dy + yOffset), 20, paint);
      } else if (selectedNumbers.contains(number) ||
          isPointInside(position, localOffset)) {
        Paint paint = Paint();
        paint.color = Colors.black;
        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = 2;
        canvas.drawCircle(
            Offset(position.dx + xOffset, position.dy + yOffset), 20, paint);
      }
    }

    if (isPointInside(position, localOffset)) {
      selectedNumber = number;
    }
  }

  bool isPointInside(Offset point, Offset localOffset) {
    if (localOffset == null) return false;
    return pow(point.dx + xOffset - localOffset.dx, 2) +
            pow(point.dy + yOffset - localOffset.dy, 2) <
        pow(20, 2);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
