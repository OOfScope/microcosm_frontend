import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../constants.dart';
import 'account_details.dart';

class Leaderboard extends StatelessWidget {
  const Leaderboard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 270,
      padding: const EdgeInsets.all(defaultPadding),
      decoration: const BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: const Column(
        children: <Widget>[
          Text(
            'Leaderboard',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
            // Align in the center
            textAlign: TextAlign.center,
          ),
          SizedBox(height: defaultPadding),
          account_info_card(
              rank: '1', name: 'Angelina Jolieeeeeeeeeee', score: '100'),
          account_info_card(rank: '2', name: 'Tom Hanks', score: '80'),
          account_info_card(rank: '3', name: 'Tom Cruise', score: '60'),
          account_info_card(rank: '4', name: 'Tom Cruise', score: '60'),
          account_info_card(rank: '5', name: 'Tom Cruise', score: '60'),
        ],
      ),
    );
  }
}

class account_info_card extends StatelessWidget {
  const account_info_card({
    super.key,
    required this.rank,
    required this.name,
    required this.score,
  });
  final rank;
  final name;
  final score;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: defaultPadding),
      padding: const EdgeInsets.only(
          top: defaultPadding / 2,
          left: defaultPadding,
          right: defaultPadding,
          bottom: defaultPadding / 2),
      decoration: BoxDecoration(
        color: secondaryColor,
        border: Border.all(width: 2, color: primaryColor.withOpacity(0.15)),
        borderRadius: const BorderRadius.all(
          Radius.circular(defaultPadding),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(rank),
          AccountDetails(name: name),
          Text(score),
        ],
      ),
    );
  }
}
