import 'dart:convert';
import 'dart:js_interop';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web/web.dart';

import 'constants.dart';
import 'controllers/menu_app_controller.dart';
import 'models/user_data.dart';
import 'screens/main/main_screen.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

Future<User> checkIfUserOnDisk(String email, String country) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  final String? nickname = prefs.getString('nickname');
  final int score = prefs.getInt('score') ?? 0;
  final int level = prefs.getInt('level') ?? 0;

  if (nickname != null && prefs.getString('email') == email && prefs.getString('country') == country) {
    // User exists on disk
    final String name = email.split('@').first;
    final String laboratory = prefs.getString('laboratory') ?? 'Unknown Lab';

    User user = User(
      nickname: nickname,
      name: name,
      email: email,
      laboratory: laboratory,
      score: score,
      level: level,
      country: country,
    );
    print(user);
    return user;

  } else {
    // User does not exist on disk, create one
    final String name = email.split('@').first;
    
    // List of random names for the laboratory
    final List<String> labNames = ['Physics Lab', 'Chemistry Lab', 'Biology Lab', 'Computer Lab'];
    final String laboratory = labNames[Random().nextInt(labNames.length)];

    // Set new user data in SharedPreferences
    await prefs.setString('nickname', name);
    await prefs.setString('name', name);
    await prefs.setString('email', email);
    await prefs.setString('laboratory', laboratory);
    await prefs.setInt('score', score);
    await prefs.setInt('level', level);
    await prefs.setString('country', country);

    User user = User(
      nickname: name,
      name: name,
      email: email,
      laboratory: laboratory,
      score: score,
      level: level,
      country: country,
    );
    print(user);
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();


  Map<String, dynamic>? decodedToken;

  if (kReleaseMode) {
    final String cookie = document.cookie;
    final Iterable<MapEntry<String, String>> entity =
        cookie.split('; ').map((String item) {
      final List<String> split = item.split('=');
      return MapEntry(split[0], split[1]);
    });
    final Map<String, String> cookieMap = Map.fromEntries(entity);
    final String? token = cookieMap['CF_Authorization'];
    if (kDebugMode) {
      print(token);
    }

    if (token != null) {
      decodedToken = await jwtDecode(token);
    }
  } else {
    if (kDebugMode) {
      print('WARN: Using test-token!');
    }

    const String testToken =
        'eyJhbGciOiJSUzI1NiIsImtpZCI6Ijg5OTE0OTI4ZWE0MzkwZjEyYzY3MzdmZWFhYWRmYTA1NTcwMDlhMjE0OTVhYzE4NTExMTIzYzgzYjhiM2QxN2EifQ.eyJhdWQiOlsiOTkzYmQ1ZDY3YmQ3NTFiNTQ1YmY4N2I5MzY1MWRlOTBiMmU0ODI2NTAzZDgzMTRhMjg3N2NlZjVkMzgwOWYxYyJdLCJlbWFpbCI6IjI3MzgzOUBzdHVkZW50aS51bmltb3JlLml0IiwiZXhwIjoxNzE4OTc5MDg0LCJpYXQiOjE3MTg5NzcyODQsIm5iZiI6MTcxODk3NzI4NCwiaXNzIjoiaHR0cHM6Ly9nbWljaGVsZS5jbG91ZGZsYXJlYWNjZXNzLmNvbSIsInR5cGUiOiJhcHAiLCJpZGVudGl0eV9ub25jZSI6IjJha3doSjlabnhmZnY1SE8iLCJzdWIiOiJkZDQyMjllNy0yMDgzLTVkNWYtYTU1NC04MmQ4MTAxMGMwNmIiLCJjb3VudHJ5IjoiSVQifQ.XvCybleXeWHMGHx_TZOSzHc9LcqEf0yZfd3u5Uo0eMstR1hiT1qjYjsDstaCvpPBz7EZQLOHNIhycxKCXfKcesRvqDRwHQYkQvbCjmhMMbT6a0HYlcvxyAEO8fJrOcdL8gMqaCg4Pf08mNuCx-vbFdWkYcHfbbQ_2ehDeLK59GHIshuOAy7y6H6RYKp6I2nqz8drBUVm3koyIW3Pk3iyqsx6_gcqpMblNBZoRWz9mznKpoR1gQ6WvifnzPkzxz3uLz9WXjxlLrS-UAu0TKzm-qejnhUyVDW5aCCXm2cd04-t16f36QDWclS9KkCutOHof8JCOCxgPlmXxb43V72tiw';
    decodedToken = await jwtDecode(testToken);
  }

  if (decodedToken == null || decodedToken.isEmpty) {
    console.log('ERR: Error in token parsing or token is empty!'.toJS);
  } else {
    if (kDebugMode) {
      print(decodedToken);
    }
  }
  String email = decodedToken!['email'] as String;
  String country = decodedToken['country'] as String;

  final User user = await checkIfUserOnDisk(email, country);

  print(user);

  debugPaintSizeEnabled = false;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Admin Panel',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: bgColor,
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme)
            .apply(bodyColor: Colors.white),
        canvasColor: secondaryColor,
      ),
      home: MultiProvider(
        providers: <SingleChildWidget>[
          ChangeNotifierProvider(
            create: (BuildContext context) => MenuAppController(),
          ),
        ],
        child: const MainScreen(),
      ),
    );
  }
}
