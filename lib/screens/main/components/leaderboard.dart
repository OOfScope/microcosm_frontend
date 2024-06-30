import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../constants.dart';
import '../../../models/user_data.dart';
import '../../../utils.dart';
import 'account_details.dart';

class Leaderboard extends StatefulWidget {
  const Leaderboard({
    super.key,
  });

  @override
  State<Leaderboard> createState() => LeaderboardState();
}

class LeaderboardState extends State<Leaderboard> {
  late List<AccountInfoCard> accountInfoCards;

  @override
  void initState() {
    super.initState();
    accountInfoCards = refreshLeaderboard();
  }

  void updateLeaderboard() {
    setState(() {
      print('update leaderboard state');
      accountInfoCards = refreshLeaderboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    User user = UserManager.instance.user;

    return Container(
      width: 270,
      padding: const EdgeInsets.all(defaultPadding),
      decoration: const BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        children: <Widget>[
          Text(
            '${user.laboratory.toUpperCase()} LEADERBOARD',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: defaultPadding),
          ...accountInfoCards,
          const SizedBox(height: defaultPadding),
          ElevatedButton(
            onPressed: () {
              user.addScore(10);
              updateLeaderboard();
            },
            child: const Text('Debug addScore(10)'),
          ),
        ],
      ),
    );
  }

  List<AccountInfoCard> refreshLeaderboard() {
    final User user = UserManager.instance.user;

    final List<Map<String, String>> accounts = <Map<String, String>>[
      <String, String>{'name': 'Kristofer Weeks', 'score': '80'},
      <String, String>{'name': 'Deeann Lorine', 'score': '20'},
      <String, String>{'name': 'Jessie Leopold', 'score': '40'},
      <String, String>{'name': 'Laraine Izzy', 'score': '50'},
      // <String, String>{'name': 'Phyllis Montes', 'score': '20'},
    ];

    accounts.add(
        <String, String>{'name': user.name, 'score': user.score.toString()});

    accounts.sort((Map<String, String> a, Map<String, String> b) =>
        int.parse(b['score']!).compareTo(int.parse(a['score']!)));

    final List<AccountInfoCard> accountInfoCards = accounts
        .asMap()
        .entries
        .map((MapEntry<int, Map<String, String>> entry) {
      final int index = entry.key;
      final Map<String, String> account = entry.value;
      final String rank = (index + 1).toString();
      return AccountInfoCard(
        rank: rank,
        name: account['name']!,
        score: account['score']!,
      );
    }).toList();

    return accountInfoCards;
  }
}

class AccountInfoCard extends StatelessWidget {
  const AccountInfoCard({
    super.key,
    required this.rank,
    required this.name,
    required this.score,
  });
  final String rank;
  final String name;
  final String score;

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
