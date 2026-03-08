import 'package:flutter/material.dart';
import 'themes.dart';

class ThemeProvider extends ChangeNotifier {
  String _currentThemeName = 'VibeDark';

  ThemeData get currentTheme =>
      AppThemes.themes[_currentThemeName] ?? AppThemes.vibeDark;

  String get currentThemeName => _currentThemeName;

  static List<String> get themeNames => AppThemes.themes.keys.toList();

  static Color themeColorFor(String name) {
    return AppThemes.themes[name]?.primaryColor ?? Colors.cyanAccent;
  }

  void setTheme(String name) {
    if (AppThemes.themes.containsKey(name)) {
      _currentThemeName = name;
      notifyListeners();
    }
  }

  // Backward-compatible helpers
  void setNeon() => setTheme('VibeDark');
  void setSunset() => setTheme('Sunset');
}