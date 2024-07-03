import 'package:flutter/material.dart';

import '../../../constants.dart';
import '../../../utils.dart';

typedef IndexCallback = void Function(int index);

class DragAndDropGame extends StatefulWidget {
  const DragAndDropGame({
    super.key,
    required this.onUpdate,
    required this.onCompleted,
    required this.onNext,
    required this.onGameLoaded,
  });

  final IndexCallback onUpdate;
  final VoidCallback onCompleted;
  final VoidCallback onNext;
  final VoidCallback onGameLoaded;

  @override
  DragAndDropWidgetState createState() => DragAndDropWidgetState();
}

class DragAndDropWidgetState extends State<DragAndDropGame> {
  final String imageUrl =
      'https://microcosm-backend.gmichele.com/get/low/random/';

  late List<ImageUtils> images;
  String resultMessage = '';

  bool _areAllCorrect = false;
  bool _isLoading = true;
  bool _isConfirmed = false;

  final Map<int, Image?> _currentPositions = <int, Image?>{
    0: null,
    1: null,
    2: null,
    3: null
  };

  Future<void> _fetchImage() async {
    images = await loadMoreImages(imageUrl, 4);

    setState(() {
      _isLoading = false;
      widget.onGameLoaded();
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchImage();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                RichText(
                  text: TextSpan(
                    text:
                        'Drag and drop WSIs to their labels. Confirm to check your answers!',
                    style: DefaultTextStyle.of(context).style.apply(
                          fontSizeFactor: 2,
                          fontWeightDelta: 2,
                        ),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      _buildGameGrid(),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          _buildImageGrid(),
                          if (_isConfirmed)
                            Center(
                              child: AnswerWidget(
                                text: resultMessage,
                                answerColor:
                                    _areAllCorrect ? Colors.green : Colors.red,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 25),
                  child: Center(
                    child: SizedBox(
                      height: 70,
                      width: 180,
                      child: FilledButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32.0, vertical: 16.0),
                          backgroundColor: Colors.blue,
                          textStyle: const TextStyle(fontSize: 20),
                        ),
                        onPressed: _allImagesDragged() && !_isConfirmed
                            ? () {
                                _checkPositions();
                                setState(() {
                                  _isConfirmed = true;
                                });
                              }
                            : _isConfirmed
                                ? () {
                                    widget.onNext();
                                  }
                                : null,
                        child: _isConfirmed
                            ? const Text('Next',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 24, color: Colors.white))
                            : const Text(
                                'Confirm Choices',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 22, color: Colors.white),
                                overflow: TextOverflow.visible,
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
  }

  bool _allImagesDragged() {
    return _currentPositions.values
            .where((Image? element) => element != null)
            .length ==
        4;
  }

  Widget _buildGameGrid() {
    return Container(
      padding: const EdgeInsets.all(20),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueAccent, width: 5),
        borderRadius: BorderRadius.circular(10),
      ),
      height: 500,
      width: 500,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisSpacing: 8, mainAxisSpacing: 8, crossAxisCount: 2),
        itemCount: images.length,
        itemBuilder: (BuildContext context, int index) {
          return DragTarget<Image>(
            onAcceptWithDetails: (DragTargetDetails<Image?> draggableImage) {
              setState(() {
                final Image? previousData = _currentPositions[index];
                final int previousIndex = _currentPositions.keys.firstWhere(
                    (int key) => _currentPositions[key] == draggableImage.data,
                    orElse: () => -1);

                if (previousIndex != -1) {
                  _currentPositions[previousIndex] = previousData;
                }
                _currentPositions[index] = draggableImage.data;
              });
            },
            builder: (BuildContext context, List<Image?> candidateData,
                List rejectedData) {
              return Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                  color: _currentPositions[index] != null
                      ? Colors.white
                      : Colors.grey[200],
                ),
                child: _currentPositions[index] != null
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
                          color: Colors.white,
                          width: 200,
                          height: 200,
                          child: Center(
                            child: Text(
                              tissueTypes[images[index].tissueToFind]!,
                              style: const TextStyle(
                                  fontSize: 24, color: Colors.black),
                            ),
                          ),
                        ),
                        child: SizedBox(
                          width: 200,
                          height: 200,
                          child: _currentPositions[index],
                        ),
                      )
                    : Center(
                        child: Text(
                          tissueTypes[images[index].tissueToFind]!,
                          style: const TextStyle(
                              fontSize: 24, color: Colors.black),
                        ),
                      ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildImageGrid() {
    return Center(
      child: SizedBox(
        height: 400,
        width: 400,
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: images.length,
          itemBuilder: (BuildContext context, int index) {
            return Draggable<Image>(
              data: images[index].displayedFullImage,
              feedback: SizedBox(
                width: 200,
                height: 200,
                child: images[index].displayedFullImage,
              ),
              childWhenDragging: const SizedBox(width: 200, height: 200),
              onDragCompleted: () {},
              child: !_currentPositions
                      .containsValue(images[index].displayedFullImage)
                  ? SizedBox(
                      width: 200,
                      height: 200,
                      child: images[index].displayedFullImage,
                    )
                  : const SizedBox(width: 200, height: 200),
            );
          },
        ),
      ),
    );
  }

  void _checkPositions() {
    setState(() {
      widget.onCompleted();

      for (int i = 0; i < images.length; i++) {
        if (_currentPositions[i] != images[i].displayedFullImage) {
          widget.onUpdate(wrongAnswerScore);
          resultMessage = 'Wrong choices';
          return;
        }
      }
      widget.onUpdate(correctAnswerScore);
      _areAllCorrect = true;
      resultMessage = 'Well Done!';
    });
  }
}
