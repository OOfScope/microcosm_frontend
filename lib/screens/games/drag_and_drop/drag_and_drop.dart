import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

typedef IndexCallback = void Function(int index);

class DragAndDropGame extends StatelessWidget {
  const DragAndDropGame({super.key, required this.onNavButtonPressed});
  final IndexCallback onNavButtonPressed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drag and Drop Game'),
      ),
      body: DragAndDropWidget(
        onNavButtonPressed: onNavButtonPressed,
      ),
    );
  }
}

class DragAndDropWidget extends StatefulWidget {
  const DragAndDropWidget({super.key, required this.onNavButtonPressed});
  final IndexCallback onNavButtonPressed;

  @override
  _DragAndDropWidgetState createState() => _DragAndDropWidgetState();
}

class _DragAndDropWidgetState extends State<DragAndDropWidget> {
  final String imageUrl =
      'https://microcosm-backend.gmichele.com/get/low/random/image';

  List<Image> pieces = <Image>[];
  final Map<int, Image?> _currentPositions = <int, Image?>{
    0: null,
    1: null,
    2: null,
    3: null
  };

  String resultMessage = '';

  List<String> labels = <String>[
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
      final http.Response response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonImageResponse =
            jsonDecode(response.body) as Map<String, dynamic>;

        final String base64Image = jsonImageResponse['rows'][0][0] as String;

        final Uint8List rawImage = base64Decode(base64Image);

        final Image fullImage = Image.memory(rawImage);
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
      children: <Widget>[
        const SizedBox(
          height: 20,
        ),
        Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Container(
                      transformAlignment: Alignment.center,
                      padding: const EdgeInsets.all(20),
                      alignment: Alignment.center,
                      height: 500,
                      width: 500,
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                                crossAxisCount: 2),
                        itemCount: pieces.length,
                        itemBuilder: (BuildContext context, int index) {
                          return DragTarget<Image>(
                            onAcceptWithDetails:
                                (DragTargetDetails<Image?> draggableImage) {
                              setState(() {
                                final Image? previousData =
                                    _currentPositions[index];
                                final int previousIndex = _currentPositions.keys
                                    .firstWhere(
                                        (int key) =>
                                            _currentPositions[key] ==
                                            draggableImage.data,
                                        orElse: () => -1);

                                if (previousIndex != -1) {
                                  //print('Previous index: $previousIndex');
                                  _currentPositions[previousIndex] =
                                      previousData;
                                }
                                _currentPositions[index] = draggableImage.data;
                              });
                            },
                            builder: (BuildContext context,
                                List<Image?> candidateData, List rejectedData) {
                              return _currentPositions[index] != null
                                  ? Draggable(
                                      data: _currentPositions[index],
                                      feedback: Center(
                                        child: SizedBox(
                                          width: 200,
                                          height: 200,
                                          child: _currentPositions[index],
                                        ),
                                      ),
                                      childWhenDragging: Container(
                                        color: Colors.grey[200],
                                        width: 200,
                                        height: 200,
                                        child: Center(
                                            child: Text(
                                          labels[index],
                                          style: const TextStyle(fontSize: 24),
                                        )),
                                      ),
                                      child: SizedBox(
                                        width: 200,
                                        height: 200,
                                        child: _currentPositions[index],
                                      ))
                                  : Container(
                                      color: Colors.grey[200],
                                      width: 200,
                                      height: 200,
                                      child: Center(
                                        child: Text(
                                          labels[index],
                                          style: const TextStyle(fontSize: 24),
                                        ),
                                      ));
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    Center(
                      child: Row(
                        children: <Widget>[
                          SizedBox(
                            height: 400,
                            width: 400,
                            child: GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                              itemCount: pieces.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Draggable<Image>(
                                  data:
                                      pieces[index], // Empty space once placed
                                  feedback: SizedBox(
                                      width: 200,
                                      height: 200,
                                      child: pieces[index]),
                                  childWhenDragging: const SizedBox(
                                      width: 200,
                                      height:
                                          200), // Empty space while dragging
                                  onDragCompleted: () {},
                                  child: !_currentPositions
                                          .containsValue(pieces[index])
                                      ? SizedBox(
                                          width: 200,
                                          height: 200,
                                          child: pieces[index])
                                      : const SizedBox(width: 200, height: 200),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]),
              const SizedBox(
                height: 40,
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: _checkPositions,
                      child: const Text('Confirm Choices'),
                    ),
                    ElevatedButton(
                      onPressed: () => widget.onNavButtonPressed(0),
                      child: const Text('Main Menu'),
                    )
                  ]),
            ]),
        Center(
          child: Text(
            resultMessage,
            style: resultMessage != 'Well Done!'
                ? const TextStyle(fontSize: 24, color: Colors.red)
                : const TextStyle(fontSize: 24, color: Colors.green),
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
