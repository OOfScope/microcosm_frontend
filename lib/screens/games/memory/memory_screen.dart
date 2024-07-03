// lib/memory_game.dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';

import '../../../constants.dart';
import '../../../utils.dart';
import 'components/game_state.dart';

class MemoryGame extends StatelessWidget {
  const MemoryGame(
      {super.key,
      required this.onUpdate,
      required this.onCompleted,
      required this.onNext});

  final void Function(int) onUpdate;
  final VoidCallback onCompleted;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => GameState()..initialize(),
      child: Column(
        children: <Widget>[
          RichText(
            text: TextSpan(
              text:
                  'Match the cards based on the same tissue pattern to win the game!',
              style: DefaultTextStyle.of(context).style.apply(
                    fontSizeFactor: 2,
                    fontWeightDelta: 2,
                  ),
            ),
          ),
          const SizedBox(height: 10),
          const Expanded(child: MyHomePage()),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Consumer<GameState>(
              builder:
                  (BuildContext context, GameState gameState, Widget? child) {
                if (gameState.allMatched) {
                  SchedulerBinding.instance.addPostFrameCallback((_) {
                    onCompleted();
                    onUpdate(correctAnswerScore);
                  });
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      const AnswerWidget(
                        text: 'Well Done',
                        answerColor: Colors.green,
                      ),
                      SizedBox(
                        height: 60,
                        width: 170,
                        child: FilledButton(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.blue),
                          ),
                          onPressed: () {
                            onNext();
                          },
                          child: const Text('Next',
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(fontSize: 17, color: Colors.white)),
                        ),
                      ),
                    ],
                  );
                } else {
                  return Container(); // Empty container if not all matched
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final GameState gameState = Provider.of<GameState>(context);
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: SizedBox(
        height: 700,
        width: 1100,
        child: GridView.builder(
          padding: const EdgeInsets.all(16.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 16.0,
            crossAxisSpacing: 16.0,
          ),
          itemCount: gameState.cards.length,
          itemBuilder: (BuildContext context, int index) {
            return CardTile(index: index);
          },
        ),
      ),
    );
  }
}

class CardTile extends HookWidget {
  const CardTile({super.key, required this.index});
  final int index;

  @override
  Widget build(BuildContext context) {
    final GameState gameState = Provider.of<GameState>(context);
    final bool isFlipped = gameState.cardFlipped[index];

    return GestureDetector(
      onTap: () {
        // print info
        //print('isFlipped: $isFlipped');
        //print('gameState.isCardFlipping: ${gameState.isCardFlipping}');
        //print('gameState.cardMatched: ${gameState.cardMatched}');
        //print('gameState.cards: ${gameState.cards}');
        //print('gameState.flippedCards: ${gameState.flippedCards}');
        //print('gameState.allMatched: ${gameState.allMatched}');

        if (!isFlipped && !gameState.isCardFlipping) {
          gameState.flipCard(index);
        }
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          final Animation<double> rotateAnim =
              Tween(begin: pi, end: 0.0).animate(animation);
          return AnimatedBuilder(
            animation: rotateAnim,
            child: child,
            builder: (BuildContext context, Widget? child) {
              final bool isUnder = (ValueKey(isFlipped) != child!.key);
              double tilt = ((animation.value - 0.5).abs() - 0.5) * 0.002;
              tilt *= isUnder ? -1.0 : 1.0;
              final double value = isUnder
                  ? (rotateAnim.value < pi / 2 ? rotateAnim.value : pi / 2)
                  : rotateAnim.value;
              return Transform(
                transform: (Matrix4.rotationY(value)..setEntry(3, 0, tilt)),
                alignment: Alignment.center,
                child: child,
              );
            },
          );
        },
        // matched card must not be flipped
        child: isFlipped
            ? CardFace(
                key: const ValueKey(true),
                index: gameState.cards[index],
              )
            : const CardBack(
                key: ValueKey(false),
              ),
      ),
    );
  }
}

class CardFace extends StatelessWidget {
  const CardFace({required Key key, required this.index}) : super(key: key);
  final int index;

  @override
  Widget build(BuildContext context) {
    final GameState gameState = Provider.of<GameState>(context);
    final List<Image> pieces = gameState.pieces;

    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Colors.black26,
              offset: Offset(2, 2),
              blurRadius: 5,
            ),
          ],
        ),
        child: pieces.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: pieces[gameState.cards[index]],
              )
            : const CircularProgressIndicator());
  }
}

class CardBack extends StatelessWidget {
  const CardBack({required Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Colors.black26,
            offset: Offset(2, 2),
            blurRadius: 5,
          ),
        ],
      ),
      child: const Center(
        child: Text(
          '?',
          style: TextStyle(fontSize: 24, color: Colors.white),
        ),
      ),
    );
  }
}
