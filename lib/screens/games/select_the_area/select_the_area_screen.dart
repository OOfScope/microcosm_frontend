import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

import '../../../constants.dart';
import '../../../models/user_data.dart';
import '../../../utils.dart';
import 'components/answer_widget.dart';
import 'components/circle_painter.dart';
import 'components/tissue_legend.dart';

class SelectTheAreaGame extends StatefulWidget {
  const SelectTheAreaGame(
      {super.key,
      required this.onUpdate,
      required this.onCompleted,
      required this.onNext});

  final ValueChanged<int> onUpdate;
  final VoidCallback onCompleted;
  final VoidCallback onNext;

  @override
  CircleImageComparisonScreenState createState() =>
      CircleImageComparisonScreenState();
}

class CircleImageComparisonScreenState extends State<SelectTheAreaGame> {
  Offset? _startPoint;
  Offset? _endPoint;

  bool _isLoading = true;
  bool _isEnabled = false;
  bool _isConfirmed = false;
  bool _isCompleted = false;

  double imageVisibility = 0.5;

  late AnswerWidget _answer;

  Map<int, int> pixelCount = <int, int>{};

  ImageResponse imageHandler = ImageResponse();

  @override
  void initState() {
    super.initState();
    _loadWSI();
  }

  Future<void> _loadWSI() async {
    await imageHandler
        .loadImages('https://microcosm-backend.gmichele.com/get/low/random/');
    setState(() {
      _isLoading = false;
    });
  }

