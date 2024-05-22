import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class Owly extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SelectionModel(),
      child: MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: Text('Image Selection')),
          body: ImageSelectionWidget(
            imageUrl: 'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg',
          ),
        ),
      ),
    );
  }
}



class ImageSelectionWidget extends StatefulWidget {
  final String imageUrl;

  ImageSelectionWidget({required this.imageUrl});

  @override
  _ImageSelectionWidgetState createState() => _ImageSelectionWidgetState();
}

class _ImageSelectionWidgetState extends State<ImageSelectionWidget> {
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
        Provider.of<SelectionModel>(context, listen: false).endSelection();
      },
      child: Stack(
        children: [
          Center(
            child: Image.network(
              widget.imageUrl,
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
  final Offset? start;
  final Offset? end;
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

      final rect = Rect.fromPoints(start!, end!);
      canvas.drawRect(rect, rectPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class SelectionModel extends ChangeNotifier {
  Offset? _start;
  Offset? _end;
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

  Offset? get start => _start;
  Offset? get end => _end;
  List<Offset> get points => _points;
}