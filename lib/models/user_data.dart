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
        ){
        _levelName = levels.firstWhere((Map<String, dynamic> level) => level['score'] == score)['name'] as String;
        _nextLevelName = levels.firstWhere((Map<String, dynamic> level) => (level['score'] as int) > score)['name'] as String;
        _level = levels.indexWhere((Map<String, dynamic> level) => (level['score'] as int) > score) + 1; // levels are zero indexed
        
        this.addScore(60);
        }
        
  final String _nickname;
  final String _name;
  final String _email;
  final String _laboratory;
  int _score;
  int _level;
  final String _country;
  final CircleAvatar _circleAvatar;
  final CircleAvatar _smallCircleAvatar;
  late final String _levelName;
  late final String _nextLevelName;


  static const String assetPath = 'assets/icons/doctors';

   
  static final List<Map<String, dynamic>> _levels = <Map<String, dynamic>>[
    <String, dynamic>{
      'name': 'Resident Doctor',
      'score': 0,
      'image': '$assetPath/1_level.svg'
    },
    <String, dynamic>{
      'name': 'Junior Doctor',
      'score': 20,
      'image': '$assetPath/2_level.svg'
    },
    <String, dynamic>{
      'name': 'Senior Doctor',
      'score': 40,
      'image': '$assetPath/3_level.svg'
    },
    <String, dynamic>{
      'name': 'Attending Physician',
      'score': 60,
      'image': '$assetPath/4_level.svg'
    },
    <String, dynamic>{
      'name': 'Chief Physician',
      'score': 80,
      'image': '$assetPath/5_level.svg'
    },
    <String, dynamic>{
      'name': 'Pathology Expert',
      'score': 100,
      'image': '$assetPath/6_level.svg'
    },
  ];


  String get nickname => _nickname;
  String get name => _name;
  String get email => _email;
  String get laboratory => _laboratory;
  String get country => _country;
  CircleAvatar get circleAvatar => _circleAvatar;
  CircleAvatar get smallCircleAvatar => _smallCircleAvatar;
  int get score => _score;
  int get level => _level;


  set score(int newScore) {
    _score = newScore;
  }

  set level(int newLevel) {
    _level = newLevel;
  }

  String get levelName => _levelName;
  String get nextLevelName => _nextLevelName;

  List<Map<String, dynamic>> get levels => _levels;

  int addScore(int scoreToAdd){
    _score += scoreToAdd;

    return _score; 
  }

  @override
  String toString() {
    return 'User(nickname: $_nickname, name: $_name, email: $_email, laboratory: $_laboratory, score: $_score, level: $_level, country: $_country)';
  }

}
