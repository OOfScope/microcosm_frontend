import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../constants.dart';
import 'models/user_data.dart';
import 'screens/dashboard/components/level_button.dart';

class UserManager {
  UserManager._internal();

  static final UserManager _instance = UserManager._internal();
  late User _user;

  static UserManager get instance => _instance;

  set user(User user) {
    _user = user;
  }

  User get user => _user;
}

Future<User> checkIfUserOnDisk(String email, String country) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  final String? nickname = prefs.getString('nickname');
  final int score = prefs.getInt('score') ?? 0;
  final int level = prefs.getInt('level') ?? 0;

  if (nickname != null &&
      prefs.getString('email') == email &&
      prefs.getString('country') == country) {
    // User exists on disk
    final String name = email.split('@').first;
    final String laboratory = prefs.getString('laboratory') ?? 'Unknown Lab';

    final User user = User(
      nickname: nickname,
      name: name,
      email: email,
      laboratory: laboratory,
      score: score,
      level: level,
      country: country,
    );

    return user;
  } else {
    final String name = email.split('@').first;

    final List<String> labNames = <String>[
      'AI Lab',
      'Physics Lab',
      'Chemistry Lab',
      'Biology Lab',
      'Computer Lab'
    ];

    final String laboratory = labNames[Random().nextInt(labNames.length)];

    await prefs.setString('nickname', name);
    await prefs.setString('name', name);
    await prefs.setString('email', email);
    await prefs.setString('laboratory', laboratory);
    await prefs.setInt('score', score);
    await prefs.setInt('level', level);
    await prefs.setString('country', country);

    final User user = User(
      nickname: name,
      name: name,
      email: email,
      laboratory: laboratory,
      score: score,
      level: level,
      country: country,
    );
    return user;
  }
}

Future<Map<String, dynamic>> jwtDecode(String token) async {
  final String jwtDecodeUrl =
      'https://microcosm-backend.gmichele.com/parse_jwt/user_data/$token';

  final http.Response response = await http.get(Uri.parse(jwtDecodeUrl));
  if (response.statusCode != 200) {
    if (kDebugMode) {
      print('ERR: Error in token parsing!');
    }
    return <String, dynamic>{};
  } else {
    final Map<String, dynamic> ret =
        jsonDecode(response.body) as Map<String, dynamic>;
    return ret;
  }
}

class ImageUtils {
  Uint8List imageBytes = Uint8List(0);
  Uint8List maskImageBytes = Uint8List(0);
  Uint8List cmappedMaskImageBytes = Uint8List(0);

  late img.Image? fullImage;
  late img.Image? maskImage;
  late img.Image? cmappedMaskImage;

  late Image displayedFullImage;
  late Image displayedCmappedMaskImage;

  int tissueToFind = 0;

  Map<int, int> totalTissuePixelFound = <int, int>{};

  void getPixelsTypeCount() {
    for (int x = 0; x < maskImage!.width; x++) {
      for (int y = 0; y < maskImage!.height; y++) {
        final img.Pixel pixelValue = maskImage!.getPixel(x, y);
        totalTissuePixelFound.update(
            pixelValue.r as int, (int value) => value + 1,
            ifAbsent: () => 1);
      }
    }

    // Print each unique pixel value
    for (final int pixelValue in totalTissuePixelFound.keys) {
      if (kDebugMode) {
        print('Total Pixel Value: $pixelValue');
        print('Total Pixel Count: ${totalTissuePixelFound[pixelValue]}');
      }
    }
  }

  void getTissueToFind() {
    // Select randomly one of the keys in pixelCount except 0
    final List<int> pixelValues = totalTissuePixelFound.keys.toList();
    pixelValues.remove(0);

    tissueToFind = pixelValues[Random().nextInt(pixelValues.length)];

    if (kDebugMode) {
      final String tissueName = tissueTypes[tissueToFind]!;
      print('Tissue Index to Find: $tissueToFind;');
      print('Tissue to Find: $tissueName');
    }
  }

  void processImageResponse(Map<String, dynamic> jsonImageResponse) {
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
  }

  Future<void> loadImages(String url) async {
    const bool keepLoading = true;

    while (keepLoading) {
      final http.Response response = await http.get(Uri.parse(url));

      final Map<String, dynamic> jsonImageResponse =
          jsonDecode(response.body) as Map<String, dynamic>;

      processImageResponse(jsonImageResponse);
      getPixelsTypeCount();

      // Check if 0 is the only pixel value
      if (totalTissuePixelFound.length == 1 &&
          totalTissuePixelFound.containsKey(0)) {
        if (kDebugMode) {
          print('Only Unknown Class Pixels');
        }
        continue;
      }

      getTissueToFind();
      break;
    }
  }
}

