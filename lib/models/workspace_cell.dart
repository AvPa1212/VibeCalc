enum WorkspaceCellType { math, graph, text, code }

class WorkspaceCell {
  final String id;
  final WorkspaceCellType type;
  final String content;

  const WorkspaceCell({
    required this.id,
    required this.type,
    required this.content,
  });
}
