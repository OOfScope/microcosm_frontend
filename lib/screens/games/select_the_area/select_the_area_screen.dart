import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

import '../../../models/user_data.dart';
import '../../../utils.dart';

class SelectTheAreaGame extends StatefulWidget {
  const SelectTheAreaGame({super.key});

  @override
  _CircleImageComparisonScreenState createState() =>
      _CircleImageComparisonScreenState();
}

class _CircleImageComparisonScreenState extends State<SelectTheAreaGame> {
  Offset? _startPoint;
  Offset? _endPoint;
  bool _isDrawing = false;
  bool _isVisible = false;
  bool _isEnabled = false;
  double imageVisibility = 0.5;

  Uint8List imageBytes = Uint8List(0);
  Uint8List maskImageBytes = Uint8List(0);
  Uint8List cmappedMaskImageBytes = Uint8List(0);

  late img.Image? fullImage;
  late img.Image? maskImage;
  late img.Image? cmappedMaskImage;

  late Image displayedFullImage;
  late Image displayedCmappedMaskImage;

  Map<int, int> pixelCount = <int, int>{};
  Map<int, int> totalTissuePixelFound = <int, int>{};

  User myuser = UserManager.instance.user;

  int tissueToFind = 0;

  Map<int, String> tissueTypes = <int, String>{
    1: 'Carcinoma',
    2: 'Necrosis',
    3: 'Tumor Stroma',
    4: 'Others',
  };

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  void _getPixelsTypeCount() {
    for (int x = 0; x < maskImage!.width; x++) {
      for (int y = 0; y < maskImage!.height; y++) {
        final img.Pixel pixelValue = maskImage!.getPixel(x, y);
        totalTissuePixelFound.update(
            pixelValue.r as int, (int value) => value + 1,
            ifAbsent: () => 1);
      }
    }
    // Print each unique pixel value
    // for (final int pixelValue in totalTissuePixelFound.keys) {
    //   if (kDebugMode) {
    //     print('Total Pixel Value: $pixelValue');
    //     print('Total Pixel Count: ${totalTissuePixelFound[pixelValue]}');
    //   }
    // }
  }

  void _getTissueToFind() {
    // 1: (0, 0, 255),    # Carcinoma
    // 2: (255, 0, 0),    # Necrosis
    // 3: (0, 255, 0),    # Tumor Stroma
    // 4: (0, 255, 255),  # Others

    // Select randomly one of the keys in pixelCount exept 0
    final List<int> pixelValues = totalTissuePixelFound.keys.toList();
    pixelValues.remove(0);
    tissueToFind = pixelValues[Random().nextInt(pixelValues.length)];

    if (kDebugMode) {
      final String tissueName = tissueTypes[tissueToFind]!;
      print('Tissue Index to Find: $tissueToFind;');
      print('Tissue to Find: $tissueName');
    }
  }

  void _processImageResponse(Map<String, dynamic> jsonImageResponse) {
    setState(() {
      imageBytes = base64Decode(jsonImageResponse['rows']![0][1] as String);
      maskImageBytes = base64Decode(jsonImageResponse['rows']![0][2] as String);
      cmappedMaskImageBytes =
          base64Decode(jsonImageResponse['rows']![0][3] as String);

      fullImage = img.decodeImage(imageBytes);
      maskImage = img.decodeImage(maskImageBytes);
      cmappedMaskImage = img.decodeImage(cmappedMaskImageBytes);
      displayedFullImage = Image.memory(
        imageBytes,
        fit: BoxFit.cover,
        width: 600,
        height: 600,
      );

      displayedCmappedMaskImage = Image.memory(
        cmappedMaskImageBytes,
        fit: BoxFit.cover,
        width: 600,
        height: 600,
      );
    });
  }

