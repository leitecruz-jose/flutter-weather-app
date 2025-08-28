import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:weather_app/models/user_model.dart';

import 'package:weather_app/services/user_service.dart';

class AuthService {
  //in this app, that doesn't have a backend, we store the secret out here in the open
  static const String JWT_SECRET = 'my-not-that-secret-jwt-secret';
  final _storage = const FlutterSecureStorage();

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

    final payload = {
      'username': username,
      'exp':
          DateTime.now().add(const Duration(days: 7)).millisecondsSinceEpoch ~/
          1000,
    };

    final jwt = JWT(payload);
    final jwtToken = jwt.sign(SecretKey(JWT_SECRET));

    await _storage.write(key: 'jwt_token', value: jwtToken);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: 'jwt_token');
  }

  Future<bool> checkIfTokenIsValid() async {
    final token = await _storage.read(key: 'jwt_token');

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
      await deleteToken();
      return false;
    } on JWTException {
      await deleteToken();
      return false;
    } catch (e) {
      await deleteToken();
      return false;
    }
  }
}
