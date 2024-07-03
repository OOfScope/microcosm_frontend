// Assume that the SelectTheAreaGame widget has a callback for when the game is loaded

import 'package:flutter/material.dart';

import '../drag_and_drop/drag_and_drop.dart';
import '../memory/memory_screen.dart';
import '../quiz/quiz.dart';
import '../select_the_area/select_the_area_screen.dart';

class GameWrapper extends StatelessWidget {
  GameWrapper(
      {super.key,
      required this.index,
      required this.onGameLoaded,
      required this.onScoreUpdate,
      required this.onGameCompleted,
      required this.onNextLevel});

  final int index;
  final VoidCallback onGameLoaded;
  final ValueChanged<int> onScoreUpdate;
  final VoidCallback onGameCompleted;
  final VoidCallback onNextLevel;

  @override
  Widget build(BuildContext context) {
    final Map<int, Widget> games = <int, Widget>{
      1: QuizGame(
        onUpdate: onScoreUpdate,
        onCompleted: onGameCompleted,
        onNext: onNextLevel,
      ),
      2: DragAndDropGame(
        onUpdate: onScoreUpdate,
        onCompleted: onGameCompleted,
        onNext: onNextLevel,
      ),
      3: MemoryGame(
        onUpdate: onScoreUpdate,
        onCompleted: onGameCompleted,
        onNext: onNextLevel,
      ),
      4: SelectTheAreaGame(
        onUpdate: onScoreUpdate,
        onCompleted: onGameCompleted,
        onNext: onNextLevel,
      ),
    };
    // Simulate a delay for loading the game
    Future.delayed(const Duration(seconds: 4), onGameLoaded);

    return Center(child: games[index]);
  }
}
