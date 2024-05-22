import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class Owly extends StatelessWidget {
  var bb;
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SelectionModel(),
      child: MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: Text('Image Selection')),
          body: ImageSelectionWidget(
            imageUrl: 'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg',
            onSelectionComplete: (Rect value) { print(value); },
          ),
        ),
      ),
    );
  }
}



class ImageSelectionWidget extends StatelessWidget {
  final String imageUrl;
  final ValueChanged<Rect> onSelectionComplete;

  ImageSelectionWidget({
    required this.imageUrl,
    required this.onSelectionComplete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        Provider.of<SelectionModel>(context, listen: false)
            .startSelection(details.localPosition);
      },
      onPanUpdate: (details) {
        Provider.of<SelectionModel>(context, listen: false)
            .updateSelection(details.localPosition);
      },
      onPanEnd: (details) {
        final selectionModel =
            Provider.of<SelectionModel>(context, listen: false);
        selectionModel.endSelection();
        if (onSelectionComplete != null) {
          final boundingBox = selectionModel.boundingBox;
          onSelectionComplete(boundingBox);
        }
      },
      child: Stack(
        children: [
          Center(
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
            ),
          ),
          Consumer<SelectionModel>(
            builder: (context, selectionModel, child) {
              return CustomPaint(
                painter: SelectionPainter(
                    selectionModel.start, selectionModel.end, selectionModel.points),
              );
            },
          ),
        ],
      ),
    );
  }
}

class SelectionPainter extends CustomPainter {
  final Offset start;
  final Offset end;
  final List<Offset> points;

  SelectionPainter(this.start, this.end, this.points);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawPoints(PointMode.polygon, points, paint);

    if (start != null && end != null) {
      final rectPaint = Paint()
        ..color = Colors.blue.withOpacity(0.3)
        ..style = PaintingStyle.fill;

      final rect = Rect.fromPoints(start, end);
      canvas.drawRect(rect, rectPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class SelectionModel extends ChangeNotifier {
  late Offset _start;
  late Offset _end;
  List<Offset> _points = [];

  void startSelection(Offset position) {
    _start = position;
    _end = position;
    _points = [position];
    notifyListeners();
  }

  void updateSelection(Offset position) {
    _end = position;
    _points.add(position);
    notifyListeners();
  }

  void endSelection() {
    notifyListeners();
  }

  Offset get start => _start;
  Offset get end => _end;
  List<Offset> get points => _points;

  Rect get boundingBox {
    if (_start == null || _end == null) {
      return Rect.zero;
    }
    return Rect.fromPoints(_start, _end);
  }
}