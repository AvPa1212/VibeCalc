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

  void _onButtonTap(String value) {
    setState(() {
      if (value == 'AC') {
        _expression = '';
        _result = '0';
      } else if (value == '⌫') {
        if (_expression.isNotEmpty) {
          _expression =
              _expression.substring(0, _expression.length - 1);
        }
      } else if (value == '=') {
        try {
          _result = _engine.evaluate(_expression);
        } catch (e) {
          _result = 'Error';
        }
      } else {
        _expression += value;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// DISPLAY PANEL
        Expanded(
          flex: 2,
          child: DisplayPanel(
            expression: _expression,
            result: _result,
          ),
        ),

        /// BUTTON GRID
        Expanded(
          flex: 5,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final buttonHeight =
                    constraints.maxHeight / 6 - 10;

                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _buildButtons(buttonHeight),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildButtons(double height) {
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
        width: 70,
        height: height,
        child: AnimatedCalcButton(
          label: label,
          onTap: () => _onButtonTap(_mapLabel(label)),
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