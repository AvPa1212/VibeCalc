import 'package:flutter_test/flutter_test.dart';
import 'package:vibecalc/services/notebook_code_executor.dart';

void main() {
  group('NotebookCodeExecutor', () {
    test('executes assignments and print with variable substitution', () {
      final result = NotebookCodeExecutor.execute(
        code: 'x = 2 + 3\ny = x * 4\nprint y',
        initialVariables: const {},
        maxSteps: 100,
        timeBudgetMs: 1000,
      );

      expect(result.timedOut, isFalse);
      expect(result.variables['x'], '5');
      expect(result.variables['y'], '20');
      expect(result.outputLines, ['x = 5', 'y = 20', '20']);
      expect(result.steps, hasLength(3));
      expect(result.steps.every((s) => s.status == 'ok'), isTrue);
    });

    test('marks unsupported statements as errors', () {
      final result = NotebookCodeExecutor.execute(
        code: 'foo(1)',
        initialVariables: const {},
        maxSteps: 100,
        timeBudgetMs: 1000,
      );

      expect(result.timedOut, isFalse);
      expect(result.steps, hasLength(1));
      expect(result.steps.first.status, 'error');
      expect(
        result.outputLines.first,
        startsWith('Unsupported statement:'),
      );
    });

    test('stops execution when step budget is exceeded', () {
      final result = NotebookCodeExecutor.execute(
        code: 'a = 1\nb = 2\nprint b',
        initialVariables: const {},
        maxSteps: 1,
        timeBudgetMs: 1000,
      );

      expect(result.timedOut, isTrue);
      expect(result.steps, hasLength(1));
      expect(result.variables['a'], '1');
      expect(
        result.outputLines.last,
        'Execution stopped: time/step budget exceeded.',
      );
    });
  });
}
