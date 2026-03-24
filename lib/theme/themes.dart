import 'package:flutter/material.dart';

enum AppThemeMode { neon, sunset }

class AppThemeOption {
  final AppThemeMode mode;
  final String name;
  final String subtitle;
  final Color accent;

  const AppThemeOption({
    required this.mode,
    required this.name,
    required this.subtitle,
    required this.accent,
  });
}

class AppThemes {
  static const options = [
    AppThemeOption(
      mode: AppThemeMode.neon,
      name: 'Neon Grid',
      subtitle: 'Cool cyan highlights for technical work',
      accent: Color(0xFF15E8FF),
    ),
    AppThemeOption(
      mode: AppThemeMode.sunset,
      name: 'Sunset Ember',
      subtitle: 'Warm amber contrast for long sessions',
      accent: Color(0xFFFFA457),
    ),
  ];

  static ThemeData resolve(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.neon:
        return _buildTheme(
          seed: const Color(0xFF15E8FF),
          scaffold: const Color(0xFF090E16),
        );
      case AppThemeMode.sunset:
        return _buildTheme(
          seed: const Color(0xFFFFA457),
          scaffold: const Color(0xFF1A1010),
        );
    }
  }

  static ThemeData _buildTheme({
    required Color seed,
    required Color scaffold,
  }) {
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffold,
      appBarTheme: AppBarTheme(
        backgroundColor: scaffold,
        foregroundColor: scheme.onSurface,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: scaffold,
        selectedItemColor: scheme.primary,
        unselectedItemColor: scheme.onSurface.withValues(alpha: 0.7),
      ),
    );
  }
}
