import 'package:flutter/material.dart';
import '../../constants.dart';
import '../main/components/header.dart';

class RoadmapScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        primary: false,
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            Header(
              title: 'Dashboard',
            ),
            SizedBox(height: defaultPadding),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 4,
                  child: Column(
                    // Here we need vfertical scrollable menu games
                    children: [
                      SizedBox(height: defaultPadding),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