  Future<void> _loadImages() async {
    const bool keepLoading = true;

    while (keepLoading) {
      final http.Response response = await http.get(
          Uri.parse('https://microcosm-backend.gmichele.com/get/low/random/'));

      final Map<String, dynamic> jsonImageResponse =
          jsonDecode(response.body) as Map<String, dynamic>;

      _processImageResponse(jsonImageResponse);
      _getPixelsTypeCount();

      // Check if 0 is the only pixel value
      if (totalTissuePixelFound.length == 1 &&
          totalTissuePixelFound.containsKey(0)) {
        if (kDebugMode) {
          print('Only Unknown Class Pixels');
        }
        continue;
      }

      _getTissueToFind();
      break;
    }
  }

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _startPoint = details.localPosition;
      _endPoint = details.localPosition;
      _isDrawing = true;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _endPoint = details.localPosition;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      if (_isEnabled) {
        _comparePixels();
      }

      _isEnabled = true;

      // try {
      //   _comparePixels();
      // } catch (e) {
      //   if (kDebugMode) {
      //     print('Error: $e');
      //   }
      // }
    });
  }

  void _comparePixels() {
    if (_startPoint == null || _endPoint == null) {
      return;
    }

    // Scaling factor to handle rendered image and mask
    final double scalingFactorX =
        maskImage!.width / displayedCmappedMaskImage.width!;
    final double scalingFactorY =
        maskImage!.height / displayedCmappedMaskImage.height!;

    // Convert screen coordinates to image coordinates
    final double centerX =
        ((_startPoint!.dx + _endPoint!.dx) / 2) * scalingFactorX;
    final double centerY =
        ((_startPoint!.dy + _endPoint!.dy) / 2) * scalingFactorY;
    final double radius = (sqrt(pow(_endPoint!.dx - _startPoint!.dx, 2) +
                pow(_endPoint!.dy - _startPoint!.dy, 2)) /
            2) *
        scalingFactorX; // Assuming uniform scaling

    // if (kDebugMode) {
    //   print('Center: ($centerX, $centerY), Radius: $radius');
    //   print('Image Size: ${fullImage!.width} x ${fullImage!.height}');
    //   print('Mask Size: ${maskImage!.width} x ${maskImage!.height}');
    //   print(
    //       'Rendered cmapped Mask Size: ${displayedCmappedMaskImage.width} x ${displayedCmappedMaskImage.height}');
    //   print(
    //       'Rendered Image Size: ${displayedFullImage.width} x ${displayedFullImage.height}');
    // }

    final Set<int> uniquePixelValues = <int>{};
    final Map<int, int> pixelCount = <int, int>{};

    for (int x = (centerX - radius).toInt();
        x <= (centerX + radius).toInt();
        x++) {
      for (int y = (centerY - radius).toInt();
          y <= (centerY + radius).toInt();
          y++) {
        if (x >= 0 && x < maskImage!.width && y >= 0 && y < maskImage!.height) {
          final double dx = x - centerX;
          final double dy = y - centerY;

          if (dx * dx + dy * dy <= radius * radius) {
            final img.Pixel pixelValue = maskImage!.getPixel(x, y);
            uniquePixelValues.add(pixelValue.r as int);
            pixelCount.update(pixelValue.r as int, (int value) => value + 1,
                ifAbsent: () => 1);
          }
        }
      }
    }

    // if tissueToFind is in pixelCount
    if (pixelCount.containsKey(tissueToFind)) {
      // sum the total number of pixels in image
      double totalCoveredPixels = 0;
      for (final int pixelValue in pixelCount.keys) {
        totalCoveredPixels += pixelCount[pixelValue]!;
      }

      // if selected pixels cover the whole image area
      final double coveredArea =
          totalCoveredPixels / (maskImage!.width * maskImage!.height);

      if (coveredArea > 0.7) {
        if (kDebugMode) {
          print(
              "Devi selezionare solo la parte dell'immagine in cui è presente il tessuto");
          return;
        }
      }

      // if number of pixel of correct tissue is less than 50% of the total correct tissue pixels
      if (pixelCount[tissueToFind]! <
          0.5 * totalTissuePixelFound[tissueToFind]!) {
        print('Non hai individuato tutto il tessuto corretto');
        return;
      }

      if (kDebugMode) {
        print('Tissue Name: ${tissueTypes[tissueToFind]}');
        print('Total Pixel Count: ${totalTissuePixelFound[tissueToFind]}');
        print('Pixel Count in selected Area: ${pixelCount[tissueToFind]}');
        print('Covered Area: $coveredArea');
        print('Total Area: ${maskImage!.width * maskImage!.height}');
        print('Covered Pixels: $totalCoveredPixels');
      }

      print('Hai individuato il tessuto corretto');
    } else {
      print('Non hai individuato il tessuto corretto');
    }

    // Print each unique pixel value
    // for (final int pixelValue in uniquePixelValues) {
    //   if (kDebugMode) {
    //     print('Pixel Value in selected Area: $pixelValue');
    //     print('Pixel Count in selected Area: ${pixelCount[pixelValue]}');
    //   }
    // }
  }

  void checkAnswer() {
    _comparePixels();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Circle Area Comparison'),
      ),
      body: imageBytes.isEmpty || tissueToFind == 0
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 20),
                  child: RichText(
                    text: TextSpan(
                      text: 'Find the ',
                      style: DefaultTextStyle.of(context).style.apply(
                            fontSizeFactor: 2,
                          ),
                      children: <TextSpan>[
                        TextSpan(
                            text: tissueTypes[tissueToFind],
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        const TextSpan(text: ' Tissue!'),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 50, right: 20),
                      child: Center(
                        child: ClipRect(
                          child: FittedBox(
                            child: GestureDetector(
                              onPanStart: _onPanStart,
                              onPanUpdate: _onPanUpdate,
                              onPanEnd: _onPanEnd,
                              child: Stack(
                                children: <Widget>[
                                  displayedFullImage,
                                  AnimatedOpacity(
                                      opacity:
                                          _isVisible ? imageVisibility : 0.0,
                                      duration:
                                          const Duration(milliseconds: 100),
                                      child: displayedCmappedMaskImage),
                                  if (_isDrawing &&
                                      _startPoint != null &&
                                      _endPoint != null)
                                    CustomPaint(
                                      painter: CirclePainter(
                                          _startPoint!, _endPoint!),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        const Row(
                          children: <Widget>[
                            Align(
                              alignment: Alignment.topLeft,
                              child: SizedBox(
                                height: 200,
                                width: 550,
                                child: Text(
                                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
                                  'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. '
                                  'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. '
                                  'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. '
                                  'Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    overflow: TextOverflow.visible,
                                  ),
                                  maxLines: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        Row(
                          children: <Widget>[
                            if (_isVisible)
                              Column(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(left: 20),
                                    child: RichText(
                                      text: TextSpan(
                                        text: 'Image visibility: ',
                                        style: DefaultTextStyle.of(context)
                                            .style
                                            .apply(
                                              fontSizeFactor: 1.5,
                                            ),
                                        children: <TextSpan>[
                                          TextSpan(
                                              text: imageVisibility
                                                  .toStringAsFixed(2),
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Slider(
                                    value: imageVisibility,
                                    onChanged: (double value) {
                                      setState(() {
                                        imageVisibility = value;
                                      });
                                    },
                                  ),
                                  const SizedBox(width: 30),
                                  const Text('legenda')
                                ],
                              ),
                          ],
                        )
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 30),
                // Display bottom left button to confirm the selection
                Row(
                  children: <Widget>[
                    const Spacer(),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: SizedBox(
                        height: 50,
                        width: 200,
                        child: FilledButton(
                          onPressed: _isEnabled
                              ? () {
                                  setState(() {
                                    if (!_isVisible &&
                                        _startPoint != null &&
                                        _endPoint != null &&
                                        _isDrawing) {
                                      _isVisible = true;
                                      checkAnswer();
                                    }
                                  });
                                }
                              : null,
                          child: const Text('Confirm Selection'),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}

class CirclePainter extends CustomPainter {
  CirclePainter(this.startPoint, this.endPoint);
  final Offset startPoint;
  final Offset endPoint;

  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = (startPoint.dx + endPoint.dx) / 2;
    final double centerY = (startPoint.dy + endPoint.dy) / 2;
    final double radius = sqrt(pow(endPoint.dx - startPoint.dx, 2) +
            pow(endPoint.dy - startPoint.dy, 2)) /
        2;

    final Paint paint = Paint()
      ..color = Colors.blue.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(centerX, centerY), radius, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
