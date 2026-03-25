import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/graph_engine.dart';
import '../core/constants.dart';

class GraphScreen extends StatefulWidget {
  const GraphScreen({super.key});

  @override
  State<GraphScreen> createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen> {
  String _expression = 'sin(x)';
  double _minX = -10;
  double _maxX = 10;
  final _controller = TextEditingController(text: 'sin(x)');

  List<FlSpot> _spots = [];
  double _minY = -1.5;
  double _maxY = 1.5;

  @override
  void initState() {
    super.initState();
    _updateGraph();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateGraph() {
    final spots = GraphEngine.generatePoints(
      expression: _expression,
      minX: _minX,
      maxX: _maxX,
      resolution: AppConstants.graphResolution,
    );
    final (minY, maxY) = GraphEngine.calculateYBounds(spots);
    setState(() {
      _spots = spots;
      _minY = minY;
      _maxY = maxY;
    });
  }

  void _zoom(double factor) {
    final (newMin, newMax) =
        GraphEngine.zoom(minX: _minX, maxX: _maxX, factor: factor);
    _minX = newMin;
    _maxX = newMax;
    _updateGraph();
  }

  void _pan(double delta) {
    final range = _maxX - _minX;
    final (newMin, newMax) = GraphEngine.pan(
        minX: _minX, maxX: _maxX, delta: delta * range * 0.1);
    _minX = newMin;
    _maxX = newMax;
    _updateGraph();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Graph')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'f(x)',
                hintText: 'e.g. sin(x), x^2, cos(x)+1',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                suffixIcon: IconButton(
                  icon: Icon(Icons.play_arrow, color: theme.primaryColor),
                  onPressed: () {
                    _expression = _controller.text.trim();
                    _updateGraph();
                  },
                ),
              ),
              onSubmitted: (val) {
                _expression = val.trim();
                _updateGraph();
              },
            ),
          ),

          // Zoom / pan controls
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  tooltip: 'Zoom out',
                  onPressed: () => _zoom(0.5),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  tooltip: 'Zoom in',
                  onPressed: () => _zoom(2.0),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  tooltip: 'Pan left',
                  onPressed: () => _pan(-1),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  tooltip: 'Pan right',
                  onPressed: () => _pan(1),
                ),
                const SizedBox(width: 16),
                TextButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset'),
                  onPressed: () {
                    _minX = -10;
                    _maxX = 10;
                    _updateGraph();
                  },
                ),
              ],
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: _spots.isEmpty
                  ? Center(
                      child: Text(
                        'No data to display',
                        style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.5)),
                      ),
                    )
                  : LineChart(
                      LineChartData(
                        minX: _minX,
                        maxX: _maxX,
                        minY: _minY,
                        maxY: _maxY,
                        gridData: FlGridData(
                          show: true,
                          getDrawingHorizontalLine: (_) => FlLine(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.15),
                              strokeWidth: 2.5),
                          getDrawingVerticalLine: (_) => FlLine(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.15),
                              strokeWidth: 2.5),
                        ),
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: (_maxX - _minX) / AppConstants.graphAxisDivisions,
                              getTitlesWidget: (value, _) => Text(
                                value.toStringAsPrecision(3),
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.7),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, _) => Text(
                                value.toStringAsPrecision(3),
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.7),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: _spots,
                            isCurved: false,
                            color: theme.primaryColor,
                            barWidth: 2,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              color: theme.primaryColor.withValues(alpha: 0.1),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
