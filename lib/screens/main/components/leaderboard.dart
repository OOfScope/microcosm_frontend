import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../constants.dart';
import '../../../models/user_data.dart';
import '../../../utils.dart';
import 'account_details.dart';

class Leaderboard extends StatelessWidget {
  const Leaderboard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    User user = UserManager.instance.user;

    final List<AccountInfoCard> accountInfoCards = refreshLeaderboard(user);

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
        ],
      ),
    );
  }
}

List<AccountInfoCard> refreshLeaderboard(User user) {
  final List<Map<String, String>> accounts = <Map<String, String>>[
    <String, String>{'name': 'Kristofer Weeks', 'score': '80'},
    <String, String>{'name': 'Deeann Lorine', 'score': '20'},
    <String, String>{'name': 'Jessie Leopold', 'score': '40'},
    <String, String>{'name': 'Laraine Izzy', 'score': '50'},
    // <String, String>{'name': 'Phyllis Montes', 'score': '20'},
  ];

  accounts.add(<String, String>{'name': user.name, 'score': user.score.toString()});

  // Sort accounts in descending order by score
  accounts.sort((Map<String, String> a, Map<String, String> b) => int.parse(b['score']!).compareTo(int.parse(a['score']!)));

  // Generate account info cards with computed ranks
  final List<AccountInfoCard> accountInfoCards = accounts.asMap().entries.map((MapEntry<int, Map<String, String>> entry) {
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