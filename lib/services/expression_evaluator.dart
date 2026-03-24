
class ExpressionEvaluator {
  static String evaluate(String expression) {
    expression = expression.replaceAll("^", "**");
    return _simpleEval(expression).toString();
  }

  static num _simpleEval(String exp) {
    return double.parse(exp);
  }
}