class RewriteRule {
  final String id;
  final String name;
  final String pattern;
  final String replacement;

  const RewriteRule({
    required this.id,
    required this.name,
    required this.pattern,
    required this.replacement,
  });
}

class RewriteStep {
  final String before;
  final String after;
  final String ruleName;

  const RewriteStep({
    required this.before,
    required this.after,
    required this.ruleName,
  });
}

class RewriteTraceResult {
  final String finalExpression;
  final List<RewriteStep> steps;

  const RewriteTraceResult({
    required this.finalExpression,
    required this.steps,
  });
}

class RewriteTraceEngine {
  static final List<RewriteRule> defaultRules = [
    const RewriteRule(
      id: 'pow-two',
      name: 'Square Expansion',
      pattern: r'([a-zA-Z0-9]+)\^2',
      replacement: r'($1)*($1)',
    ),
    const RewriteRule(
      id: 'double-neg',
      name: 'Double Negative',
      pattern: r'--',
      replacement: '+',
    ),
    const RewriteRule(
      id: 'mul-one-left',
      name: 'Identity Multiplication (Left)',
      pattern: r'\b1\*',
      replacement: '',
    ),
    const RewriteRule(
      id: 'mul-one-right',
      name: 'Identity Multiplication (Right)',
      pattern: r'\*1\b',
      replacement: '',
    ),
  ];

  static RewriteTraceResult trace(
    String expression, {
    List<RewriteRule>? userRules,
    int maxPasses = 20,
  }) {
    var current = expression;
    final steps = <RewriteStep>[];

    final allRules = <RewriteRule>[
      ...defaultRules,
      ...?userRules,
    ];

    var pass = 0;
    while (pass < maxPasses) {
      var changed = false;

      for (final rule in allRules) {
        final regex = RegExp(rule.pattern);
        final next = current.replaceAll(regex, rule.replacement);

        if (next != current) {
          steps.add(RewriteStep(
            before: current,
            after: next,
            ruleName: rule.name,
          ));
          current = next;
          changed = true;
        }
      }

      if (!changed) {
        break;
      }
      pass += 1;
    }

    return RewriteTraceResult(finalExpression: current, steps: steps);
  }
}
