import 'package:flutter/material.dart';
import '../../../constants.dart';

class AccountDetails extends StatelessWidget {
  const AccountDetails({super.key, required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.only(
          left: defaultPadding,
          right: defaultPadding,
        ),
        child: Text(
          name,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
