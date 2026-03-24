import 'package:fl_chart/fl_chart.dart';
import 'math_engine.dart';

class GraphEngine {
  /// Generates graph points for f(x)
  static List<FlSpot> generatePoints({
    required String expression,
    double minX = -10,
    double maxX = 10,
    int resolution = 400,
  }) {
    final List<FlSpot> spots = [];

    final step = (maxX - minX) / resolution;

    for (int i = 0; i <= resolution; i++) {
      double x = minX + (i * step);

      double? y = _safeEvaluate(expression, x);

      if (y != null && y.isFinite) {
        spots.add(FlSpot(x, y));
      }
    }

    return spots;
  }

  /// Safe evaluation wrapper
  static double? _safeEvaluate(String expression, double x) {
    try {
      String parsed = expression
          .replaceAll("π", "pi")
          .replaceAll("√", "sqrt")
          .replaceAll("x", "($x)");

      String result = MathEngine.evaluate(parsed);

      if (result == "Error") return null;

      double value = double.parse(result);

      if (value.isNaN || value.isInfinite) return null;

      return value;
    } catch (_) {
      return null;
    }
  }

  /// Automatically calculates smart Y-axis bounds
  static (double minY, double maxY) calculateYBounds(
      List<FlSpot> spots) {
    if (spots.isEmpty) return (-10, 10);

    double minY = spots.first.y;
    double maxY = spots.first.y;

    for (var s in spots) {
      if (s.y < minY) minY = s.y;
      if (s.y > maxY) maxY = s.y;
    }

    // Add padding
    double padding = (maxY - minY).abs() * 0.1;
    if (padding == 0) padding = 1;

    return (minY - padding, maxY + padding);
  }

  /// Zoom utility
  static (double newMinX, double newMaxX) zoom({
    required double minX,
    required double maxX,
    required double factor,
  }) {
    double center = (minX + maxX) / 2;
    double halfRange = (maxX - minX) / 2;

    halfRange /= factor;

    return (center - halfRange, center + halfRange);
  }

  /// Pan utility
  static (double newMinX, double newMaxX) pan({
    required double minX,
    required double maxX,
    required double delta,
  }) {
    return (minX + delta, maxX + delta);
  }
}