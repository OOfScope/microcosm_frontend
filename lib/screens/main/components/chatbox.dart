import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../constants.dart';
import 'chat_widget.dart';
import 'search_button.dart';

class ChatBot extends StatelessWidget {
  const ChatBot({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: const BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          const Text(
            'Chat with AI',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
            // Align in the center
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: defaultPadding),
          Container(
            height: 350,
            padding: const EdgeInsets.only(
              left: defaultPadding,
              right: defaultPadding,
            ),
            child: const SingleChildScrollView(
              child: ChatWidget(
                msg: 'Hello, how can I help you?',
                chatIndex: 1,
              ),
            ),
          ),
          const SizedBox(height: defaultPadding),
          const SearchButton(),
        ],
      ),
    );
  }
}
