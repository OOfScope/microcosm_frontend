import 'dart:js_interop';

import 'package:admin/constants.dart';
import 'package:admin/controllers/MenuAppController.dart';
import 'package:admin/screens/main/main_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:web/web.dart';
import 'package:http/http.dart' as http;



Future<JSBoxedDartObject> jwt_decode(String token) async{
  final String jwt_decode_url = 'https://microcosm-backend.gmichele.com/parse_jwt/' + token;

  final response = await http.get(Uri.parse(jwt_decode_url));

      if (response.statusCode == 200) {
        console.dir(response.toJSBox);
      }
  return response.toJSBox;
      
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

    Future<JSBoxedDartObject> ret = jwt_decode(token);
    console.dir(ret.toJS);
  }
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
