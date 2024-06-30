import 'dart:convert';
import 'dart:math';

import 'package:admin/models/user_data.dart';
import 'package:admin/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

class SelectTheAreaGame extends StatefulWidget {
  const SelectTheAreaGame({super.key});

  @override
  _CircleImageComparisonScreenState createState() =>
      _CircleImageComparisonScreenState();
}

class _CircleImageComparisonScreenState extends State<SelectTheAreaGame> {
  Offset? _startPoint;
  Offset? _endPoint;
  bool _isDrawing = false;
  bool _isVisible = false;
  bool _isEnabled = false;
  double imageVisibility = 0.5;

  Uint8List imageBytes = Uint8List(0);
  Uint8List maskImageBytes = Uint8List(0);
  Uint8List cmappedMaskImageBytes = Uint8List(0);

  late img.Image? fullImage;
  late img.Image? maskImage;
  late img.Image? cmappedMaskImage;

  late Image displayedFullImage;
  late Image displayedCmappedMaskImage;

  Map<int, int> pixelCount = <int, int>{};

  User myuser = UserManager.instance.user;

//   color_map = {
//     0: (0, 0, 0),      # Unknown
//     1: (0, 0, 255),    # Carcinoma
//     2: (255, 0, 0),    # Necrosis
//     3: (0, 255, 0),    # Tumor Stroma
//     4: (0, 255, 255),  # Others
//  }

  @override
  void initState() {
    super.initState();

    _loadImages();
  }

  void _getPixelsTypeCount() {
    for (int x = 0; x < maskImage!.width; x++) {
      for (int y = 0; y < maskImage!.height; y++) {
        int pixelValue = maskImage!.getPixel(x, y);
        pixelValue = (pixelValue >> 16) & 0xFF;
        pixelCount.update(pixelValue, (int value) => value + 1,
            ifAbsent: () => 1);
      }
    }

    // Print each unique pixel value
    for (final int pixelValue in pixelCount.keys) {
      if (kDebugMode) {
        print('Total Pixel Value: $pixelValue');
        print('Total Pixel Count: ${pixelCount[pixelValue]}');
      }
    }
  }

