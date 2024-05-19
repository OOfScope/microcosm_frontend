import 'package:flutter/material.dart';
import '../../../constants.dart';

class SearchButton extends StatelessWidget {
  const SearchButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
        decoration: InputDecoration(
      hintText: "Ask me anything...",
      fillColor: secondaryColor,
      filled: true,
      border: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      suffixIcon: InkWell(
        onTap: () {},
        child: Container(
            padding: EdgeInsets.all(defaultPadding * 0.75),
            margin: EdgeInsets.symmetric(horizontal: defaultPadding / 2),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            child: SizedBox(
              height: 22,
              width: 22,
              child: IconButton(
                  padding: EdgeInsets.all(0.0),
                  onPressed: (() {
                    print("Send button pressed");
                  }),
                  icon: Icon(Icons.send, size: 22, color: Colors.white)),
            )),
      ),
    ));
  }
}
