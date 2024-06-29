import 'package:flutter/material.dart';

class User {

  User({
    required String nickname,
    required String name,
    required String email,
    required String laboratory,
    required int score,
    required int level,
    required String country,
  })  : _nickname = nickname,
        _name = name,
        _email = email,
        _laboratory = laboratory,
        _score = score,
        _level = level,
        _country = country,
        _circleAvatar = CircleAvatar(
          backgroundColor: Colors.blueGrey,
          radius: 40,
          child: Text(
            nickname[0].toUpperCase() + nickname[1].toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 40,
            ),
          ),
        ),
        _smallCircleAvatar = CircleAvatar(
          backgroundColor: Colors.blueGrey,
          radius: 15,
          child: Text(
            nickname[0].toUpperCase() + nickname[1].toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        );
        
  final String _nickname;
  final String _name;
  final String _email;
  final String _laboratory;
  int _score;
  int _level;
  final String _country;
  final CircleAvatar _circleAvatar;
  final CircleAvatar _smallCircleAvatar;


  String get nickname => _nickname;
  String get name => _name;
  String get email => _email;
  String get laboratory => _laboratory;
  int get score => _score;
  int get level => _level;
  String get country => _country;
  CircleAvatar get circleAvatar => _circleAvatar;
  CircleAvatar get smallCircleAvatar => _smallCircleAvatar;

  set score(int newScore) {
    _score = newScore;
  }

  set level(int newLevel) {
    _level = newLevel;
  }

  @override
  String toString() {
    return 'User(nickname: $_nickname, name: $_name, email: $_email, laboratory: $_laboratory, score: $_score, level: $_level, country: $_country)';
  }
}