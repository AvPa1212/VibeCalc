import 'package:flutter/material.dart';
import '../services/math_engine.dart';

class CalculatorModel extends ChangeNotifier {
  String expression = "";
  String result = "0";
  List<String> history = [];

  void add(String value) {
    expression += value;
    notifyListeners();
  }

  void deleteLast() {
    if (expression.isNotEmpty) {
      expression = expression.substring(0, expression.length - 1);
      notifyListeners();
    }
  }

  void clear() {
    expression = "";
    result = "0";
    notifyListeners();
  }

  void evaluate() {
    result = MathEngine.evaluate(expression);
    if (result != "Error") {
      history.insert(0, "$expression = $result");
    }
    notifyListeners();
  }
}