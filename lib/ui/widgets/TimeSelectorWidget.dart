import 'dart:math';

import 'package:docup/constants/colors.dart';
import 'package:docup/utils/Utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TimeSelectorWidget extends StatefulWidget {
  Offset tappedOffset;
  final Function(int) callback;

  TimeSelectorWidget({this.tappedOffset, this.callback});

  @override
  _TimeSelectorWidgetState createState() => _TimeSelectorWidgetState();
}

class _TimeSelectorWidgetState extends State<TimeSelectorWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      child: CustomPaint(
        painter: TimerSelectorPaint(
            context: context,
            tappedOffset: widget.tappedOffset,
            callback: widget.callback),
      ),
    );
  }
}

class TimerSelectorPaint extends CustomPainter {
  final Offset tappedOffset;
  final BuildContext context;
  final Function(int) callback;
  Set<int> selectedNumbers = Set.identity();

  TimerSelectorPaint({this.context, this.tappedOffset, this.callback});

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

    if (selectedNumbers.contains(number) ||
        isPointInside(position, localOffset)) {
      callback(number);
      selectedNumbers.add(number);
      Paint paint = Paint();
      paint.color = Colors.black;
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 2;
      canvas.drawCircle(Offset(position.dx + 8, position.dy + 112), 20, paint);
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
