import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/theme_provider.dart';
import 'screens/home_screen.dart';
import 'models/calculator_model.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => CalculatorModel()),
      ],
      child: const VibeCalc(),
    ),
  );
}

class VibeCalc extends StatelessWidget {
  const VibeCalc({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (_, theme, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: theme.currentTheme,
          home: const HomeScreen(),
        );
      },
    );
  }
}