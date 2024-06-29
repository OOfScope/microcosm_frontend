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
  // bool _isSecondClick = false;
  Uint8List imageBytes = Uint8List(0);
  Uint8List maskImageBytes = Uint8List(0);
  Uint8List cmappedMaskImageBytes = Uint8List(0);
  Image? fullImage;
  Image? maskImage;
  Image? cmappedMaskImage;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    final http.Response response = await http.get(
        Uri.parse('https://microcosm-backend.gmichele.com/get/high/random/'));

    final Map<String, dynamic> jsonImageResponse =
        jsonDecode(response.body) as Map<String, dynamic>;

    setState(() {
      imageBytes = base64Decode(jsonImageResponse['rows']![0][1] as String);
      maskImageBytes = base64Decode(jsonImageResponse['rows']![0][2] as String);
      cmappedMaskImageBytes =
          base64Decode(jsonImageResponse['rows']![0][3] as String);
      fullImage = Image.memory(
        imageBytes,
        height: 4096,
        width: 4096,
      );
      maskImage = Image.memory(maskImageBytes, height: 4096, width: 4096);
      cmappedMaskImage =
          Image.memory(cmappedMaskImageBytes, height: 4096, width: 4096);
    });
  }

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _isDrawing = true;
      _startPoint = details.localPosition;
      _endPoint = details.localPosition;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _endPoint = details.localPosition;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      if (fullImage != null && maskImage != null) {
        try {
          _comparePixels();
        } catch (e) {
          if (kDebugMode) {
            print('Error: $e');
          }
        }
      }
    });
  }

  void _comparePixels() {
    if (_startPoint == null || _endPoint == null) {
      return;
    }

    final double centerX = (_startPoint!.dx + _endPoint!.dx) / 2;
    final double centerY = (_startPoint!.dy + _endPoint!.dy) / 2;
    final double radius = sqrt(pow(_endPoint!.dx - _startPoint!.dx, 2) +
            pow(_endPoint!.dy - _startPoint!.dy, 2)) /
        2;

    if (kDebugMode) {
      print('Center: ($centerX, $centerY), Radius: $radius');
      print('Image Size: ${fullImage!.width} x ${fullImage!.height}');
      print('Mask Size: ${maskImage!.width} x ${maskImage!.height}');
    }

    final Set<int> uniquePixelValues = <int>{};

    for (int x = (centerX - radius).toInt();
        x <= (centerX + radius).toInt();
        x++) {
      for (int y = (centerY - radius).toInt();
          y <= (centerY + radius).toInt();
          y++) {
        if (x >= 0 &&
            x < fullImage!.width! &&
            y >= 0 &&
            y < fullImage!.height!) {
          final double dx = x - centerX;
          final double dy = y - centerY;

          if (dx * dx + dy * dy <= radius * radius) {
            //final int pixelValue =maskImage?[y * fullImage!.width!.toInt() + x];
            //uniquePixelValues.add(pixelValue);
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

    // Reset the points after calculation
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Circle Area Comparison'),
      ),
      body: imageBytes.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ClipRect(
                child: FittedBox(
                  child: GestureDetector(
                    onPanStart: _onPanStart,
                    onPanUpdate: _onPanUpdate,
                    onPanEnd: _onPanEnd,
                    child: Stack(
                      children: <Widget>[
                        Image.memory(
                          imageBytes,
                          fit: BoxFit.cover,
                          width: 600,
                          height: 600,
                        ),
                        if (_isDrawing &&
                            _startPoint != null &&
                            _endPoint != null)
                          CustomPaint(
                            painter: CirclePainter(_startPoint!, _endPoint!),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
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
