import 'dart:math' as math;

enum UnitCategory {
  length,
  mass,
  time,
  speed,
  area,
  volume,
  temperature,
  energy,
  pressure,
  angle,
  digitalStorage,
  frequency,
}

class UnitEngine {
  /// Master conversion map (base-unit normalized)
  static final Map<UnitCategory, Map<String, double>> _conversionFactors = {
    UnitCategory.length: {
      "m": 1,
      "km": 1000,
      "cm": 0.01,
      "mm": 0.001,
      "mi": 1609.34,
      "yd": 0.9144,
      "ft": 0.3048,
      "in": 0.0254,
    },
    UnitCategory.mass: {
      "kg": 1,
      "g": 0.001,
      "mg": 0.000001,
      "lb": 0.453592,
      "oz": 0.0283495,
      "ton": 1000,
    },
    UnitCategory.time: {
      "s": 1,
      "min": 60,
      "h": 3600,
      "day": 86400,
    },
    UnitCategory.speed: {
      "m/s": 1,
      "km/h": 0.277778,
      "mph": 0.44704,
      "ft/s": 0.3048,
    },
    UnitCategory.area: {
      "m2": 1,
      "km2": 1e6,
      "cm2": 0.0001,
      "ft2": 0.092903,
      "mi2": 2.59e6,
    },
    UnitCategory.volume: {
      "m3": 1,
      "L": 0.001,
      "mL": 0.000001,
      "ft3": 0.0283168,
      "gal": 0.00378541,
    },
    UnitCategory.energy: {
      "J": 1,
      "kJ": 1000,
      "cal": 4.184,
      "kcal": 4184,
      "Wh": 3600,
      "kWh": 3.6e6,
      "eV": 1.602176634e-19,
    },
    UnitCategory.pressure: {
      "Pa": 1,
      "kPa": 1000,
      "bar": 100000,
      "atm": 101325,
      "psi": 6894.76,
    },
    UnitCategory.angle: {
      "rad": 1,
      "deg": math.pi / 180,
      "grad": math.pi / 200,
    },
    UnitCategory.digitalStorage: {
      "B": 1,
      "KB": 1024,
      "MB": 1024 * 1024,
      "GB": 1024 * 1024 * 1024,
      "TB": 1024 * 1024 * 1024 * 1024,
    },
    UnitCategory.frequency: {
      "Hz": 1,
      "kHz": 1000,
      "MHz": 1e6,
      "GHz": 1e9,
    },
  };

  /// Temperature handled separately
  static double _convertTemperature(
      double value, String from, String to) {
    if (from == to) return value;

    double toKelvin(double v, String unit) {
      switch (unit) {
        case "C":
          return v + 273.15;
        case "F":
          return (v - 32) * 5 / 9 + 273.15;
        case "K":
          return v;
        default:
          throw Exception("Unsupported temperature unit");
      }
    }

    double fromKelvin(double v, String unit) {
      switch (unit) {
        case "C":
          return v - 273.15;
        case "F":
          return (v - 273.15) * 9 / 5 + 32;
        case "K":
          return v;
        default:
          throw Exception("Unsupported temperature unit");
      }
    }

    double kelvin = toKelvin(value, from);
    return fromKelvin(kelvin, to);
  }

  /// Public convert method
  static double convert({
    required UnitCategory category,
    required double value,
    required String fromUnit,
    required String toUnit,
  }) {
    if (category == UnitCategory.temperature) {
      return _convertTemperature(value, fromUnit, toUnit);
    }

    final categoryMap = _conversionFactors[category];

    if (categoryMap == null ||
        !categoryMap.containsKey(fromUnit) ||
        !categoryMap.containsKey(toUnit)) {
      throw Exception("Invalid unit selection");
    }

    double baseValue = value * categoryMap[fromUnit]!;
    return baseValue / categoryMap[toUnit]!;
  }

  /// Get units for UI dropdown
  static List<String> getUnits(UnitCategory category) {
    if (category == UnitCategory.temperature) {
      return ["C", "F", "K"];
    }

    return _conversionFactors[category]?.keys.toList() ?? [];
  }

  /// Get all categories
  static List<UnitCategory> getCategories() {
    return UnitCategory.values;
  }
}

