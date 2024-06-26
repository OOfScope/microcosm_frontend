import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';

void main() {
  runApp(QuizGame());
}

class QuizGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Quiz Game'),
        ),
        body: QuizWidget(),
      ),
    );
  }
}

class QuizWidget extends StatefulWidget {
  @override
  _QuizWidgetState createState() => _QuizWidgetState();
}

class _QuizWidgetState extends State<QuizWidget> {
  final String imageUrl = 'https://microcosm-backend.gmichele.com/1/image';
  Uint8List? imageBytes;
  int selectedAnswer = -1;
  int correctAnswer = 2; // Index of the correct answer
  List<String> answers = ['Dog', 'Cat', 'Owl', 'Eagle'];

  @override
  void initState() {
    super.initState();
    _fetchImage();
  }

  Future<void> _fetchImage() async {
    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final base64Image = jsonResponse['rows'][0][0];
      setState(() {
        imageBytes = base64.decode(base64Image);
      });
    } else {
      throw Exception('Failed to load image');
    }
  }

  ButtonStyle _buttonStyle(Color backgroundColor) {
    return backgroundColor != Colors.blue
        ? ElevatedButton.styleFrom(
            minimumSize: Size(200, 60),
            backgroundColor: backgroundColor,
            disabledBackgroundColor: backgroundColor.withOpacity(0.8),
            textStyle: TextStyle(
                color: Colors.black,
                fontSize:
                    24), // Ensures the disabled color matches the background color
          )
        : ElevatedButton.styleFrom(
            minimumSize: Size(200, 60),
            textStyle: TextStyle(fontSize: 24, color: Colors.black),
          );
  }

  @override
  Widget build(BuildContext context) {
    return imageBytes == null
        ? Center(child: CircularProgressIndicator())
        : Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.memory(imageBytes!, width: 400, height: 400),
                SizedBox(height: 20),
                ...List.generate(answers.length, (index) {
                  Color buttonColor;
                  if (selectedAnswer == -1) {
                    buttonColor = Colors.blue;
                  } else if (selectedAnswer == index) {
                    buttonColor =
                        (index == correctAnswer) ? Colors.green : Colors.red;
                  } else {
                    buttonColor =
                        (index == correctAnswer) ? Colors.green : Colors.blue;
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 50.0),
                    child: ElevatedButton(
                      style: _buttonStyle(buttonColor),
                      onPressed: selectedAnswer == -1
                          ? () {
                              setState(() {
                                selectedAnswer = index;
                              });
                            }
                          : null,
                      child: Text(answers[index]),
                    ),
                  );
                }),
              ],
            ),
          );
  }
}
