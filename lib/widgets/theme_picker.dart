import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_provider.dart';

class ThemePicker extends StatelessWidget {
  const ThemePicker({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: ThemeProvider.themeNames.map((name) {
        final isSelected = themeProvider.currentThemeName == name;
        final color = ThemeProvider.themeColorFor(name);

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          color: isSelected
              ? color.withOpacity(0.15)
              : theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isSelected ? color : Colors.transparent,
              width: 2,
            ),
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: color,
              radius: 18,
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.black, size: 18)
                  : null,
            ),
            title: Text(
              name,
              style: theme.textTheme.titleMedium?.copyWith(
                color: isSelected ? color : theme.colorScheme.onSurface,
                fontWeight:
                    isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            trailing: isSelected
                ? Icon(Icons.radio_button_checked, color: color)
                : const Icon(Icons.radio_button_unchecked),
            onTap: () => themeProvider.setTheme(name),
          ),
        );
      }).toList(),
    );
  }
}
