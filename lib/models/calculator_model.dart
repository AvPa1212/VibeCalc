import 'package:flutter/material.dart';
import '../services/math_engine.dart';
import '../core/constants.dart';

class CalculatorModel extends ChangeNotifier {
  String expression = "";
  String result = "0";
  List<String> history = [];

  void add(String value) {
    expression += value;
    notifyListeners();
  }

  void setExpression(String value) {
    expression = value;
    result = "0";
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

  void addPercent() {
    if (expression.isNotEmpty) {
      final num = double.tryParse(expression);
      if (num != null) {
        expression = (num / 100).toString();
        notifyListeners();
      }
    }
  }

  void evaluate() {
    if (expression.isEmpty) return;
    final r = MathEngine.evaluate(expression);
    if (r != "Error") {
      final entry = "$expression = $r";
      history.insert(0, entry);
      if (history.length > AppConstants.maxHistory) {
        history.removeLast();
      }
      expression = r;
    }
    result = r;
    notifyListeners();
  }

  void clearHistory() {
    history.clear();
    notifyListeners();
  }

  void removeHistoryAt(int index) {
    if (index >= 0 && index < history.length) {
      history.removeAt(index);
      notifyListeners();
    }
  }
}