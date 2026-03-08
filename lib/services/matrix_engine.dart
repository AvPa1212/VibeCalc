class MatrixEngine {
  static double determinant2x2(
      double a, double b, double c, double d) {
    return a * d - b * c;
  }

  /// Adds two 2×2 matrices represented as flat lists [a, b, c, d].
  static List<double> add2x2(List<double> a, List<double> b) {
    return List.generate(4, (i) => a[i] + b[i]);
  }

  /// Subtracts B from A for two 2×2 matrices.
  static List<double> subtract2x2(List<double> a, List<double> b) {
    return List.generate(4, (i) => a[i] - b[i]);
  }

  /// Multiplies two 2×2 matrices represented as flat lists [a, b, c, d].
  static List<double> multiply2x2(List<double> a, List<double> b) {
    return [
      a[0] * b[0] + a[1] * b[2],
      a[0] * b[1] + a[1] * b[3],
      a[2] * b[0] + a[3] * b[2],
      a[2] * b[1] + a[3] * b[3],
    ];
  }
}