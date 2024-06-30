
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'models/user_data.dart';


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

  if (nickname != null && prefs.getString('email') == email && prefs.getString('country') == country) {
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
    
    final List<String> labNames = <String>['AI Lab', 'Physics Lab', 'Chemistry Lab', 'Biology Lab', 'Computer Lab'];
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