  void _onPanStart(DragStartDetails details) {
    setState(() {
      if (!_isConfirmed) {
        _startPoint = details.localPosition;
        _endPoint = details.localPosition;
      }
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      if (!_isConfirmed) {
        _endPoint = details.localPosition;
      }
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (!_isConfirmed) {
      setState(() {
        if (_isEnabled) {
          _comparePixels();
        }
        if (_startPoint != null && _endPoint != null) {
          _isEnabled = true;
        }

        // try {
        //   _comparePixels();
        // } catch (e) {
        //   if (kDebugMode) {
        //     print('Error: $e');
        //   }
        // }
      });
    }
  }

  void _comparePixels() {
    if (_startPoint == null || _endPoint == null || !_isConfirmed) {
      return;
    }

    // Scaling factor to handle rendered image and mask
    final double scalingFactorX = imageHandler.maskImage!.width /
        imageHandler.displayedCmappedMaskImage.width!;
    final double scalingFactorY = imageHandler.maskImage!.height /
        imageHandler.displayedCmappedMaskImage.height!;

    // Convert screen coordinates to image coordinates
    final double centerX =
        ((_startPoint!.dx + _endPoint!.dx) / 2) * scalingFactorX;
    final double centerY =
        ((_startPoint!.dy + _endPoint!.dy) / 2) * scalingFactorY;
    final double radius = (sqrt(pow(_endPoint!.dx - _startPoint!.dx, 2) +
                pow(_endPoint!.dy - _startPoint!.dy, 2)) /
            2) *
        scalingFactorX; // Assuming uniform scaling

    // if (kDebugMode) {
    //   print('Center: ($centerX, $centerY), Radius: $radius');
    //   print('Image Size: ${fullImage!.width} x ${fullImage!.height}');
    //   print('Mask Size: ${maskImage!.width} x ${maskImage!.height}');
    //   print(
    //       'Rendered cmapped Mask Size: ${displayedCmappedMaskImage.width} x ${displayedCmappedMaskImage.height}');
    //   print(
    //       'Rendered Image Size: ${displayedFullImage.width} x ${displayedFullImage.height}');
    // }

    final Set<int> uniquePixelValues = <int>{};
    final Map<int, int> pixelCount = <int, int>{};

    for (int x = (centerX - radius).toInt();
        x <= (centerX + radius).toInt();
        x++) {
      for (int y = (centerY - radius).toInt();
          y <= (centerY + radius).toInt();
          y++) {
        if (x >= 0 &&
            x < imageHandler.maskImage!.width &&
            y >= 0 &&
            y < imageHandler.maskImage!.height) {
          final double dx = x - centerX;
          final double dy = y - centerY;

          if (dx * dx + dy * dy <= radius * radius) {
            final img.Pixel pixelValue = imageHandler.maskImage!.getPixel(x, y);
            uniquePixelValues.add(pixelValue.r as int);
            pixelCount.update(pixelValue.r as int, (int value) => value + 1,
                ifAbsent: () => 1);
          }
        }
      }
    }

    // if tissueToFind is in pixelCount
    if (pixelCount.containsKey(imageHandler.tissueToFind)) {
      // sum the total number of pixels in image
      double totalCoveredPixels = 0;
      for (final int pixelValue in pixelCount.keys) {
        totalCoveredPixels += pixelCount[pixelValue]!;
      }

      // if selected pixels cover the whole image area
      final double coveredArea = totalCoveredPixels /
          (imageHandler.maskImage!.width * imageHandler.maskImage!.height);

      if (coveredArea > 0.7) {
        setState(() {
          _answer = const AnswerWidget(
            text:
                'You must select only the part of the image where the tissue is present',
            answerColor: Colors.red,
          );
          widget.onUpdate(10);
        });

        return;
      }

      // if number of pixel of correct tissue is less than 50% of the total correct tissue pixels

      if (pixelCount[imageHandler.tissueToFind]! <
          0.5 *
              imageHandler.totalTissuePixelFound[imageHandler.tissueToFind]!) {
        setState(() {
          _answer = const AnswerWidget(
            text: 'You have not identified all the correct tissue',
            answerColor: Colors.red,
          );
          widget.onUpdate(10);
        });

        return;
      }

      if (kDebugMode) {
        print('Tissue Name: ${tissueTypes[imageHandler.tissueToFind]}');
        print(
            'Total Pixel Count: ${imageHandler.totalTissuePixelFound[imageHandler.tissueToFind]}');
        print(
            'Pixel Count in selected Area: ${pixelCount[imageHandler.tissueToFind]}');
        print('Covered Area: $coveredArea');
        print(
            'Total Area: ${imageHandler.maskImage!.width * imageHandler.maskImage!.height}');
        print('Covered Pixels: $totalCoveredPixels');
      }

      setState(() {
        _answer = const AnswerWidget(
          text: 'You have correctly identified the tissue!',
          answerColor: Colors.green,
        );

        widget.onUpdate(10);
      });
    } else {
      setState(() {
        _answer = const AnswerWidget(
          text: 'You have not identified the correct tissue!',
          answerColor: Colors.red,
        );

        widget.onUpdate(10);
      });
    }

    // Print each unique pixel value
    // for (final int pixelValue in uniquePixelValues) {
    //   if (kDebugMode) {
    //     print('Pixel Value in selected Area: $pixelValue');
    //     print('Pixel Count in selected Area: ${pixelCount[pixelValue]}');
    //   }
    // }
  }

  void checkAnswer() {
    _isCompleted = true;
    widget.onCompleted();
    _comparePixels();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading ||
              imageHandler.imageBytes.isEmpty ||
              imageHandler.tissueToFind == 0
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: <Widget>[
                Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 20),
                    child: RichText(
                      text: TextSpan(
                        text: 'Find the ',
                        style: DefaultTextStyle.of(context).style.apply(
                              fontSizeFactor: 2.5,
                            ),
                        children: <InlineSpan>[
                          WidgetSpan(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4.0, vertical: 2.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                tissueTypes[imageHandler.tissueToFind]!,
                                style: DefaultTextStyle.of(context).style.apply(
                                      fontSizeFactor: 2.5,
                                      color: Colors.black,
                                      fontWeightDelta: 2,
                                    ),
                              ),
                            ),
                          ),
                          TextSpan(
                            text: ' Tissue!',
                            style: DefaultTextStyle.of(context)
                                .style
                                .apply(fontSizeFactor: 2.5),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 50, right: 20),
                      child: Center(
                        child: ClipRect(
                          child: FittedBox(
                            child: GestureDetector(
                              onPanStart: _onPanStart,
                              onPanUpdate: _onPanUpdate,
                              onPanEnd: _onPanEnd,
                              child: Stack(
                                children: <Widget>[
                                  imageHandler.displayedFullImage,
                                  AnimatedOpacity(
                                      opacity:
                                          _isConfirmed ? imageVisibility : 0.0,
                                      duration:
                                          const Duration(milliseconds: 100),
                                      child: imageHandler
                                          .displayedCmappedMaskImage),
                                  if (_startPoint != null && _endPoint != null)
                                    CustomPaint(
                                      painter: CirclePainter(
                                          _startPoint!, _endPoint!),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            Container(
                              alignment: Alignment.center,
                              height: 150,
                              width: 550,
                              child: Text(
                                tissueDescription[imageHandler.tissueToFind]!,
                                style: const TextStyle(
                                  fontSize: tissueDescriptionFontSize,
                                  overflow: TextOverflow.visible,
                                ),
                                maxLines: 20,
                              ),
                            ),
                            const SizedBox(
                              height: 100,
                            ),

                            // Display answer
                            if (!_isConfirmed)
                              Container(
                                height: 65 *
                                    (1 +
                                        imageHandler
                                            .totalTissuePixelFound.length
                                            .toDouble()),
                              )
                            else
                              SizedBox(width: 550, height: 100, child: _answer),

                            Row(
                              children: <Widget>[
                                if (_isConfirmed)
                                  TissueTypeLegend(
                                      totalTissuePixelFound:
                                          imageHandler.totalTissuePixelFound)
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                if (_isConfirmed)
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Row(
                                        children: [
                                          Text(
                                            'Mask Transparency: ',
                                            style: DefaultTextStyle.of(context)
                                                .style
                                                .apply(
                                                  fontSizeFactor: 1.5,
                                                ),
                                          ),
                                          Text(
                                            imageVisibility.toStringAsFixed(2),
                                            style: DefaultTextStyle.of(context)
                                                .style
                                                .apply(
                                                  fontSizeFactor: 1.5,
                                                ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Slider(
                                        value: imageVisibility,
                                        onChanged: (double value) {
                                          setState(() {
                                            imageVisibility = value;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 70, right: 50),
                                    child: SizedBox(
                                      height: 60,
                                      width: 170,
                                      child: FilledButton(
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  _isEnabled
                                                      ? Colors.blue
                                                      : Colors.grey),
                                        ),
                                        onPressed: _isEnabled
                                            ? () {
                                                setState(() {
                                                  if (!_isConfirmed &&
                                                      _startPoint != null &&
                                                      _endPoint != null) {
                                                    _isConfirmed = true;
                                                    checkAnswer();
                                                    return;
                                                  }

                                                  if (_isCompleted) {
                                                    widget.onNext();
                                                  }
                                                });
                                              }
                                            : null,
                                        child: Text(
                                            _isCompleted
                                                ? 'Next'
                                                : 'Confirm Selection',
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                                fontSize: 17,
                                                color: Colors.white)),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
                // Display bottom left button to confirm the selection
              ],
            ),
    );
  }
}
