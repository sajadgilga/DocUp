
import 'package:flutter/material.dart';

class MyPainter extends CustomPainter {

  @override
  void paint(Canvas canvas, Size size) {
    Paint rectPaint = Paint();
    rectPaint.style = PaintingStyle.fill;
    rectPaint.color = Colors.white;

    Paint paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
        RRect.fromRectAndCorners(
            Rect.fromLTWH(
                0.0, size.height * 0.2, size.width * 0.9, size.height * 0.8),
            topRight: Radius.circular(40)),
        rectPaint);

    canvas.drawRRect(
        RRect.fromRectAndCorners(
            Rect.fromLTWH(size.width * 0.2, size.height * 0.101 , size.width * 0.2,
                size.height * 0.1),
            topRight: Radius.circular(40),
            topLeft: Radius.circular(40)),
        rectPaint);

    Path path = Path();
    path.moveTo(size.width * 0.1, size.height * 0.201);
    path.quadraticBezierTo(size.width * 0.2, size.height * 0.2, size.width * 0.2, size.height  * 0.15);
    path.lineTo(size.width * 0.2, size.height  * 0.2);
    path.close();
    canvas.drawPath(path, paint);

    Path path2= Path();
    path2.moveTo(size.width * 0.4, size.height * 0.15);
    path2.quadraticBezierTo(size.width * 0.4, size.height * 0.2, size.width * 0.5, size.height  * 0.201);
    path2.lineTo(size.width * 0.4, size.height  * 0.2);
    path2.close();
    canvas.drawPath(path2, paint);

  }

  @override
  bool shouldRepaint(MyPainter oldDelegate) => false;
}
