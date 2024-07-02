import 'dart:math';
import 'package:flutter/material.dart';
import '../main/components/header.dart';

enum LevelStatus {
  locked,
  inProgress,
  completed,
}

class LevelButton extends StatelessWidget {
  LevelButton(
      {super.key,
      required this.levelNumber,
      required this.status,
      this.levelScore = 0,
      this.stars = 0,
      this.isActive = false,
      this.onTapLevelButton});

  final int levelNumber;
  LevelStatus status;
  int levelScore;
  int stars;
  bool isActive;
  final void Function(int, int)? onTapLevelButton;

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

  void addLevelScore(int score) {
    levelScore += score;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if ((onTapLevelButton != null) && isActive) {
          onTapLevelButton!(levelNumber, stars);
        }
      },
      child: Container(
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
                  (int index) => const Icon(
                    Icons.star,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

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

class Roadmap extends StatefulWidget {
  final void Function(int level, int difficulty) onLevelButtonPressed;

  const Roadmap({super.key, required this.onLevelButtonPressed});

  @override
  RoadmapState createState() => RoadmapState();
}

class RoadmapState extends State<Roadmap> {
  final List<LevelButton> _levelButtons = [];

  @override
  void initState() {
    super.initState();
    _initializeLevelButtons();
  }

  void _initializeLevelButtons() {
    for (int i = 1; i <= 40; i++) {
      _levelButtons.add(
        LevelButton(
          levelNumber: i,
          status: i == 1 ? LevelStatus.inProgress : LevelStatus.locked,
          stars: i == 1 ? 1 : 0,
          isActive: i == 1,
          onTapLevelButton: widget.onLevelButtonPressed,
        ),
      );
    }
  }

  void updateLevelScore(int index, int score) {
    setState(() {
      if (_levelButtons[index].stars < 3) {
        if (index >= 0 && index < _levelButtons.length) {
          if (_levelButtons[index].stars == 3) {
            _levelButtons[index].status = LevelStatus.completed;
            _levelButtons[index + 1].status = LevelStatus.inProgress;
            _levelButtons[index + 1].isActive = true;
          }

          _levelButtons[index].addLevelScore(score);
          _levelButtons[index].stars += 1;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Column levels = Column(
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
    );
    return Scaffold(
      appBar: AppBar(
        title: const Header(title: 'Roadmap'),
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
            child: levels,
          ),
        ],
      ),
    );
  }

  Widget _buildLevelPath(int startLevel, int endLevel) {
    final List<Widget> rows = <Widget>[];

    for (int i = startLevel; i <= endLevel; i += 4) {
      final int levelsInRow = min(4, endLevel - i + 1);
      final List<Widget> rowChildren = <Widget>[];

      for (int j = i; j < i + levelsInRow; j++) {
        final int currentLevel = j;
        rowChildren.add(
          Expanded(
            child: Column(
              children: <Widget>[
                _levelButtons[currentLevel - 1],
                if (currentLevel < endLevel && j < i + levelsInRow - 1)
                  SizedBox(
                    width: 60,
                    child: CustomPaint(
                      painter: DashedLinePainter(
                        color: Colors.white,
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
