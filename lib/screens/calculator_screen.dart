import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/calculator_model.dart';
import '../widgets/animated_calc_button.dart';
import '../widgets/display_panel.dart';
import '../widgets/history_drawer.dart';
import 'about_screen.dart';

class CalculatorScreen extends StatelessWidget {
  const CalculatorScreen({super.key});

  static const String _backspaceToken = '\u232b';

  @override
  Widget build(BuildContext context) {
    final model = context.watch<CalculatorModel>();
    final theme = Theme.of(context);

    const buttons = [
      'AC', _backspaceToken, '%', '/',
      '7', '8', '9', '*',
      '4', '5', '6', '-',
      '1', '2', '3', '+',
      '(', '0', '.', '=',
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('VibeCalc'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.alt_route),
            tooltip: 'Rewrite Trace',
            onPressed: () => _showRewriteTrace(context, model),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'About',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AboutScreen()),
            ),
          ),
          Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.history),
              tooltip: 'History',
              onPressed: () => Scaffold.of(ctx).openEndDrawer(),
            ),
          ),
        ],
      ),
      endDrawer: HistoryDrawer(
        onItemSelected: (entry) {
          final parts = entry.split(' = ');
          if (parts.length == 2) {
            model.setExpression(parts[1]);
          }
        },
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Flexible(
            flex: 1,
            child: DisplayPanel(
              expression: model.expression,
              result: model.result,
              onDelete: model.deleteLast,
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 6),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _QuickActionChip(
                        label: 'MR',
                        onTap: () => _handleMemoryRecall(context, model),
                        highlight: model.hasMemory,
                      ),
                      _QuickActionChip(
                        label: 'M+',
                        onTap: () => _handleMemoryAdd(context, model),
                      ),
                      _QuickActionChip(
                        label: 'M-',
                        onTap: () => _handleMemorySubtract(context, model),
                      ),
                      _QuickActionChip(
                        label: 'MC',
                        onTap: model.memoryClear,
                      ),
                      _QuickActionChip(
                        label: 'ANS',
                        onTap: model.addAnswer,
                      ),
                      _QuickActionChip(
                        label: '\u00B1',
                        onTap: model.toggleSign,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      const columns = 4;
                      const rows = 5;
                      const spacing = 2.0;

                      final itemWidth =
                          (constraints.maxWidth - (columns - 1) * spacing) / columns;
                      final itemHeight =
                          (constraints.maxHeight - (rows - 1) * spacing) / rows;
                      final ratio = itemWidth / itemHeight;

                      return GridView.builder(
                        padding: EdgeInsets.zero,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: buttons.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          childAspectRatio: ratio,
                          crossAxisSpacing: spacing,
                          mainAxisSpacing: spacing,
                        ),
                        itemBuilder: (_, i) {
                          final label = buttons[i];
                          final isOperator = ['/', '*', '-', '+'].contains(label);
                          final isEquals = label == '=';
                          final isSpecial = ['AC', _backspaceToken, '%'].contains(label);

                          Color? btnColor;
                          if (isEquals) btnColor = theme.primaryColor;
                          if (isSpecial) {
                            btnColor = theme.colorScheme.surface.withValues(alpha: 0.6);
                          }

                          return AnimatedCalcButton(
                            label: label,
                            onTap: () => _handleButton(label, model),
                            isOperator: isOperator || isEquals,
                            color: btnColor,
                            textColor: isEquals ? Colors.black : null,
                            glow: isEquals,
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleButton(String label, CalculatorModel model) {
    switch (label) {
      case 'AC':
        model.clear();
        return;
      case _backspaceToken:
        model.deleteLast();
        return;
      case '=':
        model.evaluate();
        return;
      case '%':
        model.addPercent();
        return;
      default:
        model.add(label);
        return;
    }
  }

  void _handleMemoryRecall(BuildContext context, CalculatorModel model) {
    if (!model.memoryRecall()) {
      _showHint(context, 'Memory is empty');
    }
  }

  void _handleMemoryAdd(BuildContext context, CalculatorModel model) {
    if (!model.memoryAddFromCurrent()) {
      _showHint(context, 'Enter a valid value first');
    }
  }

  void _handleMemorySubtract(BuildContext context, CalculatorModel model) {
    if (!model.memorySubtractFromCurrent()) {
      _showHint(context, 'Enter a valid value first');
    }
  }

  void _showHint(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(milliseconds: 900)),
    );
  }

  void _showRewriteTrace(BuildContext context, CalculatorModel model) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) {
        final steps = model.lastRewriteSteps;
        final titleInput = model.lastEvaluatedInput.isEmpty
            ? 'No evaluation yet'
            : model.lastEvaluatedInput;

        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(ctx).size.height * 0.7,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Text(
                    'Rewrite Trace',
                    style: Theme.of(ctx).textTheme.titleLarge,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Text(
                    titleInput,
                    style: Theme.of(ctx).textTheme.bodyMedium,
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: steps.isEmpty
                      ? const Center(
                          child: Text('No rewrite steps for the last evaluation.'),
                        )
                      : ListView.builder(
                          itemCount: steps.length,
                          itemBuilder: (_, i) {
                            final step = steps[i];
                            return ListTile(
                              leading: Text('${i + 1}'),
                              title: Text(step.ruleName),
                              subtitle: Text('${step.before} -> ${step.after}'),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool highlight;

  const _QuickActionChip({
    required this.label,
    required this.onTap,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      backgroundColor: highlight
          ? theme.colorScheme.primary.withValues(alpha: 0.22)
          : theme.colorScheme.surface.withValues(alpha: 0.55),
      side: BorderSide(
        color: highlight
            ? theme.colorScheme.primary.withValues(alpha: 0.8)
            : theme.colorScheme.outline.withValues(alpha: 0.5),
      ),
      labelStyle: theme.textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
