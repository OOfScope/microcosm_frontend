import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'dart:convert';

typedef void IndexCallback(int index);

class DragAndDropGame extends StatelessWidget {
  final IndexCallback onNavButtonPressed;

  const DragAndDropGame({Key? key, required this.onNavButtonPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Drag and Drop Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Drag and Drop Game'),
        ),
        body: DragAndDropWidget(
          onNavButtonPressed: this.onNavButtonPressed,
        ),
      ),
    );
  }
}

class DragAndDropWidget extends StatefulWidget {
  final IndexCallback onNavButtonPressed;

  const DragAndDropWidget({Key? key, required this.onNavButtonPressed})
      : super(key: key);

  @override
  _DragAndDropWidgetState createState() => _DragAndDropWidgetState();
}

class _DragAndDropWidgetState extends State<DragAndDropWidget> {
  final String imageUrl =
      'https://microcosm-backend.gmichele.com/get/low/random';

  List<Uint8List> pieces = [];
  final Map<int, Uint8List?> _currentPositions = {
    0: null,
    1: null,
    2: null,
    3: null
  };

  String resultMessage = '';
  List<String> labels = [
    'Top Left',
    'Top Right',
    'Bottom Left',
    'Bottom Right'
  ];
  @override
  void initState() {
    super.initState();
    _downloadAndSplitImage();
  }

  Future<void> _downloadAndSplitImage() async {
    for (int i = 0; i < 4; i++) {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final Map<String, dynamic> quizData = jsonDecode(response.body);

        final img.Image? fullImage =
            img.decodeImage(base64Decode(quizData['rows'][0][1]));

        if (fullImage == null) {
          throw Exception("Failed to create image from bytes.");
        }

        // pieces = [
        //   Uint8List.fromList(img.encodeJpg(
        //       img.copyCrop(fullImage, 0, 0, pieceWidth, pieceHeight))),
        //   Uint8List.fromList(img.encodeJpg(
        //       img.copyCrop(fullImage, pieceWidth, 0, pieceWidth, pieceHeight))),
        //   Uint8List.fromList(img.encodeJpg(img.copyCrop(
        //       fullImage, 0, pieceHeight, pieceWidth, pieceHeight))),
        //   Uint8List.fromList(img.encodeJpg(img.copyCrop(
        //       fullImage, pieceWidth, pieceHeight, pieceWidth, pieceHeight))),
        // ];

        print('hey');

        Set<int> pixels = {};
        for (int i = 0; i < fullImage.width; i++) {
          for (int j = 0; j < fullImage.height; j++) {
            pixels.add(fullImage.getPixel(i, j));
          }
        }

        print(pixels);

        for (int i = 0; i < pixels.length; i++) {
          print(Color(pixels.elementAt(i)));
          print(Color(pixels.elementAt(i)).red);
        }

        setState(() {});
      } else {
        throw Exception('Failed to download image');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      Column(children: [
        Expanded(
            child: Container(
          padding: EdgeInsets.all(20),
          alignment: Alignment.center,
          height: 400,
          width: 400,
          child: GridView.builder(
            gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 1),
            itemCount: pieces.length,
            itemBuilder: (context, index) {
              return DragTarget<Uint8List>(
                onAccept: (data) {
                  setState(() {
                    Uint8List? previousData = _currentPositions[index];
                    int previousIndex = _currentPositions.keys.firstWhere(
                        (key) => _currentPositions[key] == data,
                        orElse: () => -1);
                    if (previousIndex != -1) {
                      _currentPositions[previousIndex] = previousData;
                    }
                    _currentPositions[index] = data;
                    //print(_currentPositions[index]);
                  });
                },
                builder: (context, candidateData, rejectedData) {
                  return _currentPositions[index] != null
                      ? Draggable(
                          data: _currentPositions[index],
                          child: Image.memory(
                            _currentPositions[index]!,
                            width: 100,
                            height: 100,
                          ),
                          feedback: Image.memory(_currentPositions[index]!,
                              width: 100, height: 100),
                          childWhenDragging: Container(
                              color: Colors.grey[200], width: 100, height: 100),
                        )
                      : Container(
                          color: Colors.grey[200],
                          width: 100,
                          height: 100,
                          child: Center(
                            child: Text(
                              labels[index],
                              style: TextStyle(fontSize: 24),
                            ),
                          ));
                },
              );
            },
          ),
        )),
        SizedBox(height: 20),
        Row(children: [
          ElevatedButton(
            onPressed: _checkPositions,
            child: Text('Confirm Choices'),
          ),
          ElevatedButton(
            onPressed: () => widget.onNavButtonPressed(0),
            child: Text('Main Menu'),
          )
        ]),
        SizedBox(height: 20),
        Text(
          resultMessage,
          style: resultMessage != 'Well Done!'
              ? TextStyle(fontSize: 24, color: Colors.red)
              : TextStyle(fontSize: 24, color: Colors.green),
        ),
      ]),
      Column(
        children: pieces.map((piece) {
          return Draggable<Uint8List>(
            data: piece,
            child: !_currentPositions.containsValue(piece)
                ? Image.memory(piece, width: 200, height: 200)
                : Container(width: 200, height: 200), // Empty space once placed
            feedback: Image.memory(piece, width: 200, height: 200),
            childWhenDragging: Container(
                width: 200, height: 200), // Empty space while dragging
          );
        }).toList(),
      ),
    ]);
  }

  void _checkPositions() {
    bool allCorrect = true;
    for (int i = 0; i < pieces.length; i++) {
      if (_currentPositions[i] != pieces[i]) {
        allCorrect = false;
        break;
      }
    }

    setState(() {
      resultMessage = allCorrect ? 'Well Done!' : 'Wrong choices';
    });
  }
}
