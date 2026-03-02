import 'package:flutter/material.dart';

class ConverterScreen extends StatefulWidget {
  const ConverterScreen({super.key});

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  double meters = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          TextField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: "Meters"),
            onChanged: (v) {
              setState(() {
                meters = double.tryParse(v) ?? 0;
              });
            },
          ),
          const SizedBox(height: 20),
          Text("Kilometers: ${meters / 1000}"),
        ],
      ),
    );
  }
}