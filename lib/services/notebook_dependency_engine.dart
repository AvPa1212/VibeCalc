import '../models/workspace_cell.dart';

class NotebookDependencyEdge {
  final String fromCellId;
  final String toCellId;
  final String variable;

  const NotebookDependencyEdge({
    required this.fromCellId,
    required this.toCellId,
    required this.variable,
  });
}

class NotebookDependencyEngine {
  static final RegExp _identifierRegex = RegExp(r'[a-zA-Z_]\w*');
  static const Set<String> _reserved = {
    'sin',
    'cos',
    'tan',
    'sqrt',
    'pi',
    'print',
    'frac',
  };

  static List<NotebookDependencyEdge> buildEdges(List<WorkspaceCell> cells) {
    final definedByCell = <String, String>{};
    for (final cell in cells) {
      for (final v in extractDefinedVariables(cell)) {
        definedByCell[v] = cell.id;
      }
    }

    final edges = <NotebookDependencyEdge>[];
    for (final cell in cells) {
      final used = extractUsedVariables(cell);
      for (final v in used) {
        final source = definedByCell[v];
        if (source == null || source == cell.id) {
          continue;
        }
        edges.add(NotebookDependencyEdge(
          fromCellId: source,
          toCellId: cell.id,
          variable: v,
        ));
      }
    }

    return edges;
  }

  static ({List<String> orderedCellIds, List<String> cycleCellIds})
      topologicalOrder(List<WorkspaceCell> cells) {
    final edges = buildEdges(cells);
    final ids = cells.map((c) => c.id).toList();

    final outgoing = <String, Set<String>>{
      for (final id in ids) id: <String>{},
    };
    final indegree = <String, int>{
      for (final id in ids) id: 0,
    };

    for (final e in edges) {
      if (outgoing[e.fromCellId]!.add(e.toCellId)) {
        indegree[e.toCellId] = (indegree[e.toCellId] ?? 0) + 1;
      }
    }

    final queue = <String>[];
    for (final id in ids) {
      if ((indegree[id] ?? 0) == 0) {
        queue.add(id);
      }
    }

    final ordered = <String>[];
    var index = 0;
    while (index < queue.length) {
      final current = queue[index++];
      ordered.add(current);

      for (final next in outgoing[current] ?? const <String>{}) {
        final nextIn = (indegree[next] ?? 0) - 1;
        indegree[next] = nextIn;
        if (nextIn == 0) {
          queue.add(next);
        }
      }
    }

    final cycleNodes = ids.where((id) => !ordered.contains(id)).toList();
    return (orderedCellIds: ordered, cycleCellIds: cycleNodes);
  }

  static Set<String> extractDefinedVariables(WorkspaceCell cell) {
    if (cell.type != WorkspaceCellType.code) {
      return const <String>{};
    }

    final out = <String>{};
    final lines = cell.content.split('\n');
    final assignRegex = RegExp(r'^\s*([a-zA-Z_]\w*)\s*=\s*(.+)$');

    for (final line in lines) {
      final match = assignRegex.firstMatch(line);
      if (match != null) {
        out.add(match.group(1)!);
      }
    }

    return out;
  }

  static Set<String> extractUsedVariables(WorkspaceCell cell) {
    var content = cell.content;
    if (cell.type == WorkspaceCellType.code) {
      content = content.replaceAll(RegExp(r'^\s*print\s+', multiLine: true), '');
      content = content.replaceAll(RegExp(r'^\s*[a-zA-Z_]\w*\s*=\s*', multiLine: true), '');
    }

    final found = _identifierRegex
        .allMatches(content)
        .map((m) => m.group(0)!)
        .where((name) => !_reserved.contains(name))
        .toSet();

    return found;
  }
}
