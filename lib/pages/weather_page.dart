import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/services/weather_service.dart';
import 'package:weather_app/services/auth_service.dart';
import 'package:weather_app/pages/login_page.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  static String? apiKey = dotenv.env['WEATHER_API_KEY'];
  final _weatherService = WeatherService(apiKey!);
  Weather? _weather;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    Map coordinates = await _weatherService.getCurrentCoordinates();

    try {
      var weather = await _weatherService.getWeather(
        coordinates["lat"],
        coordinates["lon"],
      );
      _weather = weather;
    } catch (e) {
      rethrow;
    }
  }

  void _logout(BuildContext context) async {
    final authService = AuthService();
    await authService.deleteToken();

    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.blue),
            onPressed: () => _logout(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Center(
        child: FutureBuilder(
          future: _fetchWeather(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_on, size: 50.0, color: Colors.blue),
                  Text(
                    _weather!.cityName.toString(),
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 20,
                      fontFamily: 'Roboto',
                    ),
                  ),
                  Text(
                    'Temperature: ${_weather!.temperature.toString()}ºC',
                    style: TextStyle(fontSize: 16, fontFamily: 'Roboto'),
                  ),
                  Text(
                    'Condition: ${_weather!.mainCondition.toString()}',
                    style: TextStyle(fontSize: 16, fontFamily: 'Roboto'),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
