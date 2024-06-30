// lib/game_state.dart
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class GameState extends ChangeNotifier {
  List<int> cards = <int>[];
  List<bool> cardFlipped = List<bool>.generate(8, (int index) => false);
  List<bool> cardMatched = List<bool>.generate(8, (int index) => false);
  List<Image> pieces = <Image>[];
  List<int> flippedCards = <int>[];
  bool isCardFlipping = false;

  bool get allMatched => cardMatched.every((bool matched) => matched);

  Future<void> initialize() async {
    await _downloadAndSplitImage();
    _shuffleCards();
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

    if (cards[flippedCards[0]] == cards[flippedCards[1]]) {
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

  Future<void> _downloadAndSplitImage() async {
    final List<Image> originalPieces = <Image>[];
    const String imageUrl =
        'https://microcosm-backend.gmichele.com/get/low/random/image';

    for (int i = 0; i < 4; i++) {
      final http.Response response = await http.get(Uri.parse(imageUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonImageResponse =
            jsonDecode(response.body) as Map<String, dynamic>;

        final Image fullImage = Image.memory(
            base64Decode(jsonImageResponse['rows'][0][0] as String));

        originalPieces.add(fullImage);

        // Duplicate the pieces
      } else {
        throw Exception('Failed to download image');
      }
    }
    pieces = <Image>[...originalPieces, ...originalPieces];
  }

  void _shuffleCards() {
    cards = <int>[0, 1, 2, 3, 0, 1, 2, 3];
    cards.shuffle(Random());
  }
}
