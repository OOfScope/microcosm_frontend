import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../constants.dart';

class SearchButton extends StatelessWidget {
  const SearchButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
        decoration: InputDecoration(
      hintText: 'Ask me anything...',
      fillColor: secondaryColor,
      filled: true,
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      suffixIcon: InkWell(
        onTap: () {},
        child: Container(
            padding: const EdgeInsets.all(defaultPadding * 0.75),
            margin: const EdgeInsets.symmetric(horizontal: defaultPadding / 2),
            decoration: const BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: SizedBox(
              height: 22,
              width: 22,
              child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    if (kDebugMode) {
                      print('Send button pressed');
                    }
                  },
                  icon: const Icon(Icons.send, size: 22, color: Colors.white)),
            )),
      ),
    ));
  }
}
