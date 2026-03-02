import 'package:math_expressions/math_expressions.dart';
import 'math_engine.dart';

class CalculusEngine {
  static double derivative(String expr, double x) {
    const h = 0.00001;
    double f1 = _evaluate(expr, x + h);
    double f2 = _evaluate(expr, x - h);
    return (f1 - f2) / (2 * h);
  }

  static double integral(String expr, double a, double b) {
    int n = 1000;
    double h = (b - a) / n;
    double sum = 0;
    for (int i = 0; i < n; i++) {
      double x = a + i * h;
      sum += _evaluate(expr, x) * h;
    }
    return sum;
  }

  static double _evaluate(String expr, double x) {
    return double.tryParse(
            MathEngine.evaluate(expr.replaceAll("x", "$x"))) ??
        0;
  }
}