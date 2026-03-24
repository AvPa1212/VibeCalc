import 'package:flutter/material.dart';
import '../services/complex_engine.dart';
import '../widgets/animated_calc_button.dart';
import '../widgets/display_panel.dart';

class ScientificLayout extends StatefulWidget {
  const ScientificLayout({super.key});

  @override
  State<ScientificLayout> createState() => _ScientificLayoutState();
}

class _ScientificLayoutState extends State<ScientificLayout> {
  final ComplexEngine _engine = ComplexEngine();
  String _expression = '';
  String _result = '0';

  void _onButtonTap(String label) {
    setState(() {
      if (label == 'AC') {
        _expression = '';
        _result = '0';
      } else if (label == '⌫') {
        if (_expression.isNotEmpty) {
          _expression = _expression.substring(0, _expression.length - 1);
        }
      } else if (label == '=') {
        try {
          _result = _engine.evaluate(_expression);
        } catch (_) {
          _result = 'Error';
        }
      } else {
        _expression += _mapLabel(label);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Display panel.
        Expanded(
          flex: 2,
          child: DisplayPanel(
            expression: _expression,
            result: _result,
            onDelete: () => _onButtonTap('⌫'),
            onExpressionChanged: (value) {
              setState(() => _expression = value);
            },
          ),
        ),

        // Responsive button grid.
        Expanded(
          flex: 5,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: LayoutBuilder(
              builder: (context, constraints) {
                const spacing = 8.0;
                final crossAxisCount =
                    (constraints.maxWidth / 76).floor().clamp(4, 6);
                final buttonWidth =
                    (constraints.maxWidth - (crossAxisCount - 1) * spacing) /
                        crossAxisCount;
                final rows = (29 / crossAxisCount).ceil();
                final buttonHeight =
                    (constraints.maxHeight - (rows - 1) * spacing) / rows;

                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: _buildButtons(buttonHeight, buttonWidth),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildButtons(double height, double width) {
    final buttons = [
      'sin', 'cos', 'tan', 'π', 'e',
      'log', 'ln', '^', '√', '(',
      ')', '7', '8', '9', '/',
      '4', '5', '6', '*', '-',
      '1', '2', '3', '+', '.',
      '0', 'AC', '⌫', '=',
    ];

    return buttons.map((label) {
      return SizedBox(
        width: width,
        height: height,
        child: AnimatedCalcButton(
          label: label,
          onTap: () => _onButtonTap(label),
        ),
      );
    }).toList();
  }

  /// Maps display labels to engine-safe syntax
  String _mapLabel(String label) {
    switch (label) {
      case 'π':
        return 'pi';
      case '√':
        return 'sqrt(';
      case 'sin':
      case 'cos':
      case 'tan':
      case 'log':
      case 'ln':
        return '$label(';
      default:
        return label;
    }
  }
}