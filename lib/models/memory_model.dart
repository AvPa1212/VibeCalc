import 'package:flutter/material.dart';

/// Provides M+, M-, MR, MC calculator memory operations.
class MemoryModel extends ChangeNotifier {
  double _value = 0;

  double get value => _value;

  bool get hasValue => _value != 0;

  void store(double v) {
    _value = v;
    notifyListeners();
  }

  void add(double v) {
    _value += v;
    notifyListeners();
  }

  void subtract(double v) {
    _value -= v;
    notifyListeners();
  }

  double recall() => _value;

  void clear() {
    _value = 0;
    notifyListeners();
  }
}
