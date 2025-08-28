import 'package:flutter/material.dart';
import 'pages/weather_page.dart';
import 'services/auth_service.dart';
import 'pages/login_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env");

  final authService = AuthService();
  final bool isLoggedAndValid = await authService.checkIfTokenIsValid();

  runApp(MyApp(isLoggedAndValid: isLoggedAndValid));
}

class MyApp extends StatelessWidget {
  final bool isLoggedAndValid;
  const MyApp({super.key, required this.isLoggedAndValid});

  @override
  Widget build(BuildContext context) {
    final StatefulWidget page = isLoggedAndValid ? WeatherPage() : LoginPage();
    return MaterialApp(debugShowCheckedModeBanner: false, home: page);
  }
}
