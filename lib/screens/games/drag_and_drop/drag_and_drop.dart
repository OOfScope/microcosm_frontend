import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
      'https://microcosm-backend.gmichele.com/get/low/random/image';

  List<Image> pieces = [];
  final Map<int, Image?> _currentPositions = {
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

        final Image? fullImage =
            Image.memory(base64Decode(quizData['rows'][0][0]));

        if (fullImage == null) {
          throw Exception("Failed to create image from bytes.");
        }
        pieces.add(fullImage);

        // Set<int> pixels = {};
        // for (int i = 0; i < fullImage.width; i++) {
        //   for (int j = 0; j < fullImage.height; j++) {
        //     pixels.add(fullImage.getPixel(i, j));
        //   }
        // }

        // print(pixels);

        // for (int i = 0; i < pixels.length; i++) {
        //   print(Color(pixels.elementAt(i)));
        //   print(Color(pixels.elementAt(i)).red);
        // }

        setState(() {});
      } else {
        throw Exception('Failed to download image');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        SizedBox(
          height: 20,
        ),
        Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            Container(
              transformAlignment: Alignment.center,
              padding: EdgeInsets.all(20),
              alignment: Alignment.center,
              height: 500,
              width: 500,
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisSpacing: 8, mainAxisSpacing: 8, crossAxisCount: 2),
                itemCount: pieces.length,
                itemBuilder: (context, index) {
                  return DragTarget<Image>(
                    onAcceptWithDetails: (data) {
                      setState(() {
                        Image? previousData = _currentPositions[index];
                        int previousIndex = _currentPositions.keys.firstWhere(
                            (key) => _currentPositions[key] == data,
                            orElse: () => -1);

                        if (previousIndex != -1) {
                          //print('Previous index: $previousIndex');
                          _currentPositions[previousIndex] = previousData;
                        }
                        _currentPositions[index] = data as Image?;
                      });
                    },
                    builder: (context, candidateData, rejectedData) {
                      return _currentPositions[index] != null
                          ? Draggable(
                              data: _currentPositions[index],
                              child: Container(
                                child: _currentPositions[index]!,
                                width: 200,
                                height: 200,
                              ),
                              feedback: Center(
                                child: Container(
                                  child: _currentPositions[index]!,
                                  width: 200,
                                  height: 200,
                                ),
                              ),
                              childWhenDragging: Container(
                                color: Colors.grey[200],
                                width: 200,
                                height: 200,
                                child: Center(
                                    child: Text(
                                  labels[index],
                                  style: TextStyle(fontSize: 24),
                                )),
                              ))
                          : Container(
                              color: Colors.grey[200],
                              width: 200,
                              height: 200,
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
            ),
            SizedBox(
              height: 40,
            ),
            Center(
              child: Row(
                children: [
                  SizedBox(
                    height: 400,
                    width: 400,
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio:
                            1, // Aspect ratio for 1:1 (square) items
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: pieces.length,
                      itemBuilder: (context, index) {
                        return Draggable<Image>(
                          data: pieces[index],
                          child: !_currentPositions.containsValue(pieces[index])
                              ? Container(
                                  child: pieces[index], width: 200, height: 200)
                              : Container(
                                  width: 200,
                                  height: 200), // Empty space once placed
                          feedback: Container(
                              child: pieces[index], width: 200, height: 200),
                          childWhenDragging: Container(
                              width: 200,
                              height: 200), // Empty space while dragging
                          onDragCompleted: () {},
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ]),
          SizedBox(
            height: 40,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            ElevatedButton(
              onPressed: _checkPositions,
              child: Text('Confirm Choices'),
            ),
            ElevatedButton(
              onPressed: () => widget.onNavButtonPressed(0),
              child: Text('Main Menu'),
            )
          ]),
        ]),
        Center(
          child: Text(
            resultMessage,
            style: resultMessage != 'Well Done!'
                ? TextStyle(fontSize: 24, color: Colors.red)
                : TextStyle(fontSize: 24, color: Colors.green),
          ),
        ),
      ],
    );
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
