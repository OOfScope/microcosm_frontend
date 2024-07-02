import 'package:flutter/material.dart';

import '../../../../constants.dart';

class AnswerWidget extends StatelessWidget {
  const AnswerWidget({
    super.key,
    required this.text,
    required this.answerColor,
  });

  final String text;
  final Color answerColor;
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
          color: answerColor,
          fontSize: answerFontSize,
          fontWeight: FontWeight.bold),
      overflow: TextOverflow.visible,
    );
  }
}
