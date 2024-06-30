import 'dart:math';
import 'package:flutter/material.dart';

enum LevelStatus {
  locked,
  inProgress,
  completed,
}

class LevelButton extends StatelessWidget {
  final int levelNumber;
  final LevelStatus status;
  final int stars;
  final bool isActive;

  LevelButton({
    required this.levelNumber,
    required this.status,
    this.stars = 0,
    this.isActive = false,
  });

  Color _getColor() {
    switch (status) {
      case LevelStatus.locked:
        return Colors.red;
      case LevelStatus.inProgress:
        return isActive ? Colors.yellow : Colors.grey;
      case LevelStatus.completed:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _getColor(),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            levelNumber.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (stars > 0)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                stars,
                (index) => const Icon(
                  Icons.star,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class DashedLinePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;
  final double dashLength;

  DashedLinePainter({
    required this.color,
    this.strokeWidth = 2.0,
    this.gap = 3.0,
    this.dashLength = 5.0,
  });

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

class Roadmap extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Roadmap'),
      ),
      body: Stack(
        children: <Widget>[
          Opacity(
            opacity: 0.5,
            child: Image.asset(
              '/images/improved_rm.jpeg',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              scale: 2,
            ),
          ),
          SingleChildScrollView(
            child: Column(
              children: <Widget>[
                _buildLevelPath(1, 5),
                _buildLevelPath(6, 10),
                _buildLevelPath(11, 15),
                _buildLevelPath(16, 20),
                _buildLevelPath(21, 25),
                _buildLevelPath(26, 30),
                _buildLevelPath(31, 35),
                _buildLevelPath(36, 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelPath(int startLevel, int endLevel) {
    final random = Random();
    final int numRows = (endLevel - startLevel + 1) ~/ 4 + 1; // Calculate number of rows
    final List<Widget> rows = [];

    for (int i = startLevel; i <= endLevel; i += 4) {
      final int levelsInRow = min(4, endLevel - i + 1); // Calculate levels in this row
      final List<Widget> rowChildren = [];

      for (int j = i; j < i + levelsInRow; j++) {
        final int currentLevel = j;
        final int nextLevel = currentLevel + 1;
        final bool isActive = true; // Replace with your logic for active levels
        rowChildren.add(
          Expanded(
            child: Column(
              children: <Widget>[
                LevelButton(
                  levelNumber: currentLevel,
                  status: LevelStatus.completed, // Example status, modify as needed
                  stars: 3, // Example stars, modify as needed
                  isActive: isActive,
                ),
                if (currentLevel < endLevel && j < i + levelsInRow - 1) //                 if (currentLevel < endLevel && j < i + levelsInRow - 1)
                  SizedBox(
                    width: 60,
                    child: CustomPaint(
                      painter: DashedLinePainter(
                        color: Colors.white,
                        strokeWidth: 2.0,
                        gap: 3.0,
                        dashLength: 10.0,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      }

      rows.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: rowChildren,
      ));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Column(
        children: rows,
      ),
    );
  }
}
