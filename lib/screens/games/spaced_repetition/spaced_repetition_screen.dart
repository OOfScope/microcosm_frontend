import 'package:flutter/material.dart';

class SpacedRepetitionGame extends StatefulWidget {
  const SpacedRepetitionGame(
      {super.key,
      required this.onUpdate,
      required this.onCompleted,
      required this.onNext});

  final void Function(int) onUpdate;
  final VoidCallback onCompleted;
  final VoidCallback onNext;

  @override
  _SpacedRepetitionGameState createState() => _SpacedRepetitionGameState();
}

class _SpacedRepetitionGameState extends State<SpacedRepetitionGame> {
  @override
  Widget build(BuildContext context) {
    return Container(
        // Add your widget tree here
        );
  }
}
