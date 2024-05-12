import 'package:flutter/material.dart';
import 'package:admin/screens/dashboard/components/header.dart';
import '../../constants.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        primary: false,
        padding: EdgeInsets.all(defaultPadding),
        child: Column(children: [
          Header(
            title: 'Profile',
          ),
          SizedBox(height: defaultPadding),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                // It takes 5/6 part of the screen
                flex: 5,
                child: Column(
                  children: [
                    Text('Profilo dell\'utente'),
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
