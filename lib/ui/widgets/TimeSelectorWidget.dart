import 'dart:async';
import 'dart:math';

import 'package:docup/constants/colors.dart';
import 'package:docup/utils/Utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
      child: CustomPaint(
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
    );
  }
}

class TimerSelectorPaint extends CustomPainter {
  final Offset tappedOffset;
  final BuildContext context;
  final Function(int) callback;
  final Set<int> selectedNumbers;

  TimerSelectorPaint(
      {this.context, this.selectedNumbers, this.tappedOffset, this.callback});

  final Map<int, Offset> numbers = {
    13: Offset(40, -69.282),
    14: Offset(69.282, -40),
    15: Offset(80, 0),
    16: Offset(69.282, 40),
    17: Offset(40, 69.282),
    18: Offset(0, 80),
    19: Offset(-40, 69.282),
    20: Offset(-69.282, 40),
    21: Offset(-80, 0),
    22: Offset(-69.282, -40),
    23: Offset(-40, -69.282),
    12: Offset(0, -80)
  };

  int selectedNumber = -1;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();
    paint.color = IColors.themeColor;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 50;

    canvas.drawCircle(Offset(8, 112), 80.0, paint);

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
        color: Colors.black,
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
    textPainter.paint(canvas, Offset(position.dx, position.dy + 100));

    if (selectedNumbers.contains(number) &&
        isPointInside(position, localOffset)) {
    } else if (selectedNumbers.contains(number) ||
        isPointInside(position, localOffset)) {
      Paint paint = Paint();
      paint.color = Colors.black;
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 2;
      canvas.drawCircle(Offset(position.dx + 8, position.dy + 112), 20, paint);
    }
    if (isPointInside(position, localOffset)) {
      selectedNumber = number;
    }
  }

  bool isPointInside(Offset point, Offset localOffset) {
    if (localOffset == null) return false;
    return pow(point.dx + 8 - localOffset.dx, 2) +
            pow(point.dy + 112 - localOffset.dy, 2) <
        pow(20, 2);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
