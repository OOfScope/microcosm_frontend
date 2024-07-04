// Assume that the SelectTheAreaGame widget has a callback for when the game is loaded

import 'package:flutter/material.dart';

import '../drag_and_drop/drag_and_drop.dart';
import '../memory/memory_screen.dart';
import '../quiz/quiz.dart';
import '../select_the_area/select_the_area_screen.dart';
import '../spaced_repetition/spaced_repetition_screen.dart';

class GameWrapper extends StatelessWidget {
  const GameWrapper(
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
      0: SpacedRepetitionGame(
        onUpdate: onScoreUpdate,
        onCompleted: onGameCompleted,
        onNext: onNextLevel,
      ),
      1: QuizGame(
        onUpdate: onScoreUpdate,
        onCompleted: onGameCompleted,
        onNext: onNextLevel,
        onGameLoaded: onGameLoaded,
      ),
      2: DragAndDropGame(
        onUpdate: onScoreUpdate,
        onCompleted: onGameCompleted,
        onNext: onNextLevel,
        onGameLoaded: onGameLoaded,
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
    if (games[index % 5] is QuizGame) {
      Future.delayed(const Duration(seconds: 4), onGameLoaded);
    } else if (games[index % 5] is DragAndDropGame) {
      Future.delayed(const Duration(seconds: 26), onGameLoaded);
    } else if (games[index % 5] is MemoryGame) {
      Future.delayed(const Duration(seconds: 12), onGameLoaded);
    } else if (games[index % 5] is SelectTheAreaGame) {
      Future.delayed(const Duration(seconds: 4), onGameLoaded);
    } else if (games[index % 5] is SpacedRepetitionGame) {
      Future.delayed(const Duration(seconds: 10), onGameLoaded);
    }

    return Center(child: games[index % 5]);
  }
}
