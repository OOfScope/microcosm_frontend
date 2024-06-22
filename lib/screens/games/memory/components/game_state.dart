// lib/game_state.dart
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'dart:convert';
import 'dart:math';

class GameState extends ChangeNotifier {
  List<int> cards = [];
  List<bool> cardFlipped = List<bool>.generate(8, (index) => false);
  List<bool> cardMatched = List<bool>.generate(8, (index) => false);
  List<Uint8List> pieces = [];
  List<int> flippedCards = [];
  bool isCardFlipping = false;

  bool get allMatched => cardMatched.every((matched) => matched);

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

    await Future.delayed(Duration(seconds: 1));

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
    final String imageUrl =
        'https://microcosm-backend.gmichele.com/random/image';
    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      final Map<String, dynamic> quizData = jsonDecode(response.body);

      final img.Image? fullImage =
          img.decodeImage(base64Decode(quizData['rows'][0][0]));

      if (fullImage == null) {
        throw Exception("Failed to create image from bytes.");
      }

      final int pieceWidth = 1024;
      final int pieceHeight = 1024;

      final List<Uint8List> originalPieces = [
        Uint8List.fromList(img
            .encodeJpg(img.copyCrop(fullImage, 0, 0, pieceWidth, pieceHeight))),
        Uint8List.fromList(img.encodeJpg(
            img.copyCrop(fullImage, pieceWidth, 0, pieceWidth, pieceHeight))),
        Uint8List.fromList(img.encodeJpg(
            img.copyCrop(fullImage, 0, pieceHeight, pieceWidth, pieceHeight))),
        Uint8List.fromList(img.encodeJpg(img.copyCrop(
            fullImage, pieceWidth, pieceHeight, pieceWidth, pieceHeight))),
      ];

      pieces = [...originalPieces, ...originalPieces]; // Duplicate the pieces
    } else {
      throw Exception('Failed to download image');
    }
  }

  void _shuffleCards() {
    cards = [0, 1, 2, 3, 0, 1, 2, 3];
    cards.shuffle(Random());
  }
}
