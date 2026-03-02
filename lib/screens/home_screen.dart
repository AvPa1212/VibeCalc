import 'package:flutter/material.dart';
import 'calculator_screen.dart';
import 'graph_screen.dart';
import 'converter_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int index = 0;

  final screens = const [
    CalculatorScreen(),
    GraphScreen(),
    ConverterScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) => setState(() => index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.calculate), label: "Calc"),
          BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: "Graph"),
          BottomNavigationBarItem(icon: Icon(Icons.swap_horiz), label: "Convert"),
          BottomNavigationBarItem(icon: Icon(Icons.palette), label: "Theme"),
        ],
      ),
    );
  }
}