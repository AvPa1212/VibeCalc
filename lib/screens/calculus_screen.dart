import 'package:flutter/material.dart';
import '../services/calculus_engine.dart';

class CalculusScreen extends StatefulWidget {
  const CalculusScreen({super.key});

  @override
  State<CalculusScreen> createState() => _CalculusScreenState();
}

class _CalculusScreenState extends State<CalculusScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Derivative fields
  final _derivativeExprCtrl = TextEditingController(text: 'x^2');
  final _derivativeXCtrl = TextEditingController(text: '3');
  String _derivativeResult = '';

  // Integral fields
  final _integralExprCtrl = TextEditingController(text: 'x^2');
  final _integralACtrl = TextEditingController(text: '0');
  final _integralBCtrl = TextEditingController(text: '3');
  String _integralResult = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _derivativeExprCtrl.dispose();
    _derivativeXCtrl.dispose();
    _integralExprCtrl.dispose();
    _integralACtrl.dispose();
    _integralBCtrl.dispose();
    super.dispose();
  }

  void _computeDerivative() {
    final expr = _derivativeExprCtrl.text.trim();
    final x = double.tryParse(_derivativeXCtrl.text.trim());

    if (expr.isEmpty || x == null) {
      setState(() => _derivativeResult = 'Invalid input');
      return;
    }

    try {
      final d = CalculusEngine.derivative(expr, x);
      setState(() => _derivativeResult = "f'($x) ≈ ${_fmt(d)}");
    } catch (_) {
      setState(() => _derivativeResult = 'Error');
    }
  }

  void _computeIntegral() {
    final expr = _integralExprCtrl.text.trim();
    final a = double.tryParse(_integralACtrl.text.trim());
    final b = double.tryParse(_integralBCtrl.text.trim());

    if (expr.isEmpty || a == null || b == null) {
      setState(() => _integralResult = 'Invalid input');
      return;
    }

    try {
      final result = CalculusEngine.integral(expr, a, b);
      setState(() => _integralResult = "∫ f(x)dx from $a to $b ≈ ${_fmt(result)}");
    } catch (_) {
      setState(() => _integralResult = 'Error');
    }
  }

  String _fmt(double v) {
    if (v == v.truncateToDouble() && v.abs() < 1e15) return v.toInt().toString();
    String s = v.toStringAsPrecision(8);
    if (s.contains('.')) {
      s = s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    }
    return s;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculus'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: theme.primaryColor,
          tabs: const [
            Tab(text: "Derivative"),
            Tab(text: "Integral"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _DerivativeTab(
            exprCtrl: _derivativeExprCtrl,
            xCtrl: _derivativeXCtrl,
            result: _derivativeResult,
            onCompute: _computeDerivative,
          ),
          _IntegralTab(
            exprCtrl: _integralExprCtrl,
            aCtrl: _integralACtrl,
            bCtrl: _integralBCtrl,
            result: _integralResult,
            onCompute: _computeIntegral,
          ),
        ],
      ),
    );
  }
}

class _DerivativeTab extends StatelessWidget {
  final TextEditingController exprCtrl;
  final TextEditingController xCtrl;
  final String result;
  final VoidCallback onCompute;

  const _DerivativeTab({
    required this.exprCtrl,
    required this.xCtrl,
    required this.result,
    required this.onCompute,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Numerical Derivative  f\'(x)',
              style: theme.textTheme.titleMedium
                  ?.copyWith(color: theme.primaryColor)),
          const SizedBox(height: 16),
          _buildField(context, exprCtrl, 'Expression f(x)', 'e.g. x^2+3*x'),
          const SizedBox(height: 12),
          _buildField(context, xCtrl, 'Point x', 'e.g. 3',
              numeric: true),
          const SizedBox(height: 20),
          _buildButton(context, onCompute),
          if (result.isNotEmpty) _buildResult(context, result),
        ],
      ),
    );
  }
}

class _IntegralTab extends StatelessWidget {
  final TextEditingController exprCtrl;
  final TextEditingController aCtrl;
  final TextEditingController bCtrl;
  final String result;
  final VoidCallback onCompute;

  const _IntegralTab({
    required this.exprCtrl,
    required this.aCtrl,
    required this.bCtrl,
    required this.result,
    required this.onCompute,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Definite Integral  ∫ f(x)dx',
              style: theme.textTheme.titleMedium
                  ?.copyWith(color: theme.primaryColor)),
          const SizedBox(height: 16),
          _buildField(context, exprCtrl, 'Expression f(x)', 'e.g. x^2'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _buildField(context, aCtrl, 'Lower bound a', '0',
                      numeric: true)),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildField(context, bCtrl, 'Upper bound b', '1',
                      numeric: true)),
            ],
          ),
          const SizedBox(height: 20),
          _buildButton(context, onCompute),
          if (result.isNotEmpty) _buildResult(context, result),
        ],
      ),
    );
  }
}

Widget _buildField(
  BuildContext context,
  TextEditingController ctrl,
  String label,
  String hint, {
  bool numeric = false,
}) {
  return TextFormField(
    controller: ctrl,
    keyboardType: numeric
        ? const TextInputType.numberWithOptions(
            decimal: true, signed: true)
        : TextInputType.text,
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
  );
}

Widget _buildButton(BuildContext context, VoidCallback onTap) {
  final theme = Theme.of(context);
  return ElevatedButton(
    onPressed: onTap,
    style: ElevatedButton.styleFrom(
      backgroundColor: theme.primaryColor,
      foregroundColor: Colors.black,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    child: const Text('Calculate',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
  );
}

Widget _buildResult(BuildContext context, String result) {
  final theme = Theme.of(context);
  return Padding(
    padding: const EdgeInsets.only(top: 20),
    child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.primaryColor.withValues(alpha: 0.4)),
      ),
      child: Text(
        result,
        style: theme.textTheme.titleMedium?.copyWith(
            color: theme.primaryColor, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    ),
  );
}
