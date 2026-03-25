import 'package:flutter/material.dart';
import '../services/math_engine.dart';
import '../core/constants.dart';
import '../services/rewrite_trace_engine.dart';

class CalculatorModel extends ChangeNotifier {
  String expression = "";
  String result = "0";
  List<String> history = [];
  List<RewriteStep> lastRewriteSteps = [];
  String lastEvaluatedInput = "";

  void add(String value) {
    expression += value;
    result = "0";
    lastRewriteSteps = [];
    lastEvaluatedInput = "";
    notifyListeners();
  }

  void setExpression(String value) {
    expression = value;
    result = "0";
    lastRewriteSteps = [];
    lastEvaluatedInput = "";
    notifyListeners();
  }

  void deleteLast() {
    if (expression.isNotEmpty) {
      expression = expression.substring(0, expression.length - 1);
      result = "0";
      lastRewriteSteps = [];
      lastEvaluatedInput = "";
      notifyListeners();
    }
  }

  void clear() {
    expression = "";
    result = "0";
    lastRewriteSteps = [];
    lastEvaluatedInput = "";
    notifyListeners();
  }

  void addPercent() {
    if (expression.isNotEmpty) {
      final value = double.tryParse(expression);
      if (value != null) {
        expression = (value / 100).toString();
        result = "0";
        lastRewriteSteps = [];
        lastEvaluatedInput = "";
        notifyListeners();
      }
    }
  }

  void evaluate() {
    if (expression.isEmpty) return;
    final input = expression;
    final trace = RewriteTraceEngine.trace(input);
    final r = MathEngine.evaluate(input);
    if (r != "Error") {
      final entry = "$input = $r";
      history.insert(0, entry);
      if (history.length > AppConstants.maxHistory) {
        history.removeLast();
      }
      expression = r;
    }
    lastEvaluatedInput = input;
    lastRewriteSteps = trace.steps;
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