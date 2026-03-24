import 'package:flutter/material.dart';

import '../screens/home_screen.dart';
import '../screens/graph_screen.dart';
import '../screens/converter_screen.dart';
import '../screens/scientific_layout.dart';
import '../screens/settings_screen.dart';

class AppRouter {
  /// Route Names
  static const String home = '/';
  static const String graph = '/graph';
  static const String unit = '/unit';
  static const String scientific = '/scientific';
  static const String settingsRoute = '/settings';

  /// Route Generator
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return _buildRoute(const HomeScreen());

      case graph:
        return _buildRoute(const GraphScreen());

      case unit:
        return _buildRoute(const ConverterScreen());

      case scientific:
        return _buildRoute(const ScientificLayout());

      case settingsRoute:
        return _buildRoute(const SettingsScreen());

      default:
        return _errorRoute();
    }
  }

  /// Standard Page Route
  static PageRoute _buildRoute(Widget page) {
    return MaterialPageRoute(
      builder: (_) => page,
    );
  }

  /// Error Route
  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        body: Center(
          child: Text(
            '404 - Page Not Found',
            style: const TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}