import 'package:flutter/cupertino.dart';

import '../../../../constants.dart';

class TissueTypeLegend extends StatelessWidget {
  const TissueTypeLegend({
    super.key,
    required this.totalTissuePixelFound,
  });

  final Map<int, int> totalTissuePixelFound;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: 'Observed Tissue Types: \n',
        style: DefaultTextStyle.of(context).style.apply(
              fontSizeFactor: 1.7,
            ),
        children: <InlineSpan>[
          for (final int pixelValue in totalTissuePixelFound.keys)
            if (pixelValue != 0)
              TextSpan(
                children: <InlineSpan>[
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                          width: 10,
                          height: 10,
                          color: tissueColors[pixelValue],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          tissueTypes[pixelValue]!,
                          style: TextStyle(
                            color: DefaultTextStyle.of(context).style.color,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const TextSpan(text: '\n'),
                ],
              ),
        ],
      ),
    );
  }
}
