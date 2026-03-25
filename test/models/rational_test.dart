import 'package:flutter_test/flutter_test.dart';
import 'package:vibecalc/models/rational.dart';

void main() {
  group('Rational', () {
    test('normalizes sign and reduces fractions', () {
      final value = Rational(BigInt.from(-4), BigInt.from(-10));

      expect(value.numerator, BigInt.from(2));
      expect(value.denominator, BigInt.from(5));
      expect(value.toString(), '2/5');
    });

    test('parses decimals exactly', () {
      final value = Rational.parse('-1.25');

      expect(value.numerator, BigInt.from(-5));
      expect(value.denominator, BigInt.from(4));
      expect(value.toString(), '-5/4');
    });

    test('supports negative exponents', () {
      final value = Rational(BigInt.from(2), BigInt.from(3)).powInt(-2);

      expect(value.toString(), '9/4');
    });

    test('throws on division by zero', () {
      final left = Rational(BigInt.from(3), BigInt.from(4));
      final zero = Rational.fromInt(0);

      expect(() => left / zero, throwsArgumentError);
    });
  });
}
