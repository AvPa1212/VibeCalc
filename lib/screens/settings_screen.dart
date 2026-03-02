import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.read<ThemeProvider>();

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
              onPressed: theme.setNeon, child: const Text("Neon")),
          ElevatedButton(
              onPressed: theme.setSunset, child: const Text("Sunset")),
        ],
      ),
    );
  }
}