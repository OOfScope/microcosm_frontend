import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:math';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'dart:convert';

void main() => runApp(SelectTheAreaGame());

class SelectTheAreaGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CircleImageComparisonScreen(),
    );
  }
}

class CircleImageComparisonScreen extends StatefulWidget {
  @override
  _CircleImageComparisonScreenState createState() =>
      _CircleImageComparisonScreenState();
}

class _CircleImageComparisonScreenState
    extends State<CircleImageComparisonScreen> {
  Offset? _startPoint;
  Offset? _endPoint;
  bool _isDrawing = false;
  bool _isSecondClick = false;
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
    final response1 = await http
        .get(Uri.parse('https://microcosm-backend.gmichele.com/1/image'));
    final response2 = await http
        .get(Uri.parse('https://microcosm-backend.gmichele.com/1/mask'));

    final data1 = jsonDecode(response1.body);
    final data2 = jsonDecode(response2.body);

    setState(() {
      _image1Bytes = base64Decode(data1['rows'][0][0]);
      _image2Bytes = base64Decode(data2['rows'][0][0]);
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

    double centerX = (_startPoint!.dx + _endPoint!.dx) / 2;
    double centerY = (_startPoint!.dy + _endPoint!.dy) / 2;
    double radius = sqrt(pow(_endPoint!.dx - _startPoint!.dx, 2) +
            pow(_endPoint!.dy - _startPoint!.dy, 2)) /
        2;

    Set<int> uniquePixelValues = {};

    for (int x = (centerX - radius).toInt();
        x <= (centerX + radius).toInt();
        x++) {
      for (int y = (centerY - radius).toInt();
          y <= (centerY + radius).toInt();
          y++) {
        if (x >= 0 && x < _image1!.width && y >= 0 && y < _image1!.height) {
          double dx = x - centerX;
          double dy = y - centerY;
          if (dx * dx + dy * dy <= radius * radius) {
            int pixelValue = _image2!.getPixel(x, y);
            uniquePixelValues.add(pixelValue);
          }
        }
      }
    }

    // Print each unique pixel value
    uniquePixelValues.forEach((pixelValue) {
      print('Pixel Value: $pixelValue');
    });

    // Reset the points after calculation
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Circle Area Comparison'),
      ),
      body: _image1Bytes.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Center(
              child: ClipRect(
                child: FittedBox(
                  child: Container(
                    child: GestureDetector(
                      onPanStart: _onPanStart,
                      onPanUpdate: _onPanUpdate,
                      onPanEnd: _onPanEnd,
                      child: Stack(
                        children: [
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
  final Offset startPoint;
  final Offset endPoint;

  CirclePainter(this.startPoint, this.endPoint);

  @override
  void paint(Canvas canvas, Size size) {
    double centerX = (startPoint.dx + endPoint.dx) / 2;
    double centerY = (startPoint.dy + endPoint.dy) / 2;
    double radius = sqrt(pow(endPoint.dx - startPoint.dx, 2) +
            pow(endPoint.dy - startPoint.dy, 2)) /
        2;

    Paint paint = Paint()
      ..color = Colors.blue.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(centerX, centerY), radius, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
