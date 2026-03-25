import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../services/math_engine.dart';
import '../services/rewrite_trace_engine.dart';

class CalculatorModel extends ChangeNotifier {
  String expression = '';
  String result = '0';
  final List<String> history = [];
  List<RewriteStep> lastRewriteSteps = [];
  String lastEvaluatedInput = '';

  double _memory = 0;

  static const Set<String> _operators = {'+', '-', '*', '/', '^'};
  static const Set<String> _openValueTokens = {
    '(',
    'pi',
    'sqrt(',
    'sin(',
    'cos(',
    'tan(',
    'log(',
    'ln(',
  };

  bool get hasMemory => _memory != 0;
  String get memoryLabel => _formatNumber(_memory);

  void add(String value) {
    final token = _normalizeToken(value);
    if (token.isEmpty) return;

    if (_operators.contains(token)) {
      _appendOperator(token);
      return;
    }

    switch (token) {
      case '.':
        _appendDecimalPoint();
        return;
      case '(':
        _appendOpenParenthesis();
        return;
      case ')':
        _appendCloseParenthesis();
        return;
      default:
        _appendValue(token);
    }
  }

  void setExpression(String value) {
    expression = _normalizeExpression(value.trim());
    _resetTransient();
    notifyListeners();
  }

  void deleteLast() {
    if (expression.isNotEmpty) {
      expression = expression.substring(0, expression.length - 1);
      _resetTransient();
      notifyListeners();
    }
  }

  void clear() {
    expression = '';
    result = '0';
    lastRewriteSteps = [];
    lastEvaluatedInput = '';
    notifyListeners();
  }

  void addAnswer() {
    if (result == 'Error' || result.isEmpty) return;
    add(result);
  }

  void toggleSign() {
    if (expression.isEmpty) return;
    expression = expression.startsWith('-')
        ? expression.substring(1)
        : '-$expression';
    _resetTransient();
    notifyListeners();
  }

  void addPercent() {
    final value = _currentValue();
    if (value == null) return;
    expression = _formatNumber(value / 100);
    _resetTransient();
    notifyListeners();
  }

  bool memoryAddFromCurrent() {
    final value = _currentValue();
    if (value == null) return false;
    _memory += value;
    notifyListeners();
    return true;
  }

  bool memorySubtractFromCurrent() {
    final value = _currentValue();
    if (value == null) return false;
    _memory -= value;
    notifyListeners();
    return true;
  }

  bool memoryRecall() {
    if (!hasMemory) return false;
    add(_formatNumber(_memory));
    return true;
  }

  void memoryClear() {
    if (!hasMemory) return;
    _memory = 0;
    notifyListeners();
  }

