import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

void main() => runApp(const SelectTheAreaGame());

class SelectTheAreaGame extends StatelessWidget {
  const SelectTheAreaGame({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: CircleImageComparisonScreen(),
    );
  }
}

class CircleImageComparisonScreen extends StatefulWidget {
  const CircleImageComparisonScreen({super.key});

  @override
  _CircleImageComparisonScreenState createState() =>
      _CircleImageComparisonScreenState();
}

class _CircleImageComparisonScreenState
    extends State<CircleImageComparisonScreen> {
  Offset? _startPoint;
  Offset? _endPoint;
  bool _isDrawing = false;
  bool _isVisible = false;
  double imageVisibility = 0.5;

  Uint8List imageBytes = Uint8List(0);
  Uint8List maskImageBytes = Uint8List(0);
  Uint8List cmappedMaskImageBytes = Uint8List(0);

  late img.Image fullImage;
  late img.Image maskImage;
  late img.Image cmappedMaskImage;

  late Image renderedFullImage;
  late Image renderedCmappedMaskImage;

  @override
  void initState() {
    super.initState();

    _loadImages();
  }

  Future<void> _loadImages() async {
    final http.Response response = await http.get(
        Uri.parse('https://microcosm-backend.gmichele.com/get/low/random/'));

    final Map<String, dynamic> jsonImageResponse =
        jsonDecode(response.body) as Map<String, dynamic>;

    setState(() {
      const int imageLenght = 600;

      imageBytes = base64Decode(jsonImageResponse['rows']![0][1] as String);
      maskImageBytes = base64Decode(jsonImageResponse['rows']![0][2] as String);
      cmappedMaskImageBytes =
          base64Decode(jsonImageResponse['rows']![0][3] as String);

      fullImage = img.Image.fromBytes(imageLenght, imageLenght, imageBytes);
      maskImage = img.Image.fromBytes(imageLenght, imageLenght, maskImageBytes);
      cmappedMaskImage =
          img.Image.fromBytes(imageLenght, imageLenght, cmappedMaskImageBytes);

      renderedFullImage = Image.memory(
        imageBytes,
        fit: BoxFit.cover,
        width: 600,
        height: 600,
      );

      renderedCmappedMaskImage = Image.memory(
        cmappedMaskImageBytes,
        fit: BoxFit.cover,
        width: 600,
        height: 600,
      );

      // print all lenghts
      if (kDebugMode) {
        print('imageBytes: ${imageBytes.length}');
        print('maskImageBytes: ${maskImageBytes.length}');
        print('cmappedMaskImageBytes: ${cmappedMaskImageBytes.length}');
        print('fullImage: ${fullImage.length}');
        print('maskImage: ${maskImage.length}');
        print('cmappedMaskImage: ${cmappedMaskImage.length}');
      }
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
      try {
        _comparePixels();
      } catch (e) {
        if (kDebugMode) {
          print('Error: $e');
        }
      }
    });
  }

  void _comparePixels() {
    if (_startPoint == null || _endPoint == null) {
      return;
    }

    const double displayedImageWidth =
        600; // Adjust based on your displayed image size
    const double displayedImageHeight =
        600; // Adjust based on your displayed image size

    // Calculate the scale factor
    final double scaleX = maskImage.length / displayedImageWidth;
    final double scaleY = maskImage.length / displayedImageHeight;

    // Convert screen coordinates to image coordinates
    final double centerX = ((_startPoint!.dx + _endPoint!.dx) / 2) * scaleX;
    final double centerY = ((_startPoint!.dy + _endPoint!.dy) / 2) * scaleY;
    final double radius = (sqrt(pow(_endPoint!.dx - _startPoint!.dx, 2) +
                pow(_endPoint!.dy - _startPoint!.dy, 2)) /
            2) *
        scaleX; // Assuming uniform scaling

    if (kDebugMode) {
      print('Center: ($centerX, $centerY), Radius: $radius');
      print('Image Size: ${fullImage.width} x ${fullImage.height}');
      print('Mask Size: ${maskImage.width} x ${maskImage.height}');
    }

    final Set<int> uniquePixelValues = <int>{};

    for (int x = (centerX - radius).toInt();
        x <= (centerX + radius).toInt();
        x++) {
      for (int y = (centerY - radius).toInt();
          y <= (centerY + radius).toInt();
          y++) {
        if (x >= 0 && x < maskImage.width && y >= 0 && y < maskImage.height) {
          final double dx = x - centerX;
          final double dy = y - centerY;

          if (dx * dx + dy * dy <= radius * radius) {
            final int pixelValue = maskImage.getPixel(x, y);
            uniquePixelValues.add(pixelValue);
          }
        }
      }
    }

    // Print each unique pixel value
    for (final int pixelValue in uniquePixelValues) {
      if (kDebugMode) {
        print('Pixel Value: $pixelValue');
      }
    }

    setState(() {
      _isVisible = true;
    });

    // Reset the points after calculation
    _startPoint = null;
    _endPoint = null;
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
                if (_isVisible)
                  Slider(
                    value: imageVisibility,
                    onChanged: (double value) {
                      setState(() {
                        imageVisibility = value;
                      });
                    },
                  ),
                const SizedBox(height: 30),
                Center(
                  child: ClipRect(
                    child: FittedBox(
                      child: GestureDetector(
                        onPanStart: _onPanStart,
                        onPanUpdate: _onPanUpdate,
                        onPanEnd: _onPanEnd,
                        child: Stack(
                          children: <Widget>[
                            renderedFullImage,
                            AnimatedOpacity(
                                opacity: _isVisible ? imageVisibility : 0.0,
                                duration: const Duration(milliseconds: 100),
                                child: renderedCmappedMaskImage),
                            if (_isDrawing &&
                                _startPoint != null &&
                                _endPoint != null)
                              CustomPaint(
                                painter:
                                    CirclePainter(_startPoint!, _endPoint!),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                // Display bottom left button to confirm the selection

                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      // TO DO: Implement the logic to check if the selected area is correct
                      if (!_isVisible &&
                          _startPoint != null &&
                          _endPoint != null &&
                          _isDrawing) {
                        _isVisible = true;
                      }
                    });
                  },
                  child: const Text('Confirm Selection'),
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
