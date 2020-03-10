import 'package:flutter/material.dart';

class DrawerPainter extends CustomPainter {
  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    double iconWidth = 60;
    double iconHeight = 75;
    double startX = 20;
    double startY = 0;
    double endX = 35;
    double endY = 0;
    double controllerWidth = 5;
    double controllerHeight = 5;
    double arcHeight = 10;

    Offset topLeft = Offset(0, iconHeight);
    Offset topRight = Offset(size.width - endX, iconHeight);
    Offset bottomRight = Offset(size.width - endX, size.height);
    Offset bottomLeft = Offset(0, size.height);

    Offset endFirstCurve = Offset(startX, 50);
    Offset controllerFirstCurve = Offset(
        endFirstCurve.dx - controllerWidth, iconHeight - controllerHeight);

    Offset endArc = Offset(startX + iconWidth, 50);
    Offset controllerArc = Offset(startX + iconWidth / 2, 10);

    Offset endSecondCurve = Offset(2 * startX + iconWidth, iconHeight);
    Offset controllerSecondCurve = Offset(
        endSecondCurve.dx - startX + controllerWidth,
        iconHeight - controllerHeight);

    Path path = Path()
      ..moveTo(topLeft.dx, topLeft.dy)
      ..quadraticBezierTo(controllerFirstCurve.dx, controllerFirstCurve.dy,
          endFirstCurve.dx, endFirstCurve.dy)
      ..quadraticBezierTo(
          controllerArc.dx, controllerArc.dy, endArc.dx, endArc.dy)
      ..quadraticBezierTo(controllerSecondCurve.dx, controllerSecondCurve.dy,
          endSecondCurve.dx, endSecondCurve.dy)
      ..lineTo(topRight.dx - 20, topRight.dy)
      ..quadraticBezierTo(
          topRight.dx, topRight.dy, topRight.dx, topRight.dy + 20)
      ..lineTo(bottomRight.dx, bottomRight.dy)
      ..lineTo(bottomLeft.dx, bottomRight.dy)
      ..close();

    canvas.drawShadow(path, Colors.black, 30, false);

    canvas.drawPath(path, paint);
  }
}
