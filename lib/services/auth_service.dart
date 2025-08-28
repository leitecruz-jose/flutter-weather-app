import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class AuthService {
  //in this app, that doesn't have a backend, we store the secret out here in the open
  static const String JWT_SECRET = 'my-not-that-secret-jwt-secret';

  Future<bool> registerUser(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();

    final usersJson = prefs.getString('user_database') ?? '[]';
    List users = jsonDecode(usersJson);

    // username exists
    if (users.any((user) => user['username'] == username)) {
      return false;
    }

    // hash the password and add new user
    final hashedPassword = _hashPassword(password);
    users.add({'username': username, 'password': hashedPassword});

    // save updated users list
    prefs.setString('user_database', jsonEncode(users));

    return true;
  }

  Future<bool> login(String username, String password) async {
    
      

    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString('user_database');

    if (usersJson == null) {
      return false;
    }

    List users = jsonDecode(usersJson);
    final user = users.firstWhere(
      (user) => user['username'] == username,
      orElse: () => null,
    );

    //invalid credentials
    if (user == null || user['password'] != _hashPassword(password)) {
      return false;
    }

    //generates jwt
    await _generateAndStoreJwtToken(username, prefs);
    return true;
  }

  Future<void> _generateAndStoreJwtToken(
    String username,
    SharedPreferences prefs,
  ) async {
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

  String _hashPassword(String password) {
    final encoded = utf8.encode(password);
    final sha = sha256.convert(encoded);
    return sha.toString();
  }
}
