
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