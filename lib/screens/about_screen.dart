import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            CircleAvatar(
              radius: 48,
              backgroundColor: theme.primaryColor.withValues(alpha: 0.2),
              child: Icon(Icons.calculate,
                  size: 48, color: theme.primaryColor),
            ),
            const SizedBox(height: 16),
            Text(
              'VibeCalc',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.primaryColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Version 1.0.0',
              style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
            ),
            const SizedBox(height: 32),
            _FeatureTile(
              icon: Icons.calculate,
              title: 'Standard Calculator',
              description: 'Perform everyday arithmetic with a clean, '
                  'animated interface.',
              color: theme.primaryColor,
            ),
            _FeatureTile(
              icon: Icons.science,
              title: 'Scientific Mode',
              description: 'sin, cos, tan, log, ln, √ and more.',
              color: theme.primaryColor,
            ),
            _FeatureTile(
              icon: Icons.show_chart,
              title: 'Graph Plotter',
              description: 'Plot any f(x) expression interactively.',
              color: theme.primaryColor,
            ),
            _FeatureTile(
              icon: Icons.swap_horiz,
              title: 'Unit Converter',
              description:
                  'Convert between length, mass, temperature, and more.',
              color: theme.primaryColor,
            ),
            _FeatureTile(
              icon: Icons.functions,
              title: 'Calculus Tools',
              description: 'Numerical derivative and definite integral.',
              color: theme.primaryColor,
            ),
            _FeatureTile(
              icon: Icons.grid_on,
              title: 'Matrix Calculator',
              description: '2×2 determinant and other matrix operations.',
              color: theme.primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _FeatureTile({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
