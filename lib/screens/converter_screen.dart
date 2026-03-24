import 'package:flutter/material.dart';
import '../services/unit_engine.dart';

class ConverterScreen extends StatefulWidget {
  const ConverterScreen({super.key});

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  UnitCategory _category = UnitCategory.length;
  String? _fromUnit;
  String? _toUnit;
  double _inputValue = 0;
  String _result = '';

  List<String> get _units => UnitEngine.getUnits(_category);

  void _convert() {
    final from = _fromUnit;
    final to = _toUnit;
    if (from == null || to == null) return;

    try {
      final converted = UnitEngine.convert(
        category: _category,
        value: _inputValue,
        fromUnit: from,
        toUnit: to,
      );

      final formatted = converted == converted.truncateToDouble()
          ? converted.toInt().toString()
          : converted.toStringAsPrecision(8)
              .replaceAll(RegExp(r'0+$'), '')
              .replaceAll(RegExp(r'\.$'), '');

      setState(() => _result = '$_inputValue $from = $formatted $to');
    } catch (_) {
      setState(() => _result = 'Invalid conversion');
    }
  }

  @override
  void initState() {
    super.initState();
    _initUnits();
  }

  void _initUnits() {
    final units = _units;
    _fromUnit = units.isNotEmpty ? units.first : null;
    if (units.length > 1) {
      _toUnit = units[1];
    } else if (units.isNotEmpty) {
      _toUnit = units.first;
    } else {
      _toUnit = null;
    }
  }

  String _categoryLabel(UnitCategory cat) {
    return cat.name[0].toUpperCase() + cat.name.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final units = _units;

    return Scaffold(
      appBar: AppBar(title: const Text('Unit Converter')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Category selector
            Text('Category', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            DropdownButtonFormField<UnitCategory>(
              initialValue: _category,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              items: UnitEngine.getCategories()
                  .map((c) => DropdownMenuItem(
                      value: c, child: Text(_categoryLabel(c))))
                  .toList(),
              onChanged: (c) {
                if (c == null) return;
                setState(() {
                  _category = c;
                  _result = '';
                  _initUnits();
                });
              },
            ),

            const SizedBox(height: 20),

            // Input value
            Text('Value', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            TextFormField(
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              initialValue: '0',
              decoration: InputDecoration(
                hintText: 'Enter value',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (v) {
                setState(() {
                  _inputValue = double.tryParse(v) ?? 0;
                  if (_result.isNotEmpty) _convert();
                });
              },
            ),

            const SizedBox(height: 20),

            // From / To units
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('From', style: theme.textTheme.labelLarge),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: _fromUnit,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                        ),
                        items: units
                            .map((u) =>
                                DropdownMenuItem(value: u, child: Text(u)))
                            .toList(),
                        onChanged: (u) =>
                            setState(() => _fromUnit = u),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 24, left: 12, right: 12),
                  child: Icon(Icons.swap_horiz,
                      color: theme.primaryColor, size: 28),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('To', style: theme.textTheme.labelLarge),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: _toUnit,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                        ),
                        items: units
                            .map((u) =>
                                DropdownMenuItem(value: u, child: Text(u)))
                            .toList(),
                        onChanged: (u) =>
                            setState(() => _toUnit = u),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            ElevatedButton(
              onPressed: _convert,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Convert',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),
            if (_result.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: theme.primaryColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  _result,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.primaryColor,
                    fontFamily: 'monospace',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}