import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/workspace_cell.dart';

class WorkspaceSnapshot {
  final String input;
  final String notation;
  final List<WorkspaceCell> cells;

  const WorkspaceSnapshot({
    required this.input,
    required this.notation,
    required this.cells,
  });

  Map<String, dynamic> toJson() {
    return {
      'input': input,
      'notation': notation,
      'cells': cells.map((c) => c.toJson()).toList(),
    };
  }

  factory WorkspaceSnapshot.fromJson(Map<String, dynamic> json) {
    final cellData = (json['cells'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    return WorkspaceSnapshot(
      input: (json['input'] ?? '').toString(),
      notation: (json['notation'] ?? 'infix').toString(),
      cells: cellData.map(WorkspaceCell.fromJson).toList(),
    );
  }
}

class WorkspaceSnapshotService {
  static const String _snapshotKey = 'advanced_workspace_snapshot_v1';

  static Future<void> saveSnapshot(WorkspaceSnapshot snapshot) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_snapshotKey, jsonEncode(snapshot.toJson()));
  }

  static Future<WorkspaceSnapshot?> loadSnapshot() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_snapshotKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      final parsed = jsonDecode(raw);
      if (parsed is! Map<String, dynamic>) {
        return null;
      }
      return WorkspaceSnapshot.fromJson(parsed);
    } catch (_) {
      return null;
    }
  }
}
