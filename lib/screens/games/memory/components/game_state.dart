import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../utils.dart';

class GameState extends ChangeNotifier {
  List<int> cards = <int>[];
  List<bool> cardFlipped = List<bool>.generate(8, (int index) => false);
  List<bool> cardMatched = List<bool>.generate(8, (int index) => false);
  List<Image> pieces = <Image>[];
  List<int> flippedCards = <int>[];
  bool isCardFlipping = false;

  bool get allMatched => cardMatched.every((bool matched) => matched);

  Future<void> initialize() async {
    await _loadImages();
    _setupCards();
    notifyListeners();
  }

  void flipCard(int index) {
    cardFlipped[index] = !cardFlipped[index];
    flippedCards.add(index);

    if (flippedCards.length == 2) {
      _checkMatch();
    } else {
      notifyListeners();
    }
  }

  Future<void> _checkMatch() async {
    isCardFlipping = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    if (_isMatch(flippedCards[0], flippedCards[1])) {
      cardMatched[flippedCards[0]] = true;
      cardMatched[flippedCards[1]] = true;
    } else {
      cardFlipped[flippedCards[0]] = false;
      cardFlipped[flippedCards[1]] = false;
    }

    flippedCards.clear();
    isCardFlipping = false;
    notifyListeners();
  }

  bool _isMatch(int index1, int index2) {
    // Check if the cards are a circular match
    final int id1 = cards[index1];
    final int id2 = cards[index2];
    return (id1 + 4) % 8 == id2 || (id2 + 4) % 8 == id1;
  }

  Future<void> _loadImages() async {
    const String imageUrl =
        'https://microcosm-backend.gmichele.com/get/low/random/image';

    pieces = await loadOnlyImages(imageUrl, 8);
  }

  void _setupCards() {
    cards = <int>[0, 1, 2, 3, 4, 5, 6, 7];
    //cards.shuffle(Random());
    if (kDebugMode) {
      // Print the solution pairs
      for (int i = 0; i < 4; i++) {
        final int pairIndex = (i + 4) % 8;
        print('Card ${cards[i]} is paired with Card ${cards[pairIndex]}');
      }
      print(cards);
    }
  }
}
