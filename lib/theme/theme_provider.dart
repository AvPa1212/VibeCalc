import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeData currentTheme = neon;

  static final neon = ThemeData.dark().copyWith(
    primaryColor: Colors.cyanAccent,
    scaffoldBackgroundColor: const Color(0xFF0F0F1B),
  );

  static final sunset = ThemeData.dark().copyWith(
    primaryColor: Colors.orangeAccent,
    scaffoldBackgroundColor: const Color(0xFF1A0F0F),
  );

  void setNeon() {
    currentTheme = neon;
    notifyListeners();
  }

  void setSunset() {
    currentTheme = sunset;
    notifyListeners();
  }
}