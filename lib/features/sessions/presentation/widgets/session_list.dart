import 'package:flutter/material.dart';

import 'package:tenk/features/sessions/domain/models/session_entry.dart';

class SessionList extends StatelessWidget {
  final List<SessionEntry> entries;
  final Future<void> Function(String id) onDelete;
  final void Function(SessionEntry entry) onEdit;
  final Widget Function(BuildContext context, SessionEntry entry)?
  leadingBuilder;
  final Future<bool> Function(BuildContext context, SessionEntry entry)?
  confirmDelete;

  const SessionList({
    super.key,
    required this.entries,
    required this.onDelete,
    required this.onEdit,
    this.leadingBuilder,
    this.confirmDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const Text('No sessions yet');
    }

    return ListView.separated(
      itemCount: entries.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final e = entries[index];

        final subtitle = e.note == null || e.note!.trim().isEmpty
            ? _formatDateTime(e.startedAt)
            : '${_formatDateTime(e.startedAt)}\n${e.note}';

        final leading = leadingBuilder?.call(context, e);

        return Dismissible(
          key: ValueKey(e.id),
          direction: DismissDirection.horizontal,
          background: _editBackground(),
          secondaryBackground: _deleteBackground(),
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.startToEnd) {
              // Swipe right -> edit (do not dismiss)
              onEdit(e);
              return false;
            }

            // Swipe left -> delete
            if (confirmDelete == null) return true;
            return await confirmDelete!(context, e);
          },
          onDismissed: (direction) async {
            if (direction == DismissDirection.endToStart) {
              await onDelete(e.id);
            }
          },
          child: ListTile(
            leading: leading,
            title: Text('${e.minutes} min'),
            subtitle: Text(subtitle),
            isThreeLine: e.note != null && e.note!.trim().isNotEmpty,
          ),
        );
      },
    );
  }

  Widget _editBackground() {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: const Text('Edit'),
    );
  }

  Widget _deleteBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: const Text('Delete'),
    );
  }

  String _formatDateTime(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$y-$m-$d $hh:$mm';
  }
}
