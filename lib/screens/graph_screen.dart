import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/graph_engine.dart';

class GraphScreen extends StatefulWidget {
  const GraphScreen({super.key});

  @override
  State<GraphScreen> createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen> {
  String expression = "sin(x)";
  double minX = -10;
  double maxX = 10;

  @override
  Widget build(BuildContext context) {
    final spots = GraphEngine.generatePoints(
      expression: expression,
      minX: minX,
      maxX: maxX,
    );

    final (minY, maxY) = GraphEngine.calculateYBounds(spots);

    return Scaffold(
      appBar: AppBar(title: const Text("Graph Mode")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                  labelText: "Enter f(x)"),
              onSubmitted: (val) {
                setState(() {
                  expression = val;
                });
              },
            ),
          ),
          Expanded(
            child: LineChart(
              LineChartData(
                minX: minX,
                maxX: maxX,
                minY: minY,
                maxY: maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: false,
                    dotData: const FlDotData(show: false),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}