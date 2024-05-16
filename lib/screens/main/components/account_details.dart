import 'package:flutter/material.dart';
import '../../../constants.dart';

class AccountDetails extends StatelessWidget {
  final name;
  const AccountDetails({Key? key, required this.name}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        padding: EdgeInsets.only(
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
