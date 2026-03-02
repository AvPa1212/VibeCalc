import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/calculator_model.dart';
import '../widgets/calc_button.dart';

class CalculatorScreen extends StatelessWidget {
  const CalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<CalculatorModel>();

    final buttons = [
      "C", "(", ")", "/",
      "7", "8", "9", "*",
      "4", "5", "6", "-",
      "1", "2", "3", "+",
      "0", ".", "^", "="
    ];

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            flex: 2,
            child: Dismissible(
              key: const Key("expr"),
              direction: DismissDirection.endToStart,
              onDismissed: (_) => model.deleteLast(),
              child: Container(
                padding: const EdgeInsets.all(20),
                alignment: Alignment.bottomRight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(model.expression, style: const TextStyle(fontSize: 28)),
                    const SizedBox(height: 10),
                    Text(model.result,
                        style: const TextStyle(
                            fontSize: 48, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: GridView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: buttons.length,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 1.2,
              ),
              itemBuilder: (_, i) {
                final label = buttons[i];
                return CalcButton(
                  label: label,
                  onTap: () {
                    if (label == "C") {
                      model.clear();
                    } else if (label == "=") {
                      model.evaluate();
                    } else {
                      model.add(label);
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}