  Future<void> _loadImages() async {
    final http.Response response = await http.get(
        Uri.parse('https://microcosm-backend.gmichele.com/get/low/random/'));

    final Map<String, dynamic> jsonImageResponse =
        jsonDecode(response.body) as Map<String, dynamic>;

    setState(() {
      imageBytes = base64Decode(jsonImageResponse['rows']![0][1] as String);
      maskImageBytes = base64Decode(jsonImageResponse['rows']![0][2] as String);
      cmappedMaskImageBytes =
          base64Decode(jsonImageResponse['rows']![0][3] as String);

      fullImage = img.decodeImage(imageBytes);
      maskImage = img.decodeImage(maskImageBytes);
      cmappedMaskImage = img.decodeImage(cmappedMaskImageBytes);

      displayedFullImage = Image.memory(
        imageBytes,
        fit: BoxFit.cover,
        width: 600,
        height: 600,
      );

      displayedCmappedMaskImage = Image.memory(
        cmappedMaskImageBytes,
        fit: BoxFit.cover,
        width: 600,
        height: 600,
      );

      // print all lenghts
      // if (kDebugMode) {
      //   print('imageBytes: ${imageBytes.length}');
      //   print('maskImageBytes: ${maskImageBytes.length}');
      //   print('cmappedMaskImageBytes: ${cmappedMaskImageBytes.length}');
      //   print('fullImage: ${fullImage.data.length}');
      //   print('maskImage: ${maskImage.data.length}');
      //   print('cmappedMaskImage: ${cmappedMaskImage.length}');
      // }

      _getPixelsTypeCount();
    });
  }

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _startPoint = details.localPosition;
      _endPoint = details.localPosition;
      _isDrawing = true;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _endPoint = details.localPosition;
    });
  }

  void _onPanEnd(DragEndDetails details) {
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

  void _comparePixels() {
    if (_startPoint == null || _endPoint == null) {
      return;
    }

    // Scaling factor to handle rendered image and mask
    final double scalingFactorX =
        maskImage!.width / displayedCmappedMaskImage.width!;
    final double scalingFactorY =
        maskImage!.height / displayedCmappedMaskImage.height!;

    // Convert screen coordinates to image coordinates
    final double centerX =
        ((_startPoint!.dx + _endPoint!.dx) / 2) * scalingFactorX;
    final double centerY =
        ((_startPoint!.dy + _endPoint!.dy) / 2) * scalingFactorY;
    final double radius = (sqrt(pow(_endPoint!.dx - _startPoint!.dx, 2) +
                pow(_endPoint!.dy - _startPoint!.dy, 2)) /
            2) *
        scalingFactorX; // Assuming uniform scaling

    if (kDebugMode) {
      print('Center: ($centerX, $centerY), Radius: $radius');
      print('Image Size: ${fullImage!.width} x ${fullImage!.height}');
      print('Mask Size: ${maskImage!.width} x ${maskImage!.height}');
      print(
          'Rendered cmapped Mask Size: ${displayedCmappedMaskImage.width} x ${displayedCmappedMaskImage.height}');
      print(
          'Rendered Image Size: ${displayedFullImage.width} x ${displayedFullImage.height}');
    }

    final Set<int> uniquePixelValues = <int>{};
    final Map<int, int> pixelCount = <int, int>{};

    for (int x = (centerX - radius).toInt();
        x <= (centerX + radius).toInt();
        x++) {
      for (int y = (centerY - radius).toInt();
          y <= (centerY + radius).toInt();
          y++) {
        if (x >= 0 && x < maskImage!.width && y >= 0 && y < maskImage!.height) {
          final double dx = x - centerX;
          final double dy = y - centerY;

          if (dx * dx + dy * dy <= radius * radius) {
            int pixelValue = maskImage!.getPixel(x, y);
            pixelValue = (pixelValue >> 16) & 0xFF;
            uniquePixelValues.add(pixelValue);
            pixelCount.update(pixelValue, (int value) => value + 1,
                ifAbsent: () => 1);
          }
        }
      }
    }

    // Print each unique pixel value
    for (final int pixelValue in uniquePixelValues) {
      if (kDebugMode) {
        print('Pixel Value in selected Area: $pixelValue');
        print('Pixel Count in selected Area: ${pixelCount[pixelValue]}');
      }
    }
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
      body: imageBytes.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: <Widget>[
                const SizedBox(height: 60),
                Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: Center(
                        child: ClipRect(
                          child: FittedBox(
                            child: GestureDetector(
                              onPanStart: _onPanStart,
                              onPanUpdate: _onPanUpdate,
                              onPanEnd: _onPanEnd,
                              child: Stack(
                                children: <Widget>[
                                  displayedFullImage,
                                  AnimatedOpacity(
                                      opacity:
                                          _isVisible ? imageVisibility : 0.0,
                                      duration:
                                          const Duration(milliseconds: 100),
                                      child: displayedCmappedMaskImage),
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
                    //Lorem Ipsum with title

                    Container(
                      height: 500,
                      width: 500,
                      child: const Text(
                        'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
                        'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. '
                        'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. '
                        'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. '
                        'Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
                        overflow: TextOverflow.visible,
                        maxLines: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                // Display bottom left button to confirm the selection
                Row(
                  children: <Widget>[
                    if (_isVisible)
                      Column(
                        children: <Widget>[
                          const Text('Image Visibility'),
                          const SizedBox(height: 10),
                          Slider(
                            value: imageVisibility,
                            onChanged: (double value) {
                              setState(() {
                                imageVisibility = value;
                              });
                            },
                          ),
                          Text(imageVisibility.toStringAsFixed(2)),
                        ],
                      ),
                    const Spacer(),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: ElevatedButton(
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
                        child: const Text('Confirm Selection'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}

class CirclePainter extends CustomPainter {
  CirclePainter(this.startPoint, this.endPoint);
  final Offset startPoint;
  final Offset endPoint;

  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = (startPoint.dx + endPoint.dx) / 2;
    final double centerY = (startPoint.dy + endPoint.dy) / 2;
    final double radius = sqrt(pow(endPoint.dx - startPoint.dx, 2) +
            pow(endPoint.dy - startPoint.dy, 2)) /
        2;

    final Paint paint = Paint()
      ..color = Colors.blue.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(centerX, centerY), radius, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
