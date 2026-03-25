class LatexInputAdapter {
  static String toExpression(String latex) {
    var s = latex.trim();

    s = s.replaceAll(r'\left', '');
    s = s.replaceAll(r'\right', '');
    s = s.replaceAll(r'\cdot', '*');
    s = s.replaceAll(r'\times', '*');

    s = _replaceSqrt(s);
    s = _replaceFrac(s);

    s = s.replaceAll('{', '(').replaceAll('}', ')');
    return s;
  }

  static String _replaceSqrt(String input) {
    final regex = RegExp(r'\\sqrt\{([^{}]+)\}');
    var current = input;
    while (regex.hasMatch(current)) {
      current = current.replaceAllMapped(regex, (m) => 'sqrt(${m.group(1)})');
    }
    return current;
  }

  static String _replaceFrac(String input) {
    final regex = RegExp(r'\\frac\{([^{}]+)\}\{([^{}]+)\}');
    var current = input;
    while (regex.hasMatch(current)) {
      current = current.replaceAllMapped(
        regex,
        (m) => '((${m.group(1)})/(${m.group(2)}))',
      );
    }
    return current;
  }
}
