import 'package:docup/constants/colors.dart';
import 'package:docup/utils/Utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TimeSelectorWidget extends StatefulWidget {
  @override
  _TimeSelectorWidgetState createState() => _TimeSelectorWidgetState();
}

class _TimeSelectorWidgetState extends State<TimeSelectorWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      child: CustomPaint(
        painter: TimerSelectorPaint(),
      ),
    );
  }
}

class TimerSelectorPaint extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();
    paint.color = IColors.themeColor;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 50;

    canvas.drawCircle(Offset(8, 112), 80.0, paint);

    paintNumber(canvas, 12, Offset(0, -80));
    paintNumber(canvas, 3, Offset(80, 0));
    paintNumber(canvas, 6, Offset(0, 80));
    paintNumber(canvas, 9, Offset(-80, 0));
    paintNumber(canvas, 1, Offset(40, -69.282));
    paintNumber(canvas, 2, Offset(69.282, -40));
    paintNumber(canvas, 4, Offset(69.282, 40));
    paintNumber(canvas, 5, Offset(40, 69.282));
    paintNumber(canvas, 7, Offset(-40, 69.282));
    paintNumber(canvas, 8, Offset(-69.282, 40));
    paintNumber(canvas, 10, Offset(-69.282, -40));
    paintNumber(canvas, 11, Offset(-40, -69.282));

  }

  void paintNumber(Canvas canvas, int number, Offset position) {
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
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
