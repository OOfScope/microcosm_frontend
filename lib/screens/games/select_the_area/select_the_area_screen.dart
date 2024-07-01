import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

import 'package:admin/constants.dart';

import '../../../models/user_data.dart';
import '../../../utils.dart';
import 'components/circle_painter.dart';
import 'components/tissue_legend.dart';
import 'package:admin/utils.dart';

class SelectTheAreaGame extends StatefulWidget {
  const SelectTheAreaGame({super.key});

  @override
  _CircleImageComparisonScreenState createState() =>
      _CircleImageComparisonScreenState();
}

class _CircleImageComparisonScreenState extends State<SelectTheAreaGame> {
  Offset? _startPoint;
  Offset? _endPoint;

  bool _isLoading = true;
  bool _isDrawing = false;
  bool _isVisible = false;
  bool _isEnabled = false;
  bool _isConfirmed = false;

  double imageVisibility = 0.5;

  late Text _answerWidget;

  Map<int, int> pixelCount = <int, int>{};

  ImageResponse imageHandler = ImageResponse();
  User myuser = UserManager.instance.user;

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
        _isDrawing = true;
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

        _isEnabled = true;

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
    if (_startPoint == null || _endPoint == null) {
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
          _answerWidget = const Text(
            "Devi selezionare solo la parte dell'immagine in cui è presente il tessuto",
            style: TextStyle(
                color: Colors.red,
                fontSize: answerFontSize,
                fontWeight: FontWeight.bold),
            overflow: TextOverflow.visible,
          );
        });
        _isConfirmed = true;
        return;
      }

      // if number of pixel of correct tissue is less than 50% of the total correct tissue pixels
      if (pixelCount[imageHandler.tissueToFind]! <
          0.5 *
              imageHandler.totalTissuePixelFound[imageHandler.tissueToFind]!) {
        setState(() {
          _answerWidget = const Text(
            'Non hai individuato tutto il tessuto corretto',
            style: TextStyle(
                color: Colors.red,
                fontSize: answerFontSize,
                fontWeight: FontWeight.bold),
            overflow: TextOverflow.visible,
          );
        });
        _isConfirmed = true;
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
        _answerWidget = const Text(
          'Hai individuato correttamente il tessuto!',
          style: TextStyle(
              color: Colors.green,
              fontSize: answerFontSize,
              fontWeight: FontWeight.bold),
          overflow: TextOverflow.visible,
        );
        _isConfirmed = true;
      });
    } else {
      setState(() {
        _answerWidget = const Text(
          'Non hai individuato il tessuto corretto',
          style: TextStyle(
              color: Colors.red,
              fontSize: answerFontSize,
              fontWeight: FontWeight.bold),
          overflow: TextOverflow.visible,
        );
        _isConfirmed = true;
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
    _comparePixels();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Circle Area Comparison'),
      ),
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
                                color: Colors
                                    .white, // Change to your desired highlight color
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
                                          _isVisible ? imageVisibility : 0.0,
                                      duration:
                                          const Duration(milliseconds: 100),
                                      child: imageHandler
                                          .displayedCmappedMaskImage),
                                  if (_isDrawing &&
                                      _startPoint != null &&
                                      _endPoint != null)
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
                              height: 200,
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
                            if (_isConfirmed)
                              SizedBox(
                                  width: 550,
                                  height: 100,
                                  child: _answerWidget),

                            Row(
                              children: <Widget>[
                                if (_isVisible)
                                  TissueTypeLegend(
                                      totalTissuePixelFound:
                                          imageHandler.totalTissuePixelFound)
                              ],
                            )
                          ],
                        ),
                      ],
                    )
                  ],
                ),
                // Display bottom left button to confirm the selection
                Row(
                  children: <Widget>[
                    const Spacer(),
                    if (_isConfirmed)
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Row(
                            children: [
                              Text(
                                'Mask Transparency: ',
                                style: DefaultTextStyle.of(context).style.apply(
                                      fontSizeFactor: 1.5,
                                    ),
                              ),
                              Text(
                                imageVisibility.toStringAsFixed(2),
                                style: DefaultTextStyle.of(context).style.apply(
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
                        padding: const EdgeInsets.only(left: 70, right: 50),
                        child: SizedBox(
                          height: 60,
                          width: 170,
                          child: FilledButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  _isEnabled ? Colors.blue : Colors.grey),
                            ),
                            onPressed: _isEnabled
                                ? () {
                                    setState(() {
                                      if (!_isVisible &&
                                          _startPoint != null &&
                                          _endPoint != null &&
                                          _isDrawing) {
                                        _isVisible = true;
                                        checkAnswer();
                                      }
                                    });
                                  }
                                : null,
                            child: const Text('Confirm Selection',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 17, color: Colors.white)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
