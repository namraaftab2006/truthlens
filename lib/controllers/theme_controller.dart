import 'package:flutter/material.dart';
import '../utils/constants.dart';

class ThemeController extends ChangeNotifier {
  int _themeIndex = 0;

  int get themeIndex => _themeIndex;

  ThemeMode get currentThemeMode {
    switch (_themeIndex) {
      case 1:
        return ThemeMode.light;
      case 2:
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  ThemeData get currentTheme {
    switch (_themeIndex) {
      case 1:
        return _lightTheme;
      case 2:
        return _darkTheme;
      default:
        return _defaultTheme;
    }
  }

  void toggleTheme() {
    _themeIndex = (_themeIndex + 1) % 3;
    notifyListeners();
  }


  ThemeData get _defaultTheme => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: Constants.defaultBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: Constants.accentColor,
      foregroundColor: Colors.white,
    ),
    cardColor: Colors.white,
    iconTheme: const IconThemeData(color: Colors.black),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black),
      bodyMedium: TextStyle(color: Colors.black87),
    ),
  );


  ThemeData get _lightTheme => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: Constants.lightBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
    ),
    cardColor: Colors.white,
    iconTheme: const IconThemeData(color: Colors.black),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black),
      bodyMedium: TextStyle(color: Colors.black87),
    ),
  );


  ThemeData get _darkTheme => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Constants.darkBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
    ),
    cardColor: Colors.grey[900],
    iconTheme: const IconThemeData(color: Colors.white),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white70),
    ),
  );


  IconData get themeIcon {
    switch (_themeIndex) {
      case 1:
        return Icons.light_mode; // currently Light
      case 2:
        return Icons.dark_mode; // currently Dark
      default:
        return Icons.brightness_auto; // Default beige
    }
  }
}
