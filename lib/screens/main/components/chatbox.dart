import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../constants.dart';
import '../components/chat_widget.dart';
import '../components/search_button.dart';

class ChatBox extends StatelessWidget {
  const ChatBox({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 270,
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(
            "Chat with AI",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
            // Align in the center
            textAlign: TextAlign.center,
          ),
          SizedBox(height: defaultPadding),
          Container(
            height: 300,
            padding: EdgeInsets.only(
              left: defaultPadding,
              right: defaultPadding,
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Container(
                color: Colors.grey,
              ),
            ),
          ),
          SizedBox(height: defaultPadding),
          SearchButton(),
        ],
      ),
    );
  }
}
