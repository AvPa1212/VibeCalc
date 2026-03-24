import 'package:flutter/material.dart';
import '../widgets/theme_picker.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Appearance', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 6),
            Text(
              'Pick a visual style for the calculator.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            const Expanded(child: ThemePicker()),
          ],
        ),
      ),
    );
  }
}