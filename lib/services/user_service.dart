import 'package:weather_app/models/user_model.dart';

class UserService {
  final List<User> users = [];

  final String username;
  UserService(this.username);

  void addUser(User user) {
    users.add(user
    );
  }

}
