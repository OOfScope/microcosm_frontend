// lib/memory_game.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'dart:math';
import 'package:admin/screens/games/memory/components/game_state.dart';

class MemoryGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GameState()..initialize(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Memory Game'),
        ),
        body: Column(
          children: [
            Expanded(child: MyHomePage()),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Consumer<GameState>(
                builder: (context, gameState, child) {
                  if (gameState.allMatched) {
                    return Text(
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
  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 16.0,
        crossAxisSpacing: 16.0,
      ),
      itemCount: gameState.cards.length,
      itemBuilder: (context, index) {
        return CardTile(index: index);
      },
    );
  }
}

class CardTile extends HookWidget {
  final int index;

  CardTile({required this.index});

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);
    final isFlipped = gameState.cardFlipped[index];

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
        duration: Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          final rotateAnim = Tween(begin: pi, end: 0.0).animate(animation);
          return AnimatedBuilder(
            animation: rotateAnim,
            child: child,
            builder: (context, child) {
              final isUnder = (ValueKey(isFlipped) != child!.key);
              var tilt = ((animation.value - 0.5).abs() - 0.5) * 0.002;
              tilt *= isUnder ? -1.0 : 1.0;
              final value = isUnder
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
                key: ValueKey(true),
                index: gameState.cards[index],
              )
            : CardBack(
                key: ValueKey(false),
              ),
      ),
    );
  }
}

class CardFace extends StatelessWidget {
  final int index;
  CardFace({required Key key, required this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);
    final pieces = gameState.pieces;

    return Container(
        child: pieces.isNotEmpty
            ? Image.memory(pieces[gameState.cards[index]])
            : CircularProgressIndicator());
  }
}

class CardBack extends StatelessWidget {
  CardBack({required Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
