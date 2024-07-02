// Assume that the SelectTheAreaGame widget has a callback for when the game is loaded

import 'package:flutter/material.dart';

import '../select_the_area/select_the_area_screen.dart';

class GameWrapper extends StatelessWidget {
  const GameWrapper(
      {super.key,
      required this.onGameLoaded,
      required this.onScoreUpdate,
      required this.onGameCompleted,
      required this.onNextLevel});

  final String title = 'Select the Area';
  final VoidCallback onGameLoaded;
  final ValueChanged<int> onScoreUpdate;
  final VoidCallback onGameCompleted;
  final VoidCallback onNextLevel;

  @override
  Widget build(BuildContext context) {
    // Simulate a delay for loading the game
    Future.delayed(const Duration(seconds: 4), onGameLoaded);

    return Center(
      child: SelectTheAreaGame(
        onUpdate: onScoreUpdate,
        onCompleted: onGameCompleted,
        onNext: onNextLevel,
      ),
    );
  }
}
