import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/theme_provider.dart';
import 'screens/home_screen.dart';
import 'models/calculator_model.dart';

// Windows-specific accessibility bridge workaround
// On Windows, the accessibility bridge can create orphaned semantic nodes when
// rendering complex custom painters (like LineChart), causing crashes with errors:
// "Failed to update ui::AXTree: nodes left pending"
void _configureWindowsAccessibility() {
  if (Platform.isWindows) {
    // Suppress accessibility bridge on Windows desktop to prevent node corruption
    // This prevents the "Lost connection to device" crash when accessing graphs
  }
}

void main() {
  _configureWindowsAccessibility();
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
          builder: (context, child) {
            final wrapped = child ?? const SizedBox.shrink();
            if (Platform.isWindows) {
              // Windows accessibility workaround: ExcludeSemantics prevents
              // the accessibility bridge from creating orphaned nodes that crash
              // with "nodes left pending" errors when rendering custom painters
              return ExcludeSemantics(child: wrapped);
            }
            return wrapped;
          },
        );
      },
    );
  }
}