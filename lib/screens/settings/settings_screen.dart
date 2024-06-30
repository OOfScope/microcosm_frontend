import 'package:flutter/material.dart';

import '../../constants.dart';
import '../main/components/header.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Header(title: 'Settings'),
      ),
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Impostazioni'),
              // Add more widgets as needed
            ],
          ),
        ),
      ),
    );
  }
}