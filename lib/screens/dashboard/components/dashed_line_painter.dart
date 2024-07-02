import 'package:flutter/material.dart';

class DashedLinePainter extends CustomPainter {
  DashedLinePainter({
    required this.color,
    this.strokeWidth = 2.0,
    this.gap = 3.0,
    this.dashLength = 5.0,
  });
  final Color color;
  final double strokeWidth;
  final double gap;
  final double dashLength;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    double startX = 0;
    final double startY = size.height / 2;
    final double endX = size.width;

    while (startX <= endX) {
      canvas.drawLine(
        Offset(startX, startY),
        Offset(startX + dashLength, startY),
        paint,
      );
      startX += dashLength + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