Future<List<ImageUtils>> loadMoreImages(String url, int amount) async {
  final List<ImageUtils> imageResponses = <ImageUtils>[];

  for (int i = 0; i < amount; i++) {
    final ImageUtils imageResponse = ImageUtils();
    await imageResponse.loadImages(url);
    imageResponses.add(imageResponse);
  }

  return imageResponses;
}

Future<List<Image>> loadOnlyImages(String url, int amount) async {
  final List<Image> images = <Image>[];
  Map<String, dynamic> jsonImageResponse;
  Uint8List imageBytes;
  for (int i = 0; i < amount; i++) {
    final http.Response response = await http.get(Uri.parse(url));

    jsonImageResponse = jsonDecode(response.body) as Map<String, dynamic>;
    imageBytes = base64Decode(jsonImageResponse['rows']![0][0] as String);
    images.add(Image.memory(
      imageBytes,
    ));
  }

  return images;
}

class LevelButtonManager {
  LevelButtonManager._internal();

  static final LevelButtonManager _instance = LevelButtonManager._internal();
  late List<LevelButton> _levels;

  static LevelButtonManager get instance => _instance;

  set levelButtons(List<LevelButton> levels) {
    _levels = levels;
  }

  List<LevelButton> get levelButtons => _levels;
}

List<LevelButton> initializeLevelButtons() {
  final List<LevelButton> levelButtons = <LevelButton>[];

  for (int i = 1; i <= 40; i++) {
    levelButtons.add(
      LevelButton(
        levelNumber: i,
        status: i == 1 ? LevelStatus.inProgress : LevelStatus.locked,
        isActive: i == 1,
      ),
    );
  }
  return levelButtons;
}

void setOnTapMethod(
    List<LevelButton> levels, Function(int, int) onTapLevelButton) {
  for (final LevelButton level in levels) {
    level.onTapLevelButton = onTapLevelButton;
  }
}

class AnswerWidget extends StatelessWidget {
  AnswerWidget({
    super.key,
    required this.text,
    required this.answerColor,
  });

  final String text;
  final Color answerColor;
  double fontAnswer = answerFontSize;

  set fontSize(double fontSize) {
    fontAnswer = fontSize;
  }

  double get fontSize => fontAnswer;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
          color: answerColor,
          fontSize: fontAnswer != 0 ? answerFontSize : fontAnswer,
          fontWeight: FontWeight.bold),
      overflow: TextOverflow.visible,
    );
  }
}

class GameInfo {
  GameInfo({
    required this.level,
    required this.difficulty,
  });

  final int level;
  final int difficulty;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GameInfo &&
        other.level == level &&
        other.difficulty == difficulty;
  }

  @override
  int get hashCode => level.hashCode ^ difficulty.hashCode;

  @override
  String toString() {
    return 'GameInfo (level: $level, difficulty: $difficulty)';
  }
}

class GameInfoManager {
  GameInfoManager._internal();

  static final GameInfoManager _instance = GameInfoManager._internal();
  final Map<GameInfo, int> _gameInfo = {};

  static GameInfoManager get instance => _instance;

  set gameInfo(Map<GameInfo, int> gameInfo) {
    _gameInfo.addAll(gameInfo);
  }

  Map<GameInfo, int> get gameInfo => _gameInfo;

  void update(int index, int difficulty) {
    final GameInfo tmp = GameInfo(level: index, difficulty: difficulty);

    if (!_gameInfo.containsKey(tmp)) {
      _gameInfo[tmp] = 1;

      if (kDebugMode) {
        print('Add level: $index with difficulty: $difficulty');
        print('GameInfo: $_gameInfo');
      }
    } else {
      _gameInfo[tmp] = _gameInfo[tmp]! + 1;

      if (kDebugMode) {
        print(
            'Update level: $index with difficulty: $difficulty and frequency: ${_gameInfo[tmp]}');
      }
    }
  }

  GameInfo? getHighestFrequencyGame() {
    if (_gameInfo.isEmpty) return null;

    MapEntry<GameInfo, int>? highestFrequencyEntry;
    for (var entry in _gameInfo.entries) {
      if (highestFrequencyEntry == null ||
          entry.value > highestFrequencyEntry.value) {
        highestFrequencyEntry = entry;
      }
    }

    if (highestFrequencyEntry != null) {
      return highestFrequencyEntry.key;
    }

    return null;
  }

  void removeHighestFrequencyGame() {
    if (_gameInfo.isEmpty) {
      return;
    }

    MapEntry<GameInfo, int>? highestFrequencyEntry;
    for (var entry in _gameInfo.entries) {
      if (highestFrequencyEntry == null ||
          entry.value > highestFrequencyEntry.value) {
        highestFrequencyEntry = entry;
      }
    }
    if (highestFrequencyEntry != null) {
      _gameInfo.remove(highestFrequencyEntry.key);
    }
  }
}
