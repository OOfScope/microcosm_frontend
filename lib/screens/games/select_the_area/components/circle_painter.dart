import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CirclePainter extends CustomPainter {
  CirclePainter(this.startPoint, this.endPoint);
  final Offset startPoint;
  final Offset endPoint;

  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = (startPoint.dx + endPoint.dx) / 2;
    final double centerY = (startPoint.dy + endPoint.dy) / 2;
    final double radius = sqrt(pow(endPoint.dx - startPoint.dx, 2) +
            pow(endPoint.dy - startPoint.dy, 2)) /
        2;

    final Paint paint = Paint()
      ..color = Colors.blue.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(centerX, centerY), radius, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
