import 'package:flutter/material.dart';

class AppThemes {
  static ThemeData get vibeDark => ThemeData.dark().copyWith(
        primaryColor: Colors.cyanAccent,
        scaffoldBackgroundColor: const Color(0xFF0F0F1B),
        colorScheme: const ColorScheme.dark(
          primary: Colors.cyanAccent,
          secondary: Colors.cyan,
          surface: Color(0xFF1A1A2E),
          onSurface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A1A2E),
          foregroundColor: Colors.cyanAccent,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF1A1A2E),
          selectedItemColor: Colors.cyanAccent,
          unselectedItemColor: Colors.white54,
        ),
      );

  static ThemeData get sunset => ThemeData.dark().copyWith(
        primaryColor: Colors.orangeAccent,
        scaffoldBackgroundColor: const Color(0xFF1A0F0F),
        colorScheme: const ColorScheme.dark(
          primary: Colors.orangeAccent,
          secondary: Colors.deepOrange,
          surface: Color(0xFF2E1A1A),
          onSurface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2E1A1A),
          foregroundColor: Colors.orangeAccent,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF2E1A1A),
          selectedItemColor: Colors.orangeAccent,
          unselectedItemColor: Colors.white54,
        ),
      );

  static ThemeData get midnight => ThemeData.dark().copyWith(
        primaryColor: Colors.purpleAccent,
        scaffoldBackgroundColor: const Color(0xFF0D0D1A),
        colorScheme: const ColorScheme.dark(
          primary: Colors.purpleAccent,
          secondary: Colors.deepPurple,
          surface: Color(0xFF1A1A2E),
          onSurface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A1A2E),
          foregroundColor: Colors.purpleAccent,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF1A1A2E),
          selectedItemColor: Colors.purpleAccent,
          unselectedItemColor: Colors.white54,
        ),
      );

  static ThemeData get forest => ThemeData.dark().copyWith(
        primaryColor: Colors.greenAccent,
        scaffoldBackgroundColor: const Color(0xFF0A1A0A),
        colorScheme: const ColorScheme.dark(
          primary: Colors.greenAccent,
          secondary: Colors.green,
          surface: Color(0xFF1A2E1A),
          onSurface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A2E1A),
          foregroundColor: Colors.greenAccent,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF1A2E1A),
          selectedItemColor: Colors.greenAccent,
          unselectedItemColor: Colors.white54,
        ),
      );

  static final Map<String, ThemeData> themes = {
    'VibeDark': vibeDark,
    'Sunset': sunset,
    'Midnight': midnight,
    'Forest': forest,
  };
}

