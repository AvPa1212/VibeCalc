import 'package:flutter/material.dart';
import '../services/matrix_engine.dart';

class MatrixScreen extends StatefulWidget {
  const MatrixScreen({super.key});

  @override
  State<MatrixScreen> createState() => _MatrixScreenState();
}

class _MatrixScreenState extends State<MatrixScreen> {
  // 2×2 matrix A
  final List<TextEditingController> _aCtrls =
      List.generate(4, (_) => TextEditingController(text: '0'));

  // 2×2 matrix B
  final List<TextEditingController> _bCtrls =
      List.generate(4, (_) => TextEditingController(text: '0'));

  String _result = '';
  String _operation = 'det_A';

  @override
  void dispose() {
    for (final c in [..._aCtrls, ..._bCtrls]) {
      c.dispose();
    }
    super.dispose();
  }

  List<double> _parseMatrix(List<TextEditingController> ctrls) {
    return ctrls.map((c) => double.tryParse(c.text.trim()) ?? 0).toList();
  }

  void _calculate() {
    final a = _parseMatrix(_aCtrls);
    final b = _parseMatrix(_bCtrls);

    String res;
    try {
      switch (_operation) {
        case 'det_A':
          final d = MatrixEngine.determinant2x2(a[0], a[1], a[2], a[3]);
          res = 'det(A) = ${_fmt(d)}';
        case 'det_B':
          final d = MatrixEngine.determinant2x2(b[0], b[1], b[2], b[3]);
          res = 'det(B) = ${_fmt(d)}';
        case 'add':
          final r = MatrixEngine.add2x2(a, b);
          res = 'A + B =\n${_matStr(r)}';
        case 'sub':
          final r = MatrixEngine.subtract2x2(a, b);
          res = 'A − B =\n${_matStr(r)}';
        case 'mul':
          final r = MatrixEngine.multiply2x2(a, b);
          res = 'A × B =\n${_matStr(r)}';
        default:
          res = '';
      }
    } catch (_) {
      res = 'Error';
    }

    setState(() => _result = res);
  }

  String _fmt(double v) {
    if (v == v.truncateToDouble() && v.abs() < 1e15) {
      return v.toInt().toString();
    }
    String s = v.toStringAsPrecision(6);
    if (s.contains('.')) {
      s = s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    }
    return s;
  }

  String _matStr(List<double> m) {
    return '[ ${_fmt(m[0])}  ${_fmt(m[1])} ]\n'
        '[ ${_fmt(m[2])}  ${_fmt(m[3])} ]';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Matrix Calculator')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Matrix A
            _MatrixInput(label: 'Matrix A', ctrls: _aCtrls),
            const SizedBox(height: 16),

            // Matrix B
            _MatrixInput(label: 'Matrix B', ctrls: _bCtrls),
            const SizedBox(height: 20),

            // Operation selector
            Text('Operation', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _OpChip('det(A)', 'det_A', _operation, (v) => setState(() => _operation = v)),
                _OpChip('det(B)', 'det_B', _operation, (v) => setState(() => _operation = v)),
                _OpChip('A + B', 'add', _operation, (v) => setState(() => _operation = v)),
                _OpChip('A − B', 'sub', _operation, (v) => setState(() => _operation = v)),
                _OpChip('A × B', 'mul', _operation, (v) => setState(() => _operation = v)),
              ],
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _calculate,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Calculate',
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),

            if (_result.isNotEmpty) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border:
                      Border.all(color: theme.primaryColor.withValues(alpha: 0.4)),
                ),
                child: Text(
                  _result,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MatrixInput extends StatelessWidget {
  final String label;
  final List<TextEditingController> ctrls;

  const _MatrixInput({required this.label, required this.ctrls});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: theme.textTheme.titleSmall
                ?.copyWith(color: theme.primaryColor)),
        const SizedBox(height: 8),
        Table(
          children: [
            TableRow(children: [
              _cell(ctrls[0]),
              _cell(ctrls[1]),
            ]),
            TableRow(children: [
              _cell(ctrls[2]),
              _cell(ctrls[3]),
            ]),
          ],
        ),
      ],
    );
  }

  Widget _cell(TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: TextFormField(
        controller: ctrl,
        textAlign: TextAlign.center,
        keyboardType: const TextInputType.numberWithOptions(
            decimal: true, signed: true),
        decoration: InputDecoration(
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        ),
      ),
    );
  }
}

class _OpChip extends StatelessWidget {
  final String label;
  final String value;
  final String selected;
  final ValueChanged<String> onSelect;

  const _OpChip(this.label, this.value, this.selected, this.onSelect);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSelected = value == selected;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: theme.primaryColor.withValues(alpha: 0.3),
      onSelected: (_) => onSelect(value),
    );
  }
}
