import 'package:flutter/material.dart';

import '../../constants.dart';
import '../../models/user_data.dart';

import '../../utils.dart';
import '../main/components/progress_levels.dart' as pl;

class ProfileScreen extends StatefulWidget {
  Function() onTestButtonPressed;

  ProfileScreen({super.key, required this.onTestButtonPressed});

  final UserManager userManager = UserManager.instance;

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late User user;

  @override
  void initState() {
    super.initState();
    user = widget.userManager.user;
  }

  void _addScore(int score) {
    setState(() {
      user.addScore(score);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(pl.defaultPadding),
        child: Column(
          children: <Widget>[
            const SizedBox(height: pl.defaultPadding),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  flex: 5,
                  child: Column(
                    children: <Widget>[
                      _buildProfileHeader(context),
                      const SizedBox(height: pl.defaultPadding),
                      _buildProfileDetails(context),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  flex: 5,
                  child: Column(
                    children: <Widget>[
                      _buildLevelingHeader(context),
                      const SizedBox(height: pl.defaultPadding),
                      pl.LevelProgressBar(user: user),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () =>
                  <void>{_addScore(10), widget.onTestButtonPressed()},
              child: const Text('Debug addScore(10)'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelingHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: Colors.blue.shade700, // Dark blue background
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 4,
            offset: const Offset(0, 2), // changes position of shadow
          ),
        ],
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            'Check your progress!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Icon(
            Icons.stars,
            color: Colors.white,
            size: 28,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Row(
      children: <Widget>[
        user.circleAvatar,
        const SizedBox(width: defaultPadding),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              user.name,
              style: const TextStyle(color: Colors.white, fontSize: 30),
            ),
            Text(user.levelName, style: const TextStyle(color: Colors.white)),
            Text(
              user.email,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProfileDetails(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildDetailRow('Email', user.email),
            _buildDetailRow('Laboratory', user.laboratory),
            _buildDetailRow('Score', user.score.toString()),
            _buildDetailRow('Level', '${user.level}/${user.levels.length}'),
            _buildDetailRow('Country', user.country),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(value),
        ],
      ),
    );
  }
}

class Header extends StatelessWidget {
  const Header({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ],
    );
  }
}
