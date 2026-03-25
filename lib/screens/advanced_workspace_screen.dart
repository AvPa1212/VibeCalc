import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../models/workspace_cell.dart';
import '../services/deterministic_expression_engine.dart';
import '../services/graph_engine.dart';
import '../services/latex_input_adapter.dart';
import '../services/math_engine.dart';
import '../services/notebook_code_executor.dart';
import '../services/notebook_dependency_engine.dart';
import '../services/rewrite_trace_engine.dart';
import '../services/workspace_snapshot_service.dart';

class AdvancedWorkspaceScreen extends StatefulWidget {
  const AdvancedWorkspaceScreen({super.key});

  @override
  State<AdvancedWorkspaceScreen> createState() => _AdvancedWorkspaceScreenState();
}

class _AdvancedWorkspaceScreenState extends State<AdvancedWorkspaceScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _inputController =
      TextEditingController(text: '(2+3)*(7-4)/5');
  final TextEditingController _rulePatternController = TextEditingController();
  final TextEditingController _ruleReplacementController = TextEditingController();

  InputNotation _notation = InputNotation.infix;
  String _result = 'Run an expression to preview deterministic evaluation.';
  String _tree = 'AST will appear here.';
  List<RewriteStep> _traceSteps = const [];
  final List<RewriteRule> _userRules = [];
  List<WorkspaceCell> _cells = [];
  final Map<String, List<FlSpot>> _cellGraphSpots = {};
  final Map<String, String> _notebookVariables = {};
  List<NotebookDependencyEdge> _dependencyEdges = const [];
  bool _autoRecompute = false;
  final Map<String, _CellExecutionState> _cellExecution = {};
  final Map<String, List<CodeStep>> _codeStepTraces = {};
  int _executionBudgetMs = 80;

  static const List<_ModuleGroup> _groups = [
    _ModuleGroup('1-3 Input / Core / Graphing', [
      'Infix + postfix parser',
      'Deterministic AST view',
      'Exact rational arithmetic',
      'Graphing engine integration point',
    ]),
    _ModuleGroup('4-6 Geometry / Linear Algebra / Calculus', [
      'Geometry primitives and transforms',
      'Dense + sparse matrix toolkit',
      'Symbolic and numeric calculus pipelines',
    ]),
    _ModuleGroup('7-10 Units / Data / Scripting / Workspace', [
      'Dimensional analysis registry',
      'CSV and JSON data tables',
      'Deterministic scripting runtime',
      'Notebook-like cell workspace',
    ]),
    _ModuleGroup('11-14 Debugging / IO / UX / Reactive', [
      'Rule-application trace engine',
      'Interoperability serializers',
      'Command palette and keyboard-first UX',
      'Dependency graph recomputation core',
    ]),
    _ModuleGroup('15-20 Collaboration / Security / Toolkits / Performance', [
      'CRDT sync protocol',
      'Sandboxed script executor',
      'EE / Mechanical / Signal toolkits',
      'GPU graph rendering and multithreading',
      'Constraint solver and system modeling',
    ]),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _cells = [
      const WorkspaceCell(
        id: 'cell-1',
        type: WorkspaceCellType.math,
        content: '(2+3)*(7-4)/5',
        output: '',
      ),
    ];
    _loadSnapshot();
    _recomputeDependencies();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _inputController.dispose();
    _rulePatternController.dispose();
    _ruleReplacementController.dispose();
    super.dispose();
  }

  void _evaluate() {
    try {
      final r = DeterministicExpressionEngine.evaluate(
        _inputController.text,
        notation: _notation,
      );

      setState(() {
        _result = r.displayValue;
        _tree = r.ast.pretty();
        _traceSteps = RewriteTraceEngine.trace(
          _inputController.text,
          userRules: _userRules,
        ).steps;
      });
    } catch (e) {
      setState(() {
        _result = 'Error: $e';
        _tree = 'AST unavailable due to parser error.';
        _traceSteps = const [];
      });
    }
  }

  void _addUserRule() {
    final pattern = _rulePatternController.text.trim();
    final replacement = _ruleReplacementController.text.trim();
    if (pattern.isEmpty) {
      return;
    }

    setState(() {
      _userRules.add(
        RewriteRule(
          id: 'user-${_userRules.length + 1}',
          name: 'User Rule ${_userRules.length + 1}',
          pattern: pattern,
          replacement: replacement,
        ),
      );
      _rulePatternController.clear();
      _ruleReplacementController.clear();
    });
  }

  Future<void> _saveSnapshot() async {
    final snapshot = WorkspaceSnapshot(
      input: _inputController.text,
      notation: _notation.name,
      cells: _cells,
    );

    await WorkspaceSnapshotService.saveSnapshot(snapshot);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Workspace snapshot saved.')),
    );
  }

  Future<void> _loadSnapshot() async {
    final snapshot = await WorkspaceSnapshotService.loadSnapshot();
    if (!mounted || snapshot == null) {
      return;
    }

    setState(() {
      _inputController.text = snapshot.input;
      _notation = snapshot.notation == InputNotation.postfix.name
          ? InputNotation.postfix
          : InputNotation.infix;
      _cells = snapshot.cells.isEmpty
          ? [
              const WorkspaceCell(
                id: 'cell-1',
                type: WorkspaceCellType.math,
                content: '',
                output: '',
              ),
            ]
          : snapshot.cells;
      _recomputeDependencies();
    });
  }

  void _addCell(WorkspaceCellType type) {
    setState(() {
      _cells = [
        ..._cells,
        WorkspaceCell(
          id: 'cell-${DateTime.now().microsecondsSinceEpoch}',
          type: type,
          content: '',
          output: '',
        ),
      ];
      _recomputeDependencies();
    });
  }

  void _removeCell(String id) {
    setState(() {
      _cells = _cells.where((cell) => cell.id != id).toList();
      _cellGraphSpots.remove(id);
      _codeStepTraces.remove(id);
      _recomputeDependencies();
    });
  }

  void _updateCellContent(String id, String content) {
    setState(() {
      _cells = _cells
          .map((cell) => cell.id == id ? cell.copyWith(content: content) : cell)
          .toList();
      _recomputeDependencies();
    });

    if (_autoRecompute) {
      _runAllCells();
    }
  }

  void _setCellOutput(String id, String output) {
    _cells = _cells
        .map((cell) => cell.id == id ? cell.copyWith(output: output) : cell)
        .toList();
  }

  void _runCell(WorkspaceCell cell) {
    final stopwatch = Stopwatch()..start();
    setState(() {
      _cellExecution[cell.id] = const _CellExecutionState(status: 'running');
    });

    try {
      if (cell.type == WorkspaceCellType.math) {
        final expr = _toRuntimeExpression(cell.content);
        final result = MathEngine.evaluate(expr);
        stopwatch.stop();
        setState(() {
          _setCellOutput(cell.id, result == 'Error' ? 'Error' : '= $result');
          _cellExecution[cell.id] = _CellExecutionState(
            status: result == 'Error' ? 'error' : 'ok',
            runtimeMs: stopwatch.elapsedMilliseconds,
          );
        });
        return;
      }

      if (cell.type == WorkspaceCellType.graph) {
        final expr = _toRuntimeExpression(cell.content);
        final spots = GraphEngine.generatePoints(
          expression: expr,
          minX: -10,
          maxX: 10,
          resolution: 140,
        );

        stopwatch.stop();
        setState(() {
          _cellGraphSpots[cell.id] = spots;
          _setCellOutput(cell.id, 'Rendered ${spots.length} points');
          _cellExecution[cell.id] = _CellExecutionState(
            status: 'ok',
            runtimeMs: stopwatch.elapsedMilliseconds,
          );
        });
        return;
      }

      if (cell.type == WorkspaceCellType.text) {
        final text = cell.content;
        final words = text.trim().isEmpty
            ? 0
            : text.trim().split(RegExp(r'\s+')).length;
        stopwatch.stop();
        setState(() {
          _setCellOutput(cell.id, '$words words, ${text.length} chars');
          _cellExecution[cell.id] = _CellExecutionState(
            status: 'ok',
            runtimeMs: stopwatch.elapsedMilliseconds,
          );
        });
        return;
      }

      final hasError = _runCodeCell(cell, recordSteps: false);
      stopwatch.stop();
      setState(() {
        _cellExecution[cell.id] = _CellExecutionState(
          status: hasError ? 'error' : 'ok',
          runtimeMs: stopwatch.elapsedMilliseconds,
        );
      });
    } catch (e) {
      stopwatch.stop();
      setState(() {
        _setCellOutput(cell.id, 'Error: $e');
        _cellExecution[cell.id] = _CellExecutionState(
          status: 'error',
          runtimeMs: stopwatch.elapsedMilliseconds,
          message: e.toString(),
        );
      });
    }
  }

  void _runAllCells() {
    _notebookVariables.clear();
    final order = NotebookDependencyEngine.topologicalOrder(_cells);
    final byId = {for (final c in _cells) c.id: c};

    if (order.cycleCellIds.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Dependency cycle detected for ${order.cycleCellIds.length} cell(s). Running in visual order.',
          ),
        ),
      );
      for (final c in _cells) {
        _runCell(c);
      }
      return;
    }

    for (final id in order.orderedCellIds) {
      final cell = byId[id];
      if (cell != null) {
        _runCell(cell);
      }
    }
  }

  void _recomputeDependencies() {
    _dependencyEdges = NotebookDependencyEngine.buildEdges(_cells);
  }

  String _cellOrdinalById(String id) {
    final index = _cells.indexWhere((c) => c.id == id);
    if (index < 0) {
      return '?';
    }
    return (index + 1).toString();
  }

  bool _runCodeCell(WorkspaceCell cell, {required bool recordSteps}) {
    final result = NotebookCodeExecutor.execute(
      code: cell.content,
      initialVariables: _notebookVariables,
      maxSteps: 500,
      timeBudgetMs: _executionBudgetMs,
    );

    _notebookVariables
      ..clear()
      ..addAll(result.variables);

    setState(() {
      _setCellOutput(
        cell.id,
        result.outputLines.isEmpty ? 'No output' : result.outputLines.join('\n'),
      );
      if (recordSteps) {
        _codeStepTraces[cell.id] = result.steps;
      }
    });

    if (result.timedOut) {
      return true;
    }

    return result.steps.any((s) => s.status == 'error');
  }

  void _debugCodeCell(WorkspaceCell cell) {
    final stopwatch = Stopwatch()..start();
    setState(() {
      _cellExecution[cell.id] = const _CellExecutionState(status: 'running');
    });

    final hasError = _runCodeCell(cell, recordSteps: true);
    final steps = _codeStepTraces[cell.id] ?? const <CodeStep>[];

    stopwatch.stop();
    setState(() {
      _cellExecution[cell.id] = _CellExecutionState(
        status: hasError ? 'error' : 'ok',
        runtimeMs: stopwatch.elapsedMilliseconds,
      );
    });

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(ctx).size.height * 0.75,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Text('Step Debug Trace', style: Theme.of(ctx).textTheme.titleLarge),
                ),
                Expanded(
                  child: steps.isEmpty
                      ? const Center(child: Text('No steps recorded.'))
                      : ListView.builder(
                          itemCount: steps.length,
                          itemBuilder: (_, i) {
                            final step = steps[i];
                            final before = step.beforeVariables.entries
                                .map((e) => '${e.key}=${e.value}')
                                .join(', ');
                            final after = step.afterVariables.entries
                                .map((e) => '${e.key}=${e.value}')
                                .join(', ');
                            return ListTile(
                              leading: Text('${i + 1}'),
                              title: Text('L${step.lineNumber}: ${step.line}'),
                              subtitle: Text(
                                '${step.message}\nBefore: ${before.isEmpty ? '-' : before}\nAfter: ${after.isEmpty ? '-' : after}',
                              ),
                              isThreeLine: true,
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _toRuntimeExpression(String input) {
    final maybeLatex = input.contains(r'\frac') ||
        input.contains(r'\sqrt') ||
        input.contains(r'\cdot') ||
        input.contains(r'\times');

    var expr = maybeLatex ? LatexInputAdapter.toExpression(input) : input;

    _notebookVariables.forEach((name, value) {
      expr = expr.replaceAll(RegExp('\\b$name\\b'), value);
    });
    return expr;
  }

  String _cellLabel(WorkspaceCellType type) {
    switch (type) {
      case WorkspaceCellType.math:
        return 'Math';
      case WorkspaceCellType.graph:
        return 'Graph';
      case WorkspaceCellType.text:
        return 'Text';
      case WorkspaceCellType.code:
        return 'Code';
    }
  }

  IconData _cellIcon(WorkspaceCellType type) {
    switch (type) {
      case WorkspaceCellType.math:
        return Icons.functions;
      case WorkspaceCellType.graph:
        return Icons.show_chart;
      case WorkspaceCellType.text:
        return Icons.notes;
      case WorkspaceCellType.code:
        return Icons.code;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced Workspace'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.input), text: 'Input Lab'),
            Tab(icon: Icon(Icons.alt_route), text: 'Trace'),
            Tab(icon: Icon(Icons.account_tree), text: 'AST'),
            Tab(icon: Icon(Icons.note_alt_outlined), text: 'Notebook'),
            Tab(icon: Icon(Icons.hub), text: 'Modules'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SegmentedButton<InputNotation>(
                  segments: const [
                    ButtonSegment(
                      value: InputNotation.infix,
                      label: Text('Infix'),
                    ),
                    ButtonSegment(
                      value: InputNotation.postfix,
                      label: Text('Postfix'),
                    ),
                  ],
                  selected: {_notation},
                  onSelectionChanged: (selection) {
                    setState(() => _notation = selection.first);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _inputController,
                  decoration: const InputDecoration(
                    labelText: 'Expression',
                    hintText: 'Infix: (2+3)*4, Postfix: 2 3 + 4 *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _evaluate,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Evaluate Deterministically'),
                ),
                const SizedBox(height: 20),
                Text('Result', style: theme.textTheme.titleMedium),
                const SizedBox(height: 6),
                SelectableText(
                  _result,
                  style: theme.textTheme.headlineSmall,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rule-based Rewrite Trace',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _rulePatternController,
                  decoration: const InputDecoration(
                    labelText: 'Custom regex pattern',
                    hintText: 'Example: x\\^2',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _ruleReplacementController,
                  decoration: const InputDecoration(
                    labelText: 'Replacement',
                    hintText: 'Example: (x)*(x)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    FilledButton.icon(
                      onPressed: _addUserRule,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Rule'),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: _evaluate,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Re-run Trace'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: _traceSteps.isEmpty
                      ? const Center(
                          child: Text('No rewrite steps yet. Evaluate an expression.'),
                        )
                      : ListView.builder(
                          itemCount: _traceSteps.length,
                          itemBuilder: (_, i) {
                            final step = _traceSteps[i];
                            return Card(
                              child: ListTile(
                                leading: Text('${i + 1}'),
                                title: Text(step.ruleName),
                                subtitle: Text('${step.before} -> ${step.after}'),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.dividerColor),
              ),
              child: SingleChildScrollView(
                child: SelectableText(
                  _tree,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontFamily: 'monospace',
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton.icon(
                      onPressed: () => _addCell(WorkspaceCellType.math),
                      icon: const Icon(Icons.functions),
                      label: const Text('Math Cell'),
                    ),
                    FilledButton.icon(
                      onPressed: () => _addCell(WorkspaceCellType.graph),
                      icon: const Icon(Icons.show_chart),
                      label: const Text('Graph Cell'),
                    ),
                    FilledButton.icon(
                      onPressed: () => _addCell(WorkspaceCellType.text),
                      icon: const Icon(Icons.notes),
                      label: const Text('Text Cell'),
                    ),
                    FilledButton.icon(
                      onPressed: () => _addCell(WorkspaceCellType.code),
                      icon: const Icon(Icons.code),
                      label: const Text('Code Cell'),
                    ),
                    OutlinedButton.icon(
                      onPressed: _saveSnapshot,
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('Save Snapshot'),
                    ),
                    OutlinedButton.icon(
                      onPressed: _loadSnapshot,
                      icon: const Icon(Icons.download_outlined),
                      label: const Text('Load Snapshot'),
                    ),
                    OutlinedButton.icon(
                      onPressed: _runAllCells,
                      icon: const Icon(Icons.playlist_play),
                      label: const Text('Run All Cells'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Switch(
                      value: _autoRecompute,
                      onChanged: (v) => setState(() => _autoRecompute = v),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text('Auto recompute on content changes'),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text('Execution budget (ms):'),
                    Expanded(
                      child: Slider(
                        value: _executionBudgetMs.toDouble(),
                        min: 20,
                        max: 500,
                        divisions: 24,
                        label: '$_executionBudgetMs',
                        onChanged: (v) {
                          setState(() => _executionBudgetMs = v.round());
                        },
                      ),
                    ),
                    Text('$_executionBudgetMs'),
                  ],
                ),
                if (_dependencyEdges.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _dependencyEdges
                          .map(
                            (edge) => Chip(
                              label: Text(
                                'Cell ${_cellOrdinalById(edge.fromCellId)} -> Cell ${_cellOrdinalById(edge.toCellId)} (${edge.variable})',
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Expanded(
                  child: _cells.isEmpty
                      ? const Center(child: Text('No notebook cells yet.'))
                      : ListView.builder(
                          itemCount: _cells.length,
                          itemBuilder: (_, i) {
                            final cell = _cells[i];
                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(_cellIcon(cell.type), size: 18),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${i + 1}. ${_cellLabel(cell.type)} Cell',
                                          style: theme.textTheme.titleSmall,
                                        ),
                                        const Spacer(),
                                        Builder(
                                          builder: (_) {
                                            final exec = _cellExecution[cell.id];
                                            final status = exec?.status ?? 'idle';
                                            Color color;
                                            switch (status) {
                                              case 'ok':
                                                color = Colors.green;
                                                break;
                                              case 'error':
                                                color = Colors.redAccent;
                                                break;
                                              case 'running':
                                                color = Colors.orange;
                                                break;
                                              default:
                                                color = theme.colorScheme.outline;
                                            }
                                            return Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.circle, size: 10, color: color),
                                                const SizedBox(width: 4),
                                                Text(
                                                  exec == null
                                                      ? 'idle'
                                                      : '${exec.status} ${exec.runtimeMs}ms',
                                                  style: theme.textTheme.bodySmall,
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                        const SizedBox(width: 6),
                                        IconButton(
                                          tooltip: 'Run cell',
                                          onPressed: () => _runCell(cell),
                                          icon: const Icon(Icons.play_arrow),
                                        ),
                                        if (cell.type == WorkspaceCellType.code)
                                          IconButton(
                                            tooltip: 'Step debug cell',
                                            onPressed: () => _debugCodeCell(cell),
                                            icon: const Icon(Icons.bug_report_outlined),
                                          ),
                                        IconButton(
                                          tooltip: 'Remove cell',
                                          onPressed: () => _removeCell(cell.id),
                                          icon: const Icon(Icons.delete_outline),
                                        ),
                                      ],
                                    ),
                                    TextFormField(
                                      key: ValueKey(cell.id),
                                      initialValue: cell.content,
                                      maxLines: cell.type == WorkspaceCellType.code ? 8 : 4,
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        hintText: 'Cell content',
                                      ),
                                      onChanged: (value) =>
                                          _updateCellContent(cell.id, value),
                                    ),
                                    if (cell.output.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.surfaceContainerHighest
                                              .withValues(alpha: 0.35),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: SelectableText(cell.output),
                                      ),
                                    ],
                                    if (cell.type == WorkspaceCellType.graph &&
                                        (_cellGraphSpots[cell.id]?.isNotEmpty ?? false)) ...[
                                      const SizedBox(height: 10),
                                      SizedBox(
                                        height: 160,
                                        child: LineChart(
                                          LineChartData(
                                            gridData: const FlGridData(show: true),
                                            borderData: FlBorderData(show: false),
                                            titlesData: const FlTitlesData(
                                              topTitles: AxisTitles(
                                                sideTitles: SideTitles(showTitles: false),
                                              ),
                                              rightTitles: AxisTitles(
                                                sideTitles: SideTitles(showTitles: false),
                                              ),
                                            ),
                                            lineBarsData: [
                                              LineChartBarData(
                                                spots: _cellGraphSpots[cell.id]!,
                                                isCurved: true,
                                                dotData: const FlDotData(show: false),
                                                barWidth: 2,
                                                color: theme.primaryColor,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
                if (_notebookVariables.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _notebookVariables.entries
                          .map(
                            (entry) => Chip(
                              avatar: const Icon(Icons.data_object, size: 16),
                              label: Text('${entry.key} = ${entry.value}'),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ],
            ),
          ),
          ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: _groups.length,
            itemBuilder: (_, i) {
              final group = _groups[i];
              return Card(
                child: ExpansionTile(
                  title: Text(group.title),
                  subtitle: const Text('Foundation + scaffold status'),
                  children: [
                    ...group.items.map(
                      (item) => ListTile(
                        dense: true,
                        leading: const Icon(Icons.check_circle_outline),
                        title: Text(item),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ModuleGroup {
  final String title;
  final List<String> items;

  const _ModuleGroup(this.title, this.items);
}

class _CellExecutionState {
  final String status;
  final int runtimeMs;
  final String message;

  const _CellExecutionState({
    required this.status,
    this.runtimeMs = 0,
    this.message = '',
  });
}
