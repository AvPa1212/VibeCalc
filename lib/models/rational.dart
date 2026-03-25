class Rational {
  final BigInt numerator;
  final BigInt denominator;

  const Rational._(this.numerator, this.denominator);

  factory Rational(BigInt numerator, BigInt denominator) {
    if (denominator == BigInt.zero) {
      throw ArgumentError('Denominator cannot be zero.');
    }

    var n = numerator;
    var d = denominator;

    if (d.isNegative) {
      n = -n;
      d = -d;
    }

    final gcd = _gcd(n.abs(), d.abs());
    return Rational._(n ~/ gcd, d ~/ gcd);
  }

  factory Rational.fromInt(int value) => Rational(BigInt.from(value), BigInt.one);

  factory Rational.parse(String value) {
    if (value.contains('/')) {
      final parts = value.split('/');
      if (parts.length != 2) {
        throw const FormatException('Invalid rational format.');
      }
      return Rational(
        BigInt.parse(parts[0].trim()),
        BigInt.parse(parts[1].trim()),
      );
    }

    if (value.contains('.')) {
      final pieces = value.split('.');
      if (pieces.length != 2) {
        throw const FormatException('Invalid decimal format.');
      }
      final whole = pieces[0].isEmpty ? '0' : pieces[0];
      final frac = pieces[1];
      final scale = BigInt.from(10).pow(frac.length);
      final signedWhole = BigInt.parse(whole) * scale;
      final signedFrac = BigInt.parse(frac) * (whole.trim().startsWith('-') ? BigInt.from(-1) : BigInt.one);
      return Rational(signedWhole + signedFrac, scale);
    }

    return Rational(BigInt.parse(value.trim()), BigInt.one);
  }

  Rational operator +(Rational other) {
    return Rational(
      numerator * other.denominator + other.numerator * denominator,
      denominator * other.denominator,
    );
  }

  Rational operator -(Rational other) {
    return Rational(
      numerator * other.denominator - other.numerator * denominator,
      denominator * other.denominator,
    );
  }

  Rational operator *(Rational other) {
    return Rational(numerator * other.numerator, denominator * other.denominator);
  }

  Rational operator /(Rational other) {
    if (other.numerator == BigInt.zero) {
      throw ArgumentError('Cannot divide by zero.');
    }
    return Rational(numerator * other.denominator, denominator * other.numerator);
  }

  Rational powInt(int exponent) {
    if (exponent == 0) {
      return Rational(BigInt.one, BigInt.one);
    }

    final e = exponent.abs();
    final numPow = numerator.pow(e);
    final denPow = denominator.pow(e);

    if (exponent.isNegative) {
      return Rational(denPow, numPow);
    }

    return Rational(numPow, denPow);
  }

  double toDouble() => numerator.toDouble() / denominator.toDouble();

  @override
  String toString() {
    if (denominator == BigInt.one) {
      return numerator.toString();
    }
    return '$numerator/$denominator';
  }

  static BigInt _gcd(BigInt a, BigInt b) {
    var x = a;
    var y = b;
    while (y != BigInt.zero) {
      final t = x % y;
      x = y;
      y = t;
    }
    return x == BigInt.zero ? BigInt.one : x;
  }
}
