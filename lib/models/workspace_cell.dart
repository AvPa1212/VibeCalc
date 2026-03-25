enum WorkspaceCellType { math, graph, text, code }

WorkspaceCellType workspaceCellTypeFromString(String value) {
  switch (value) {
    case 'math':
      return WorkspaceCellType.math;
    case 'graph':
      return WorkspaceCellType.graph;
    case 'text':
      return WorkspaceCellType.text;
    case 'code':
      return WorkspaceCellType.code;
    default:
      return WorkspaceCellType.text;
  }
}

String workspaceCellTypeToString(WorkspaceCellType type) {
  switch (type) {
    case WorkspaceCellType.math:
      return 'math';
    case WorkspaceCellType.graph:
      return 'graph';
    case WorkspaceCellType.text:
      return 'text';
    case WorkspaceCellType.code:
      return 'code';
  }
}

class WorkspaceCell {
  final String id;
  final WorkspaceCellType type;
  final String content;
  final String output;

  const WorkspaceCell({
    required this.id,
    required this.type,
    required this.content,
    this.output = '',
  });

  WorkspaceCell copyWith({
    String? id,
    WorkspaceCellType? type,
    String? content,
    String? output,
  }) {
    return WorkspaceCell(
      id: id ?? this.id,
      type: type ?? this.type,
      content: content ?? this.content,
      output: output ?? this.output,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': workspaceCellTypeToString(type),
      'content': content,
      'output': output,
    };
  }

  factory WorkspaceCell.fromJson(Map<String, dynamic> json) {
    return WorkspaceCell(
      id: (json['id'] ?? '').toString(),
      type: workspaceCellTypeFromString((json['type'] ?? 'text').toString()),
      content: (json['content'] ?? '').toString(),
      output: (json['output'] ?? '').toString(),
    );
  }
}
