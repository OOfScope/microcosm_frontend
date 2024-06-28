class User {

  User({
    required String nickname,
    required String name,
    required String email,
    required String laboratory,
    required int score,
    required int level,
  })  : _nickname = nickname,
        _name = name,
        _email = email,
        _laboratory = laboratory,
        _score = score,
        _level = level;


  final String _nickname;
  final String _name;
  final String _email;
  final String _laboratory;
  int _score;
  int _level;

  String get nickname => _nickname;
  String get name => _name;
  String get email => _email;
  String get laboratory => _laboratory;
  int get score => _score;
  int get level => _level;

  set score(int newScore) {
    _score = newScore;
  }

  set level(int newLevel) {
    _level = newLevel;
  }

  @override
  String toString() {
    return 'User(nickname: $_nickname, name: $_name, email: $_email, laboratory: $_laboratory, score: $_score, level: $_level)';
  }
}

// void main() {
//   // Example usage
//   User user = User(
//     nickname: 'johndoe',
//     name: 'John Doe',
//     email: 'john.doe@example.com',
//     laboratory: 'Physics Lab',
//     score: 1200,
//     level: 5,
//   );

//   print(user);

//   // Update score using setter
//   user.score = 1300;
//   print('Updated score: ${user.score}');

//   // Update level using setter
//   user.level = 6;
//   print('New level: ${user.level}');
// }