import 'package:flutter/material.dart';

import '../../constants.dart';
import '../main/components/header.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: SingleChildScrollView(
        primary: false,
        padding: EdgeInsets.all(defaultPadding),
        child: Column(children: <Widget>[
          Header(title: 'Settings'),
          SizedBox(height: defaultPadding),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                // It takes 5/6 part of the screen
                flex: 5,
                child: Column(
                  children: <Widget>[
                    Text('Impostazioni'),
                  ],
                ),
              ),
            ],
          ),
        ]),
      ),
    );
  }
}
