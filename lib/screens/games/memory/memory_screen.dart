// lib/memory_game.dart
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';

import 'components/game_state.dart';

class MemoryGame extends StatelessWidget {
  const MemoryGame({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => GameState()..initialize(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Memory Game'),
        ),
        body: Column(
          children: <Widget>[
            const Expanded(child: MyHomePage()),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Consumer<GameState>(
                builder: (BuildContext context, GameState gameState, Widget? child) {
                  if (gameState.allMatched) {
                    return const Text(
                      'Well Done',
                      style: TextStyle(fontSize: 24, color: Colors.green),
                    );
                  } else {
                    return Container(); // Empty container if not all matched
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final GameState gameState = Provider.of<GameState>(context);
    return GridView.builder(
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
          final Animation<double> rotateAnim = Tween(begin: pi, end: 0.0).animate(animation);
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
    final List<Uint8List> pieces = gameState.pieces;

    return Container(
        child: pieces.isNotEmpty
            ? Image.memory(pieces[gameState.cards[index]])
            : const CircularProgressIndicator());
  }
}

class CardBack extends StatelessWidget {
  const CardBack({required Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Colors.grey,
      child: Center(
        child: Text(
          '?',
          style: TextStyle(fontSize: 24, color: Colors.white),
        ),
      ),
    );
  }
}
