import 'package:flutter/material.dart';
import 'calculator_screen.dart';
import 'graph_screen.dart';
import 'converter_screen.dart';
import 'settings_screen.dart';
import 'advanced_workspace_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  late final Map<int, Widget> _screenCache = {};

  Widget _buildScreen(int index) {
    if (_screenCache.containsKey(index)) {
      return _screenCache[index]!;
    }

    final screen = switch (index) {
      0 => const CalculatorScreen(),
      1 => const GraphScreen(),
      2 => const ConverterScreen(),
      3 => const AdvancedWorkspaceScreen(),
      4 => const SettingsScreen(),
      _ => const CalculatorScreen(),
    };

    _screenCache[index] = screen;
    return screen;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildScreen(_index),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.calculate_outlined),
              activeIcon: Icon(Icons.calculate),
              label: 'Calc'),
          BottomNavigationBarItem(
              icon: Icon(Icons.show_chart_outlined),
              activeIcon: Icon(Icons.show_chart),
              label: 'Graph'),
          BottomNavigationBarItem(
              icon: Icon(Icons.swap_horiz_outlined),
              activeIcon: Icon(Icons.swap_horiz),
              label: 'Convert'),
            BottomNavigationBarItem(
              icon: Icon(Icons.hub_outlined),
              activeIcon: Icon(Icons.hub),
              label: 'Workspace'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Settings'),
        ],
      ),
    );
  }
}