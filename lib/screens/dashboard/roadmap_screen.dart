import 'package:flutter/material.dart';
import 'package:game_levels_scrolling_map/game_levels_scrolling_map.dart';
import 'package:game_levels_scrolling_map/model/point_model.dart';

typedef IndexCallback = void Function(int index);

class RoadmapScreen extends StatefulWidget {

  const RoadmapScreen({super.key, required this.onNavButtonPressed});
  final IndexCallback onNavButtonPressed;

  @override
  State<RoadmapScreen> createState() => _RoadmapScreenState();
}

class _RoadmapScreenState extends State<RoadmapScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          child: GameLevelsScrollingMap.scrollable(
        imageUrl: 'assets/images/map_vertical.png',
        direction: Axis.vertical,
        reverseScrolling: true,
        pointsPositionDeltaX: 25,
        pointsPositionDeltaY: 25,
        svgUrl: 'assets/images/map_vertical.svg',
        points: points,
      )), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  @override
  void initState() {
    super.initState();
    fillTestData();
  }

  List<PointModel> points = <PointModel>[];

  void fillTestData() {
    for (int i = 0; i < 100; i++) {
      points.add(PointModel(100, testWidget(i)));
    }
  }

  Widget testWidget(int order) {
    return InkWell(
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Image.asset(
            'assets/images/map_vertical_point.png',
            fit: BoxFit.fitWidth,
            width: 50,
          ),
          Text('$order',
              style: const TextStyle(color: Colors.black, fontSize: 15))
        ],
      ),
      onTap: () => widget.onNavButtonPressed(3),
    );
  }
}
