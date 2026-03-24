
import 'math_engine.dart';

class Complex {
  final double real;
  final double imaginary;

  const Complex(this.real, this.imaginary);

  Complex operator +(Complex other) =>
      Complex(real + other.real, imaginary + other.imaginary);

  Complex operator -(Complex other) =>
      Complex(real - other.real, imaginary - other.imaginary);

  Complex operator *(Complex other) => Complex(
        real * other.real - imaginary * other.imaginary,
        real * other.imaginary + imaginary * other.real,
      );

  Complex operator /(Complex other) {
    final denom =
        other.real * other.real + other.imaginary * other.imaginary;

    return Complex(
      (real * other.real + imaginary * other.imaginary) / denom,
      (imaginary * other.real - real * other.imaginary) / denom,
    );
  }

  @override
  String toString() {
    if (imaginary == 0) return real.toString();
    if (real == 0) return '${imaginary}i';
    return '$real ${imaginary >= 0 ? '+' : '-'} ${imaginary.abs()}i';
  }
}

class ComplexEngine {
  String evaluate(String expression) {
    final trimmed = expression.trim();
    if (trimmed.isEmpty) return '0';

    final normalized = trimmed
        .replaceAll('π', 'pi')
        .replaceAll('×', '*')
        .replaceAll('÷', '/');

    return MathEngine.evaluate(normalized);
  }
}