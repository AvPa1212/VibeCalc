import 'dart:math' as math;

import '../models/rational.dart';

enum InputNotation { infix, postfix }

class EvaluationResult {
  final AstNode ast;
  final Rational? exact;
  final double? approximate;

  const EvaluationResult({
    required this.ast,
    this.exact,
    this.approximate,
  });

  String get displayValue {
    if (exact != null) {
      return exact.toString();
    }
    if (approximate != null) {
      final raw = approximate!.toStringAsPrecision(12);
      return raw.replaceFirst(RegExp(r'\.0+$'), '');
    }
    return 'Error';
  }
}

class AstNode {
  final String value;
  final AstNode? left;
  final AstNode? right;

  const AstNode(this.value, {this.left, this.right});

  bool get isLeaf => left == null && right == null;

  String pretty([int depth = 0]) {
    final indent = '  ' * depth;
    if (isLeaf) {
      return '$indent$value';
    }

    final parts = <String>['$indent$value'];
    if (left != null) {
      parts.add(left!.pretty(depth + 1));
    }
    if (right != null) {
      parts.add(right!.pretty(depth + 1));
    }
    return parts.join('\n');
  }
}

class DeterministicExpressionEngine {
  static final Set<String> _ops = {'+', '-', '*', '/', '^'};

  static EvaluationResult evaluate(
    String input, {
    InputNotation notation = InputNotation.infix,
  }) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      throw const FormatException('Expression is empty.');
    }

    final postfix = notation == InputNotation.infix
        ? _toPostfix(_tokenizeInfix(trimmed))
        : _tokenizePostfix(trimmed);

    final ast = _buildAstFromPostfix(postfix);
    final exact = _evaluateExact(ast);
    if (exact != null) {
      return EvaluationResult(ast: ast, exact: exact);
    }

    final approximate = _evaluateApprox(ast);
    return EvaluationResult(ast: ast, approximate: approximate);
  }

  static List<String> _tokenizePostfix(String input) {
    return input.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();
  }

  static List<String> _tokenizeInfix(String input) {
    final tokens = <String>[];
    final buffer = StringBuffer();

    bool isNumberChar(String c) => RegExp(r'[0-9.]').hasMatch(c);

    for (var i = 0; i < input.length; i++) {
      final ch = input[i];
      final isUnaryMinus = ch == '-' &&
          (i == 0 ||
              _ops.contains(input[i - 1]) ||
              input[i - 1] == '(' ||
              input[i - 1] == ' ');

      if (isUnaryMinus) {
        buffer.write(ch);
        continue;
      }

      if (isNumberChar(ch)) {
        buffer.write(ch);
        continue;
      }

      if (buffer.isNotEmpty) {
        tokens.add(buffer.toString());
        buffer.clear();
      }

      if (_ops.contains(ch) || ch == '(' || ch == ')') {
        tokens.add(ch);
      }
    }

    if (buffer.isNotEmpty) {
      tokens.add(buffer.toString());
    }

    return tokens;
  }

  static List<String> _toPostfix(List<String> tokens) {
    final output = <String>[];
    final stack = <String>[];

    for (final token in tokens) {
      if (_isNumber(token)) {
        output.add(token);
      } else if (_ops.contains(token)) {
        while (stack.isNotEmpty &&
            _ops.contains(stack.last) &&
            ((_isLeftAssociative(token) && _prec(token) <= _prec(stack.last)) ||
                (!_isLeftAssociative(token) && _prec(token) < _prec(stack.last)))) {
          output.add(stack.removeLast());
        }
        stack.add(token);
      } else if (token == '(') {
        stack.add(token);
      } else if (token == ')') {
        while (stack.isNotEmpty && stack.last != '(') {
          output.add(stack.removeLast());
        }
        if (stack.isEmpty || stack.last != '(') {
          throw const FormatException('Mismatched parentheses.');
        }
        stack.removeLast();
      } else {
        throw FormatException('Unknown token: $token');
      }
    }

    while (stack.isNotEmpty) {
      final op = stack.removeLast();
      if (op == '(' || op == ')') {
        throw const FormatException('Mismatched parentheses.');
      }
      output.add(op);
    }

    return output;
  }

  static AstNode _buildAstFromPostfix(List<String> tokens) {
    final stack = <AstNode>[];

    for (final token in tokens) {
      if (_isNumber(token)) {
        stack.add(AstNode(token));
        continue;
      }

      if (!_ops.contains(token) || stack.length < 2) {
        throw const FormatException('Invalid expression.');
      }

      final right = stack.removeLast();
      final left = stack.removeLast();
      stack.add(AstNode(token, left: left, right: right));
    }

    if (stack.length != 1) {
      throw const FormatException('Invalid expression.');
    }

    return stack.single;
  }

  static Rational? _evaluateExact(AstNode node) {
    if (node.isLeaf) {
      return Rational.parse(node.value);
    }

    final left = _evaluateExact(node.left!);
    final right = _evaluateExact(node.right!);

    if (left == null || right == null) {
      return null;
    }

    switch (node.value) {
      case '+':
        return left + right;
      case '-':
        return left - right;
      case '*':
        return left * right;
      case '/':
        return left / right;
      case '^':
        if (right.denominator == BigInt.one) {
          return left.powInt(right.numerator.toInt());
        }
        return null;
      default:
        throw FormatException('Unsupported operator: ${node.value}');
    }
  }

  static double _evaluateApprox(AstNode node) {
    if (node.isLeaf) {
      return double.parse(node.value);
    }

    final left = _evaluateApprox(node.left!);
    final right = _evaluateApprox(node.right!);

    switch (node.value) {
      case '+':
        return left + right;
      case '-':
        return left - right;
      case '*':
        return left * right;
      case '/':
        return left / right;
      case '^':
        return _pow(left, right);
      default:
        throw FormatException('Unsupported operator: ${node.value}');
    }
  }

  static bool _isNumber(String token) => RegExp(r'^-?\d+(\.\d+)?$').hasMatch(token);

  static int _prec(String op) {
    switch (op) {
      case '+':
      case '-':
        return 1;
      case '*':
      case '/':
        return 2;
      case '^':
        return 3;
      default:
        return 0;
    }
  }

  static bool _isLeftAssociative(String op) => op != '^';

  static double _pow(double base, double exp) {
    return base == 0 && exp == 0 ? double.nan : math.pow(base, exp).toDouble();
  }
}
