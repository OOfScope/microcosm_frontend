import 'package:flutter/material.dart';
import 'package:game_levels_scrolling_map/game_levels_scrolling_map.dart';
import 'package:game_levels_scrolling_map/model/point_model.dart';

typedef void IndexCallback(int index);

class RoadmapScreen extends StatefulWidget {
  final IndexCallback onNavButtonPressed;

  const RoadmapScreen({Key? key, required this.onNavButtonPressed})
      : super(key: key);

  @override
  State<RoadmapScreen> createState() => _RoadmapScreenState();
}

class _RoadmapScreenState extends State<RoadmapScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          child: GameLevelsScrollingMap.scrollable(
        imageUrl: "assets/images/map_vertical.png",
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
    fillTestData();
  }

  List<PointModel> points = [];

  void fillTestData() {
    for (int i = 0; i < 100; i++) {
      points.add(PointModel(100, testWidget(i)));
    }
  }

  Widget testWidget(int order) {
    return InkWell(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            "assets/images/map_vertical_point.png",
            fit: BoxFit.fitWidth,
            width: 50,
          ),
          Text("$order",
              style: const TextStyle(color: Colors.black, fontSize: 15))
        ],
      ),
      onTap: () => widget.onNavButtonPressed(3),
    );
  }
}