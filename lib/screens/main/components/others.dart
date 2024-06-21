import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:admin/screens/main/components/search_button.dart';
import 'package:admin/screens/main/components/chat_widget.dart';
import '../../../constants.dart';

class Other extends StatelessWidget {
  const Other({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
            height: 250,
            padding: EdgeInsets.only(
              left: defaultPadding,
              right: defaultPadding,
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: ChatWidget(
                msg: "Hello, how can I help you?",
                chatIndex: 1,
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