  void evaluate() {
    if (expression.isEmpty) return;
    final input = _prepareExpression(expression);
    if (input.isEmpty) return;

    final trace = RewriteTraceEngine.trace(input);
    final evaluated = MathEngine.evaluate(input);
    if (evaluated != 'Error') {
      final entry = '$input = $evaluated';
      if (history.isEmpty || history.first != entry) {
        history.insert(0, entry);
      }
      if (history.length > AppConstants.maxHistory) {
        history.removeLast();
      }
      expression = evaluated;
    }
    lastEvaluatedInput = input;
    lastRewriteSteps = trace.steps;
    result = evaluated;
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

  void _appendOperator(String operator) {
    if (expression.isEmpty) {
      if (operator == '-') {
        expression = '-';
        _resetTransient();
        notifyListeners();
      }
      return;
    }

    if (_endsWithOperator()) {
      expression = '${expression.substring(0, expression.length - 1)}$operator';
      _resetTransient();
      notifyListeners();
      return;
    }

    if (expression.endsWith('(') && operator != '-') {
      return;
    }

    expression += operator;
    _resetTransient();
    notifyListeners();
  }

  void _appendDecimalPoint() {
    if (expression.isEmpty || _endsWithOperator() || expression.endsWith('(')) {
      expression += '0.';
      _resetTransient();
      notifyListeners();
      return;
    }

    if (expression.endsWith(')') || expression.endsWith('pi')) {
      expression += '*0.';
      _resetTransient();
      notifyListeners();
      return;
    }

    if (_currentNumberHasDecimal()) return;

    expression += '.';
    _resetTransient();
    notifyListeners();
  }

  void _appendOpenParenthesis() {
    if (_endsWithValue()) {
      expression += '*(';
    } else {
      expression += '(';
    }
    _resetTransient();
    notifyListeners();
  }

  void _appendCloseParenthesis() {
    if (_unclosedParentheses() <= 0) return;
    if (expression.isEmpty || _endsWithOperator() || expression.endsWith('(')) {
      return;
    }

    expression += ')';
    _resetTransient();
    notifyListeners();
  }

  void _appendValue(String token) {
    final isDigitToken = RegExp(r'^\d+$').hasMatch(token);
    if ((_openValueTokens.contains(token) || isDigitToken) && _endsWithValue()) {
      expression += '*';
    }

    expression += token;
    _resetTransient();
    notifyListeners();
  }

  bool _endsWithOperator() {
    if (expression.isEmpty) return false;
    return _operators.contains(expression[expression.length - 1]);
  }

  bool _endsWithValue() {
    if (expression.isEmpty) return false;
    if (expression.endsWith('pi')) return true;
    final last = expression[expression.length - 1];
    return RegExp(r'[0-9)]').hasMatch(last);
  }

  bool _currentNumberHasDecimal() {
    for (var i = expression.length - 1; i >= 0; i--) {
      final ch = expression[i];
      if (ch == '.') return true;
      if (!RegExp(r'[0-9]').hasMatch(ch)) break;
    }
    return false;
  }

  int _unclosedParentheses() {
    final opens = '('.allMatches(expression).length;
    final closes = ')'.allMatches(expression).length;
    return opens - closes;
  }

  String _prepareExpression(String input) {
    final sanitized = _normalizeExpression(input);
    if (sanitized.isEmpty) return sanitized;

    final open = '('.allMatches(sanitized).length;
    final close = ')'.allMatches(sanitized).length;
    if (open <= close) return sanitized;
    return '$sanitized${List.filled(open - close, ')').join()}';
  }

  String _normalizeExpression(String input) {
    return input
        .replaceAll(' ', '')
        .replaceAll('\u00F7', '/')
        .replaceAll('\u00D7', '*')
        .replaceAll('\u2212', '-')
        .replaceAll('\u03C0', 'pi')
        .replaceAll('\u221A', 'sqrt(');
  }

  String _normalizeToken(String value) {
    switch (value.trim()) {
      case '\u00F7':
        return '/';
      case '\u00D7':
        return '*';
      case '\u2212':
        return '-';
      case '\u03C0':
        return 'pi';
      case '\u221A':
        return 'sqrt(';
      case 'ANS':
        return result == 'Error' ? '' : result;
      default:
        return value.trim();
    }
  }

  double? _currentValue() {
    if (result != 'Error') {
      final parsedResult = double.tryParse(result);
      if (parsedResult != null) return parsedResult;
    }

    if (expression.isEmpty) return null;
    final evaluated = MathEngine.evaluate(_prepareExpression(expression));
    if (evaluated == 'Error') return null;
    return double.tryParse(evaluated);
  }

  String _formatNumber(double value) {
    if (value == value.truncateToDouble() && value.abs() < 1e15) {
      return value.toInt().toString();
    }

    var out = value.toStringAsPrecision(AppConstants.displayPrecision);
    if (out.contains('.')) {
      out = out.replaceAll(RegExp(r'0+$'), '');
      out = out.replaceAll(RegExp(r'\.$'), '');
    }
    return out;
  }

  void _resetTransient() {
    result = '0';
    lastRewriteSteps = [];
    lastEvaluatedInput = '';
  }
}
