import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_app/models/user_model.dart';
import 'dart:convert';

import 'package:weather_app/services/user_service.dart';

class AuthService {
  //in this app, that doesn't have a backend, we store the secret out here in the open
  static const String JWT_SECRET = 'my-not-that-secret-jwt-secret';

  Future<bool> login(String username, String password) async {
    final userService = UserService();
    final userObject = User(username: username, password: password);

    //check if given user info is valid and exists
    final isUserValid = userService.checkIfUserIsValid(userObject);

    if (!isUserValid) {
      return false;
    }

    //generates jwt
    await _generateAndStoreJwtToken(username);
    return true;
  }

  Future<void> _generateAndStoreJwtToken(String username) async {
    final prefs = await SharedPreferences.getInstance();

    final payload = {
      'username': username,
      'exp':
          DateTime.now().add(const Duration(days: 7)).millisecondsSinceEpoch ~/
          1000,
    };

    final jwt = JWT(payload);
    final jwtToken = jwt.sign(SecretKey(JWT_SECRET));

    await prefs.setString('jwt_token', jwtToken);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }

  Future<bool> checkIfTokenIsValid() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('jwt_token');

    if (token == null || token.isEmpty) {
      return false;
    }

    return await _validateJwt(token);
  }

  Future<bool> _validateJwt(String token) async {
    try {
      JWT.verify(token, SecretKey(JWT_SECRET));
      return true;
    } on JWTExpiredException {
      await logout();
      return false;
    } on JWTException {
      await logout();
      return false;
    } catch (e) {
      await logout();
      return false;
    }
  }
}
