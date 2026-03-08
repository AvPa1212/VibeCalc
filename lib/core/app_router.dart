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
  static const String settings = '/settings';

  /// Route Generator
  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case home:
        return _buildRoute(const HomeScreen());

      case graph:
        return _buildRoute(const GraphScreen());

      case unit:
        return _buildRoute(const ConverterScreen());

      case scientific:
        return _buildRoute(const ScientificLayout());

      case settings:
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
      builder: (_) => const Scaffold(
        body: Center(
          child: Text(
            '404 - Page Not Found',
            style: TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}