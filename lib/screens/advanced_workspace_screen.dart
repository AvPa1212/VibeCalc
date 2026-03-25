import 'package:flutter/material.dart';

import '../services/deterministic_expression_engine.dart';

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

  InputNotation _notation = InputNotation.infix;
  String _result = 'Run an expression to preview deterministic evaluation.';
  String _tree = 'AST will appear here.';

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
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _inputController.dispose();
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
      });
    } catch (e) {
      setState(() {
        _result = 'Error: $e';
        _tree = 'AST unavailable due to parser error.';
      });
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
            Tab(icon: Icon(Icons.account_tree), text: 'AST'),
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
