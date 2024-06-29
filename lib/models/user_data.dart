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
        _country = country;
        
  final String _nickname;
  final String _name;
  final String _email;
  final String _laboratory;
  int _score;
  int _level;
  final String _country;


  String get nickname => _nickname;
  String get name => _name;
  String get email => _email;
  String get laboratory => _laboratory;
  int get score => _score;
  int get level => _level;
  String get country => _country;

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