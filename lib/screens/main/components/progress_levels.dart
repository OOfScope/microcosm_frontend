import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../models/user_data.dart';
import '../../../utils.dart';

const double defaultPadding = 16.0;

class LevelProgressBar extends StatelessWidget {
  const LevelProgressBar({super.key, required this.user});
  final User user;



  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[     
          Text(
            user.level < user.levels.length ? 'You aim to become a ${user.nextLevelName}!' : 'You reached the highest level!',
            style: Theme.of(context).textTheme.headline6,
          ),
          const SizedBox(height: defaultPadding),
          Stack(
            children: <Widget>[
              Container(
                height: 90, // Adjusted height for a thinner progress bar
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              FractionallySizedBox(
                widthFactor: user.score / 100 > 1 ? 1 : user.score / 100,
                child: Container(
                  height: 90, // Adjusted height for a thinner progress bar
                  decoration: BoxDecoration(
                    color: Colors.blue.shade200,
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              Positioned.fill(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: user.levels.map((Map<String, dynamic> level) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          SvgPicture.asset(
                            level['image'] as String,
                            height: 50,
                            width: 50,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            level['name'] as String,
                            style: Theme.of(context).textTheme.caption,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
