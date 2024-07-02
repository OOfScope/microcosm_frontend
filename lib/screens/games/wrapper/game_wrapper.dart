// Assume that the SelectTheAreaGame widget has a callback for when the game is loaded
import 'package:flutter/material.dart';

import '../select_the_area/select_the_area_screen.dart';

class GameWrapper extends StatelessWidget {
  const GameWrapper(
      {super.key, required this.onLoaded, required this.onScoreUpdate});
  final String title = 'Select the Area';
  final VoidCallback onLoaded;
  final ValueChanged<int> onScoreUpdate;

  @override
  Widget build(BuildContext context) {
    // Simulate a delay for loading the game
    Future.delayed(const Duration(seconds: 4), onLoaded);

    return const Center(
      child: SelectTheAreaGame(),
    );
  }
}
