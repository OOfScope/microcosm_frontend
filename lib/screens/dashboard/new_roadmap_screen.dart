import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../utils.dart';
import '../main/components/header.dart';
import 'components/dashed_line_painter.dart';
import 'components/level_button.dart';

class Roadmap extends StatefulWidget {
  const Roadmap({super.key, required this.onLevelButtonPressed});
  final void Function(int level, int difficulty) onLevelButtonPressed;

  @override
  RoadmapState createState() => RoadmapState();
}

class RoadmapState extends State<Roadmap> {
  final List<LevelButton> _levelButtons =
      LevelButtonManager.instance.levelButtons;
  @override
  void initState() {
    super.initState();
    setOnTapMethod(_levelButtons, widget.onLevelButtonPressed);
  }

  @override
  Widget build(BuildContext context) {
    const String assetPath = kDebugMode ? '/images' : '/assets/images';

    final List<Widget> levels = <Widget>[
      _buildLevelPath(1, 5),
      _buildLevelPath(6, 10),
      _buildLevelPath(11, 15),
      _buildLevelPath(16, 20),
      _buildLevelPath(21, 25),
      _buildLevelPath(26, 30),
      _buildLevelPath(31, 35),
      _buildLevelPath(36, 40),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Header(title: 'Roadmap'),
      ),
      body: Stack(
        children: <Widget>[
          Opacity(
            opacity: 0.5,
            child: Image.asset(
              '$assetPath/improved_rm.jpeg',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              scale: 2,
            ),
          ),
          SingleChildScrollView(
            child: Column(
              children: levels,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelPath(int startLevel, int endLevel) {
    final List<Widget> rows = <Widget>[];

    for (int i = startLevel; i <= endLevel; i += 4) {
      final int levelsInRow = min(4, endLevel - i + 1);
      final List<Widget> rowChildren = <Widget>[];

      for (int j = i; j < i + levelsInRow; j++) {
        final int currentLevel = j;
        rowChildren.add(
          Expanded(
            child: Column(
              children: <Widget>[
                _levelButtons[currentLevel - 1],
                if (currentLevel < endLevel && j < i + levelsInRow)
                  SizedBox(
                    width: 60,
                    child: CustomPaint(
                      painter: DashedLinePainter(
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      }

      rows.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: rowChildren,
      ));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Column(
        children: rows,
      ),
    );
  }
}
