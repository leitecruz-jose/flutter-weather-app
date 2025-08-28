import 'package:weather_app/models/user_model.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class UserService {
  //singleton to ensure that the List users is not lost every time UserService is called
  factory UserService() {
    return _instance;
  }

  static final UserService _instance = UserService._internal();
  UserService._internal();

  final List _users = [];

  void addUser(User user) {
    _users.add(user);
  }

  List _getUsers() {
    return _users;
  }

  bool checkIfUserIsValid(User userObject) {
    if (_getUsers() == []) {
      return false;
    }

    final objectUsername = userObject.username.toString();
    final objectPassword = userObject.password.toString();

    final user = _getUsers().firstWhere(
      (userFromList) => userFromList.username.toString() == objectUsername,
      orElse: () => null,
    );

    //invalid credentials
    if (user == null || user.password != _hashPassword(objectPassword)) {
      return false;
    }

    return true;
  }

  Future<bool> registerUser(String username, String password) async {
    // username exists
    if (_users.any((user) => user.username == username)) {
      return false;
    }

    // hash the password and save new user in the users list
    final hashedPassword = _hashPassword(password);
    final user = User(username: username, password: hashedPassword);
    addUser(user);

    return true;
  }

  String _hashPassword(String password) {
    final encoded = utf8.encode(password);
    final sha = sha256.convert(encoded);
    return sha.toString();
  }
}
