import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/theme_provider.dart';
import '../theme/themes.dart';

class ThemePicker extends StatelessWidget {
  const ThemePicker({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ThemeProvider>();
    final theme = Theme.of(context);

    return ListView.separated(
      shrinkWrap: true,
      itemCount: AppThemes.options.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final option = AppThemes.options[index];
        final selected = provider.currentMode == option.mode;

        return InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => context.read<ThemeProvider>().setTheme(option.mode),
          child: Ink(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: selected ? 0.5 : 0.28),
              border: Border.all(
                color: selected
                    ? option.accent
                    : theme.colorScheme.outline.withValues(alpha: 0.35),
                width: selected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: option.accent,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(option.name, style: theme.textTheme.titleMedium),
                      const SizedBox(height: 2),
                      Text(
                        option.subtitle,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Icon(
                  selected
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: selected ? option.accent : theme.colorScheme.outline,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
