import 'package:flutter/material.dart';

import '../../constants.dart';
import '../../models/user_data.dart';
import '../../utils.dart';

class ProfileScreen extends StatelessWidget {
  final UserManager userManager = UserManager.instance;
  
  final User user = UserManager.instance.user;
   
  ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          children: <Widget>[
            const Header(
              title: 'Profile',
            ),
            const SizedBox(height: defaultPadding),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  flex: 5,
                  child: Column(
                    children: <Widget>[
                      _buildProfileHeader(context),
                      const SizedBox(height: defaultPadding),
                      _buildProfileDetails(context),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Row(
      children: <Widget>[
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.blueGrey,
          child: Text(
            user.name[0],  // Display the first letter of the user's name
            style: const TextStyle(
              fontSize: 40,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: defaultPadding),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              user.name,
              style: Theme.of(context).textTheme.headline5,
            ),
            Text(
              user.nickname,
              style: Theme.of(context).textTheme.subtitle1,
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
            _buildDetailRow('Level', user.level.toString()),
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
  final String title;

  const Header({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          title,
          style: Theme.of(context).textTheme.headline4,
        ),
      ],
    );
  }
}