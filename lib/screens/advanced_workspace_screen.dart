import 'package:flutter/material.dart';

import '../models/workspace_cell.dart';
import '../services/deterministic_expression_engine.dart';
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
      ),
    ];
    _loadSnapshot();
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
              ),
            ]
          : snapshot.cells;
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
        ),
      ];
    });
  }

  void _removeCell(String id) {
    setState(() {
      _cells = _cells.where((cell) => cell.id != id).toList();
    });
  }

  void _updateCellContent(String id, String content) {
    setState(() {
      _cells = _cells
          .map((cell) => cell.id == id ? cell.copyWith(content: content) : cell)
          .toList();
    });
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
                  ],
                ),
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
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
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
