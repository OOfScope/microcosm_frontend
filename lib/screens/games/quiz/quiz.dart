import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
  final String imageUrl =
      'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg';
  Uint8List? imageBytes;
  int selectedAnswer = -1;
  int correctAnswer = 2; // Index of the correct answer
  List<String> answers = ['Dog', 'Cat', 'Owl', 'Eagle'];

  @override
  void initState() {
    super.initState();
    _downloadImage();
  }

  Future<void> _downloadImage() async {
    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      setState(() {
        imageBytes = response.bodyBytes;
      });
    } else {
      throw Exception('Failed to download image');
    }
  }

  @override
  Widget build(BuildContext context) {
    return imageBytes == null
        ? Center(child: CircularProgressIndicator())
        : Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.memory(imageBytes!, width: 200, height: 200),
              SizedBox(height: 20),
              ...List.generate(answers.length, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 5.0, horizontal: 50.0),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                        selectedAnswer == -1
                            ? Colors.blue
                            : selectedAnswer == index
                                ? (index == correctAnswer
                                    ? Colors.green
                                    : Colors.red)
                                : (index == correctAnswer
                                    ? Colors.green
                                    : Colors.blue),
                      ),
                    ),
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
          );
  }
}
