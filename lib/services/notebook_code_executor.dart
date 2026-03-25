import 'latex_input_adapter.dart';
import 'math_engine.dart';

class CodeStep {
  final int lineNumber;
  final String line;
  final Map<String, String> beforeVariables;
  final Map<String, String> afterVariables;
  final String message;
  final String status;

  const CodeStep({
    required this.lineNumber,
    required this.line,
    required this.beforeVariables,
    required this.afterVariables,
    required this.message,
    required this.status,
  });
}

class CodeExecutionResult {
  final Map<String, String> variables;
  final List<String> outputLines;
  final List<CodeStep> steps;
  final bool timedOut;

  const CodeExecutionResult({
    required this.variables,
    required this.outputLines,
    required this.steps,
    required this.timedOut,
  });
}

class NotebookCodeExecutor {
  static CodeExecutionResult execute({
    required String code,
    required Map<String, String> initialVariables,
    required int maxSteps,
    required int timeBudgetMs,
  }) {
    final vars = Map<String, String>.from(initialVariables);
    final output = <String>[];
    final steps = <CodeStep>[];

    final lines = code.split('\n');
    final timer = Stopwatch()..start();

    var executed = 0;
    var timedOut = false;

    for (var i = 0; i < lines.length; i++) {
      final raw = lines[i];
      final line = raw.trim();
      if (line.isEmpty) {
        continue;
      }

      if (executed >= maxSteps || timer.elapsedMilliseconds > timeBudgetMs) {
        timedOut = true;
        output.add('Execution stopped: time/step budget exceeded.');
        break;
      }

      executed += 1;
      final before = Map<String, String>.from(vars);
      String message;
      var status = 'ok';

      if (line.startsWith('print ')) {
        final expr = line.substring(6).trim();
        final value = _evaluateWithVars(expr, vars);
        if (value == 'Error') {
          message = 'print error: $expr';
          status = 'error';
        } else {
          message = value;
          output.add(value);
        }
      } else {
        final assign = RegExp(r'^([a-zA-Z_]\w*)\s*=\s*(.+)$').firstMatch(line);
        if (assign != null) {
          final name = assign.group(1)!;
          final expr = assign.group(2)!;
          final value = _evaluateWithVars(expr, vars);
          if (value == 'Error') {
            message = '$name assignment error';
            status = 'error';
          } else {
            vars[name] = value;
            message = '$name = $value';
            output.add(message);
          }
        } else {
          message = 'Unsupported statement: $line';
          status = 'error';
          output.add(message);
        }
      }

      final after = Map<String, String>.from(vars);
      steps.add(
        CodeStep(
          lineNumber: i + 1,
          line: line,
          beforeVariables: before,
          afterVariables: after,
          message: message,
          status: status,
        ),
      );
    }

    timer.stop();
    return CodeExecutionResult(
      variables: vars,
      outputLines: output,
      steps: steps,
      timedOut: timedOut,
    );
  }

  static String _evaluateWithVars(String input, Map<String, String> vars) {
    var expr = input;
    if (expr.contains(r'\frac') ||
        expr.contains(r'\sqrt') ||
        expr.contains(r'\cdot') ||
        expr.contains(r'\times')) {
      expr = LatexInputAdapter.toExpression(expr);
    }

    vars.forEach((name, value) {
      expr = expr.replaceAll(RegExp('\\b$name\\b'), value);
    });

    return MathEngine.evaluate(expr);
  }
}
