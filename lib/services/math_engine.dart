import 'package:math_expressions/math_expressions.dart';

class MathEngine {
  static final GrammarParser _parser = GrammarParser();
  static final ContextModel _context = ContextModel();

  static String evaluate(String expression) {
    try {
      expression = expression
          .replaceAll("π", "pi")
          .replaceAll("√", "sqrt");

      Expression exp = _parser.parse(expression);
      double eval = exp.evaluate(EvaluationType.REAL, _context);

      if (eval.isNaN || eval.isInfinite) return "Error";
      return eval.toStringAsPrecision(12);
    } catch (_) {
      return "Error";
    }
  }
}