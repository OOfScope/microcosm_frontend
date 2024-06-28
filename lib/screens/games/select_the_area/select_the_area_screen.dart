import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

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
  Uint8List _image1Bytes = Uint8List(0);
  Uint8List _image2Bytes = Uint8List(0);
  img.Image? _image1;
  img.Image? _image2;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    final http.Response response1 = await http
        .get(Uri.parse('https://microcosm-backend.gmichele.com/1/image'));
    final http.Response response2 = await http
        .get(Uri.parse('https://microcosm-backend.gmichele.com/1/mask'));

    final data1 = jsonDecode(response1.body) as Map<String, String>;
    final Map<String, String> data2 =
        jsonDecode(response2.body) as Map<String, String>;

    setState(() {
      _image1Bytes = base64Decode(data1['rows']![0][0]);
      _image2Bytes = base64Decode(data2['rows']![0][0]);
      _image1 = img.decodeImage(_image1Bytes);
      _image2 = img.decodeImage(_image2Bytes);
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
      if (_image1 != null && _image2 != null) {
        _comparePixels();
      }
    });
  }

  void _comparePixels() {
    if (_startPoint == null || _endPoint == null) return;

    final double centerX = (_startPoint!.dx + _endPoint!.dx) / 2;
    final double centerY = (_startPoint!.dy + _endPoint!.dy) / 2;
    final double radius = sqrt(pow(_endPoint!.dx - _startPoint!.dx, 2) +
            pow(_endPoint!.dy - _startPoint!.dy, 2)) /
        2;

    final Set<int> uniquePixelValues = <int>{};

    for (int x = (centerX - radius).toInt();
        x <= (centerX + radius).toInt();
        x++) {
      for (int y = (centerY - radius).toInt();
          y <= (centerY + radius).toInt();
          y++) {
        if (x >= 0 && x < _image1!.width && y >= 0 && y < _image1!.height) {
          final double dx = x - centerX;
          final double dy = y - centerY;
          if (dx * dx + dy * dy <= radius * radius) {
            final int pixelValue = _image2!.getPixel(x, y);
            uniquePixelValues.add(pixelValue);
          }
        }
      }
    }

    // Print each unique pixel value
    for (final int pixelValue in uniquePixelValues) {
      print('Pixel Value: $pixelValue');
    }

    // Reset the points after calculation
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Circle Area Comparison'),
      ),
      body: _image1Bytes.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ClipRect(
                child: FittedBox(
                  child: Container(
                    child: GestureDetector(
                      onPanStart: _onPanStart,
                      onPanUpdate: _onPanUpdate,
                      onPanEnd: _onPanEnd,
                      child: Stack(
                        children: <Widget>[
                          Image.memory(
                            _image1Bytes,
                            fit: BoxFit.cover,
                            width: 750,
                            height: 750,
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
