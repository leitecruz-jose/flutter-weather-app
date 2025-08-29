# Flutter Weather App

A cross-platform application (Mobile and Web) developed in Flutter. The app features a complete user authentication flow with a mocked backend using JWT, secure token storage, and a screen that displays the weather for the user's current location.

## Getting Started

### Prerequisites:
- Flutter SDK (version 3.x or higher)
- A code editor like VS Code or Android Studio.


### Setup:
- Clone the repository:
```console
git clone https://github.com/leitecruz-jose/flutter-weather-app.git
cd flutter-weather-app
```

- Install dependencies:
```console
flutter pub get
```

- Configure the API Key:
This project uses the OpenWeatherMap API to fetch weather data. You will need a free API key. Create an account on [OpenWeatherMap](https://home.openweathermap.org/users/sign_up) and get your API Key.
This project uses a .env file to manage secret keys, such as the OpenWeatherMap API key. This file is committed to the repository but you need to:
- Add your API Key: Open the .env file and add your OpenWeatherMap API key in the WEATHER_API_KEY key.

After adding this, be sure to run flutter pub get again in your terminal.
