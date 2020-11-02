import 'package:flutter/material.dart';

class DrawerPainter extends CustomPainter {
  double arcStart = 20;

  DrawerPainter({this.arcStart});

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
    double iconHeight = 60;
    double startX = arcStart;
    double startY = 40;
    double endX = startX + 15;
    double endY = 0;
    double controllerWidth = 5;
    double controllerHeight = 0;
    double arcHeight = 10;

    Offset topLeft = Offset(0, iconHeight);
    Offset topRight = Offset(size.width - endX, iconHeight);
    Offset bottomRight = Offset(size.width - endX, size.height);
    Offset bottomLeft = Offset(0, size.height);

    Offset endFirstCurve = Offset(startX, startY);
    Offset controllerFirstCurve = Offset(
        endFirstCurve.dx - controllerWidth, iconHeight - controllerHeight);

    Offset endArc = Offset(startX + iconWidth, startY);
    Offset controllerArc = Offset(startX + iconWidth / 2, 0);

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
