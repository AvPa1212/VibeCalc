import 'package:flutter/material.dart';
import 'themes.dart';

class ThemeProvider extends ChangeNotifier {
  AppThemeMode _currentMode = AppThemeMode.neon;

  ThemeData get currentTheme => AppThemes.resolve(_currentMode);

  AppThemeMode get currentMode => _currentMode;

  void setTheme(AppThemeMode mode) {
    if (mode == _currentMode) return;
    _currentMode = mode;
    notifyListeners();
  }

  void setNeon() {
    setTheme(AppThemeMode.neon);
  }

  void setSunset() {
    setTheme(AppThemeMode.sunset);
  }
}