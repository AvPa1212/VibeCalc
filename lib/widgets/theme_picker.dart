import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/persistence_service.dart';

class HistoryDrawer extends StatefulWidget {
  final Function(String) onItemSelected;

  const HistoryDrawer({
    super.key,
    required this.onItemSelected,
  });

  @override
  State<HistoryDrawer> createState() => _HistoryDrawerState();
}

class _HistoryDrawerState extends State<HistoryDrawer>
    with SingleTickerProviderStateMixin {
  List<String> history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    setState(() {
      history = PersistenceService().getHistory();
    });
  }

  Future<void> _deleteItem(int index) async {
    setState(() {
      history.removeAt(index);
    });
    await PersistenceService().saveHistory(history);
    HapticFeedback.lightImpact();
  }

  Future<void> _clearAll() async {
    await PersistenceService().clearHistory();
    setState(() => history.clear());
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.surface.withOpacity(0.95),
              theme.colorScheme.surface.withOpacity(0.85),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              /// Header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "History",
                      style: theme.textTheme.titleLarge,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: history.isEmpty
                          ? null
                          : () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text("Clear History?"),
                                  content: const Text(
                                      "This will permanently delete all entries."),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text("Clear"),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                _clearAll();
                              }
                            },
                    )
                  ],
                ),
              ),

              const Divider(height: 1),

              /// History List
              Expanded(
                child: history.isEmpty
                    ? Center(
                        child: Text(
                          "No calculations yet",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withOpacity(0.5),
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: history.length,
                        itemBuilder: (context, index) {
                          final item = history[index];

                          return Dismissible(
                            key: ValueKey(item + index.toString()),
                            direction: DismissDirection.endToStart,
                            onDismissed: (_) => _deleteItem(index),
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              color: Colors.redAccent,
                              child: const Icon(Icons.delete,
                                  color: Colors.white),
                            ),
                            child: ListTile(
                              title: Text(
                                item,
                                style: theme.textTheme.bodyMedium,
                                overflow: TextOverflow.ellipsis,
                              ),
                              onTap: () {
                                widget.onItemSelected(item);
                                Navigator.pop(context);
                                HapticFeedback.selectionClick();
                              },
                              onLongPress: () async {
                                await Clipboard.setData(
                                    ClipboardData(text: item));
                                HapticFeedback.mediumImpact();

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Copied to clipboard"),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}