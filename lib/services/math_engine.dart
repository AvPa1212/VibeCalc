import 'package:math_expressions/math_expressions.dart';

import 'deterministic_expression_engine.dart';

class MathEngine {
  static final GrammarParser _parser = GrammarParser();
  static final ContextModel _context = ContextModel();

  static String evaluate(String expression) {
    try {
      if (_isDeterministicCandidate(expression)) {
        final deterministic = DeterministicExpressionEngine.evaluate(
          expression,
          notation: InputNotation.infix,
        );
        final value = deterministic.displayValue;
        if (value != 'Error') {
          return value;
        }
      }

      expression = expression
          .replaceAll("π", "pi")
          .replaceAll("√", "sqrt");

      Expression exp = _parser.parse(expression);
      double eval = exp.evaluate(EvaluationType.REAL, _context);

      if (eval.isNaN || eval.isInfinite) return "Error";

      return _formatResult(eval);
    } catch (_) {
      return "Error";
    }
  }

  static bool _isDeterministicCandidate(String expression) {
    final sanitized = expression.replaceAll(' ', '');
    if (sanitized.isEmpty) return false;
    return RegExp(r'^[0-9+\-*/^().]+$').hasMatch(sanitized);
  }

  static String _formatResult(double value) {
    // Return integer representation when possible
    if (value == value.truncateToDouble() && value.abs() < 1e15) {
      return value.toInt().toString();
    }

    // Use up to 10 significant digits and strip trailing zeros
    String result = value.toStringAsPrecision(10);
    if (result.contains('.')) {
      result = result.replaceAll(RegExp(r'0+$'), '');
      result = result.replaceAll(RegExp(r'\.$'), '');
    }
    return result;
  }
}