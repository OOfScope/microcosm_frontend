import 'dart:convert';
import 'dart:ffi';
import 'dart:js_interop';

import 'package:admin/constants.dart';
import 'package:admin/controllers/MenuAppController.dart';
import 'package:admin/screens/main/main_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:web/web.dart';
import 'package:http/http.dart' as http;


Future<Map<String,dynamic>> jwt_decode(String token) async {
  final String jwt_decode_url =
      'https://microcosm-backend.gmichele.com/parse_jwt/user_data/' + token;
  
  final response = await http.get(Uri.parse(jwt_decode_url));
  if (response.statusCode != 200){
    console.log('Error in token parsing!'.toJS);
    return new Map<String,dynamic>();
  }else{
      String body = response.body;
      var ret = jsonDecode(response.body) as Map<String, dynamic>;
      console.dir(ret.jsify());

      return ret;

  }
}

void main() {


  if (kReleaseMode) {
    final cookie = document.cookie;
    final entity = cookie.split("; ").map((item) {
      final split = item.split("=");
      return MapEntry(split[0], split[1]);
    });
    final cookieMap = Map.fromEntries(entity);
    final String token = cookieMap["CF_Authorization"].toString();
    console.log(token.toJS);

    dynamic ret = jwt_decode(token);
    console.log("OUT".toJS);
    console.dir(ret.toJS);

  }else{
    final String test_token = "eyJhbGciOiJSUzI1NiIsImtpZCI6Ijg5OTE0OTI4ZWE0MzkwZjEyYzY3MzdmZWFhYWRmYTA1NTcwMDlhMjE0OTVhYzE4NTExMTIzYzgzYjhiM2QxN2EifQ.eyJhdWQiOlsiOTkzYmQ1ZDY3YmQ3NTFiNTQ1YmY4N2I5MzY1MWRlOTBiMmU0ODI2NTAzZDgzMTRhMjg3N2NlZjVkMzgwOWYxYyJdLCJlbWFpbCI6IjI3MzgzOUBzdHVkZW50aS51bmltb3JlLml0IiwiZXhwIjoxNzE4OTc5MDg0LCJpYXQiOjE3MTg5NzcyODQsIm5iZiI6MTcxODk3NzI4NCwiaXNzIjoiaHR0cHM6Ly9nbWljaGVsZS5jbG91ZGZsYXJlYWNjZXNzLmNvbSIsInR5cGUiOiJhcHAiLCJpZGVudGl0eV9ub25jZSI6IjJha3doSjlabnhmZnY1SE8iLCJzdWIiOiJkZDQyMjllNy0yMDgzLTVkNWYtYTU1NC04MmQ4MTAxMGMwNmIiLCJjb3VudHJ5IjoiSVQifQ.XvCybleXeWHMGHx_TZOSzHc9LcqEf0yZfd3u5Uo0eMstR1hiT1qjYjsDstaCvpPBz7EZQLOHNIhycxKCXfKcesRvqDRwHQYkQvbCjmhMMbT6a0HYlcvxyAEO8fJrOcdL8gMqaCg4Pf08mNuCx-vbFdWkYcHfbbQ_2ehDeLK59GHIshuOAy7y6H6RYKp6I2nqz8drBUVm3koyIW3Pk3iyqsx6_gcqpMblNBZoRWz9mznKpoR1gQ6WvifnzPkzxz3uLz9WXjxlLrS-UAu0TKzm-qejnhUyVDW5aCCXm2cd04-t16f36QDWclS9KkCutOHof8JCOCxgPlmXxb43V72tiw";

    dynamic ret = jwt_decode(test_token);
    console.log("OUT".toJS);
    console.dir(ret.toJS);

  }
  debugPaintSizeEnabled = false;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
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
        providers: [
          ChangeNotifierProvider(
            create: (context) => MenuAppController(),
          ),
        ],
        child: MainScreen(),
      ),
    );
  }
}
