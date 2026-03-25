import 'package:flutter_test/flutter_test.dart';
import 'package:vibecalc/models/workspace_cell.dart';
import 'package:vibecalc/services/notebook_dependency_engine.dart';

void main() {
  group('NotebookDependencyEngine', () {
    test('extracts defined and used variables for code cells', () {
      const cell = WorkspaceCell(
        id: 'c1',
        type: WorkspaceCellType.code,
        content: 'x = 2\ny = x + sin\nprint y + z',
      );

      final defined = NotebookDependencyEngine.extractDefinedVariables(cell);
      final used = NotebookDependencyEngine.extractUsedVariables(cell);

      expect(defined, {'x', 'y'});
      expect(used, {'x', 'y', 'z'});
    });

    test('uses most recent definition when building edges', () {
      const cells = [
        WorkspaceCell(
          id: 'c1',
          type: WorkspaceCellType.code,
          content: 'a = 1',
        ),
        WorkspaceCell(
          id: 'c2',
          type: WorkspaceCellType.code,
          content: 'a = 2',
        ),
        WorkspaceCell(
          id: 'c3',
          type: WorkspaceCellType.code,
          content: 'b = a + 1\nprint b',
        ),
      ];

      final edges = NotebookDependencyEngine.buildEdges(cells);

      expect(edges.length, 1);
      expect(edges.first.fromCellId, 'c2');
      expect(edges.first.toCellId, 'c3');
      expect(edges.first.variable, 'a');
    });

    test('detects dependency cycles in topological order', () {
      const cells = [
        WorkspaceCell(
          id: 'c1',
          type: WorkspaceCellType.code,
          content: 'a = b + 1',
        ),
        WorkspaceCell(
          id: 'c2',
          type: WorkspaceCellType.code,
          content: 'b = a + 1',
        ),
      ];

      final order = NotebookDependencyEngine.topologicalOrder(cells);

      expect(order.orderedCellIds, isEmpty);
      expect(order.cycleCellIds.toSet(), {'c1', 'c2'});
    });
  });
}
