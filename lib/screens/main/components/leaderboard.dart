import 'package:admin/screens/main/components/account_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../constants.dart';

class Leaderboard extends StatelessWidget {
  const Leaderboard({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        children: [
          Text(
            "Leaderboard",
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
  final rank;
  final name;
  final score;
  const account_info_card({
    Key? key,
    required this.rank,
    required this.name,
    required this.score,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: defaultPadding),
      padding: EdgeInsets.only(
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
        children: [
          Text(rank),
          AccountDetails(name: name),
          Text(score),
        ],
      ),
    );
  }
}
