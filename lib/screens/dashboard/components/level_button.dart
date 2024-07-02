import 'package:flutter/material.dart';

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
  void Function(int, int)? onTapLevelButton;

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
