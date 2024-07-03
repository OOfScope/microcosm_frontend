import 'package:flutter/material.dart';

import '../../../constants.dart';
import '../../../utils.dart';

class QuizGame extends StatefulWidget {
  const QuizGame(
      {super.key,
      required this.onUpdate,
      required this.onCompleted,
      required this.onNext});

  final void Function(int) onUpdate;
  final VoidCallback onCompleted;
  final VoidCallback onNext;

  @override
  _QuizWidgetState createState() => _QuizWidgetState();
}

class _QuizWidgetState extends State<QuizGame> {
  final String imageUrl =
      'https://microcosm-backend.gmichele.com/get/low/random/';
  ImageResponse imageHandler = ImageResponse();

  int selectedAnswer = -1;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchImage();
  }

  Future<void> _fetchImage() async {
    await imageHandler.loadImages(imageUrl);
    setState(() {
      _isLoading = false;
    });
  }

  ButtonStyle _buttonStyle(Color backgroundColor) {
    return backgroundColor != Colors.blue
        ? ElevatedButton.styleFrom(
            minimumSize: const Size(200, 60),
            backgroundColor: backgroundColor,
            disabledBackgroundColor: backgroundColor.withOpacity(0.8),
            textStyle: const TextStyle(
                color: Colors.black,
                fontSize:
                    24), // Ensures the disabled color matches the background color
          )
        : ElevatedButton.styleFrom(
            minimumSize: const Size(200, 60),
            textStyle: const TextStyle(fontSize: 24, color: Colors.white),
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Image.memory(imageHandler.imageBytes,
                      width: 400, height: 400),
                  const SizedBox(height: 20),
                  ...List.generate(tissueTypes.length, (int index) {
                    Color buttonColor;
                    if (selectedAnswer == -1) {
                      buttonColor = Colors.blue;
                    } else if (selectedAnswer == index) {
                      buttonColor = (index == imageHandler.tissueToFind)
                          ? Colors.green
                          : Colors.red;
                    } else {
                      buttonColor = (index == imageHandler.tissueToFind)
                          ? Colors.green
                          : Colors.blue;
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 50.0),
                      child: FilledButton(
                        style: _buttonStyle(buttonColor),
                        onPressed: selectedAnswer == -1
                            ? () {
                                setState(() {
                                  selectedAnswer = index;
                                  if (selectedAnswer ==
                                      imageHandler.tissueToFind) {
                                    widget.onUpdate(correctAnswerScore);
                                    widget.onCompleted();
                                  } else {
                                    widget.onUpdate(wrongAnswerScore);
                                    widget.onCompleted();
                                  }
                                });
                              }
                            : null,
                        child: Text(tissueTypes[index] ?? 'Unknown Tissue'),
                      ),
                    );
                  }),
                ],
              ),
            ),
    );
  }
}
