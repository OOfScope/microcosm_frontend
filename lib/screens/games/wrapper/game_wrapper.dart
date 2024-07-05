// Assume that the SelectTheAreaGame widget has a callback for when the game is loaded

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../utils.dart';
import '../drag_and_drop/drag_and_drop.dart';
import '../memory/memory_screen.dart';
import '../quiz/quiz.dart';
import '../select_the_area/select_the_area_screen.dart';

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
    final GameInfo? highestFrequencyGame =
        GameInfoManager.instance.getHighestFrequencyGame();
    final Map<int, Widget> games = <int, Widget>{
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

    if (index % 5 == 0) {
      if (highestFrequencyGame != null) {
        if (kDebugMode) {
          print('Highest frequency game: ${highestFrequencyGame.level % 5}');
          print(games[(highestFrequencyGame.level % 5) + 1]);
        } //FIX THIS INDEX
        return Center(child: games[(highestFrequencyGame.level % 5) + 1]);
      } else {
        // No games to play screen
        return NoGamesLeftScreen(onNextLevel: onNextLevel);
      }
    } else {
      // Simulate a delay for loading the game
      if (games[index % 5] is QuizGame) {
        Future.delayed(const Duration(seconds: 4), onGameLoaded);
      } else if (games[index % 5] is DragAndDropGame) {
        Future.delayed(const Duration(seconds: 26), onGameLoaded);
      } else if (games[index % 5] is MemoryGame) {
        Future.delayed(const Duration(seconds: 12), onGameLoaded);
      } else if (games[index % 5] is SelectTheAreaGame) {
        Future.delayed(const Duration(seconds: 4), onGameLoaded);
      }

      return Center(child: games[index % 5]);
    }
  }
}

class NoGamesLeftScreen extends StatelessWidget {
  const NoGamesLeftScreen({
    super.key,
    required this.onNextLevel,
  });

  final VoidCallback onNextLevel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RichText(
            text: TextSpan(
              text: 'No Games Available!',
              style: DefaultTextStyle.of(context).style.apply(
                    fontSizeFactor: 2.2,
                    fontWeightDelta: 2,
                  ),
            ),
          ),
          const Text(
            'You have successfully completed all the games!',
            style: TextStyle(
                fontSize: 30, fontWeight: FontWeight.bold, color: Colors.green),
          ),
          const SizedBox(height: 20),
          Center(
              child: SizedBox(
                  height: 60,
                  width: 340,
                  child: FilledButton(
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32.0, vertical: 16.0),
                        backgroundColor: Colors.blue,
                        textStyle: const TextStyle(fontSize: 20)),
                    child: const Text('Go Back to Main Screen',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                    onPressed: () {
                      onNextLevel();
                    },
                  ))),
        ],
      ),
    );
  }
}
