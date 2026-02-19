import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tenk/features/activities/domain/models/activity.dart';
import 'package:tenk/features/activities/presentation/state/activities_controller.dart';
import 'package:tenk/features/sessions/domain/models/session_entry.dart';
import 'package:tenk/features/sessions/presentation/state/sessions_controller.dart';
import 'package:tenk/features/sessions/presentation/widgets/edit_session_dialog.dart';
import 'package:tenk/features/sessions/presentation/widgets/confirm_delete_session_dialog.dart';

import 'activity_details_screen.dart';
import 'dashboard_screen.dart'; // activityPalette

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sessionsC = context.watch<SessionsController>();
    final activitiesC = context.watch<ActivitiesController>();

    final byId = <String, Activity>{
      for (final a in activitiesC.activities) a.id: a,
    };

    final items = [...sessionsC.entries]
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));

    final rows = _buildRows(items);

    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: rows.isEmpty
              ? const Text('No sessions yet')
              : ListView.separated(
                  itemCount: rows.length,
                  separatorBuilder: (_, index) => const SizedBox(height: 8),
                  itemBuilder: (ctx, i) {
                    final r = rows[i];

                    if (r.isHeader) {
                      return _DayHeader(title: r.header!);
                    }

                    final e = r.entry!;
                    final subtitle = (e.note == null || e.note!.trim().isEmpty)
                        ? _formatDateTime(e.startedAt)
                        : '${_formatDateTime(e.startedAt)}\n${e.note}';

                    return Dismissible(
                      key: ValueKey(e.id),
                      direction: DismissDirection.horizontal,
                      background: _editBackground(),
                      secondaryBackground: _deleteBackground(),
                      confirmDismiss: (direction) async {
                        // Capture deps BEFORE await to satisfy linter.
                        final sessions = ctx.read<SessionsController>();

                        if (direction == DismissDirection.startToEnd) {
                          // Swipe right -> edit (do not dismiss)
                          final updated = await showEditSessionDialog(
                            ctx,
                            entry: e,
                          );
                          if (updated != null) {
                            await sessions.updateEntry(updated);
                          }
                          return false;
                        }

                        // Swipe left -> confirm delete
                        final ok = await confirmDeleteSessionDialog(
                          ctx,
                          entry: e,
                        );
                        return ok == true;
                      },
                      onDismissed: (direction) async {
                        if (direction != DismissDirection.endToStart) return;

                        // Capture deps BEFORE await to satisfy linter.
                        final sessions = ctx.read<SessionsController>();
                        await sessions.deleteEntry(e.id);
                      },
                      child: ListTile(
                        leading: _leading(ctx, byId, e),
                        title: Text('${e.minutes} min'),
                        subtitle: Text(subtitle),
                        isThreeLine:
                            e.note != null && e.note!.trim().isNotEmpty,
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }

  static List<_HistoryRow> _buildRows(List<SessionEntry> items) {
    final rows = <_HistoryRow>[];
    String? lastDay;

    for (final e in items) {
      final day = _dateKey(e.startedAt);
      if (day != lastDay) {
        rows.add(_HistoryRow.header(day));
        lastDay = day;
      }
      rows.add(_HistoryRow.entry(e));
    }

    return rows;
  }

  static Widget _leading(
    BuildContext ctx,
    Map<String, Activity> byId,
    SessionEntry e,
  ) {
    final act = byId[e.activityId];
    final title = act?.title ?? e.activityId;

    final color = act == null
        ? Theme.of(ctx).colorScheme.primary
        : activityPalette[act.colorIndex % activityPalette.length];

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: () {
        if (act == null) return;

        Navigator.of(ctx).push(
          MaterialPageRoute<void>(
            builder: (_) =>
                ActivityDetailsScreen(activityId: act.id, autoStart: false),
          ),
        );
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 90),
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(ctx).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _editBackground() {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: const Text('Edit'),
    );
  }

  static Widget _deleteBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: const Text('Delete'),
    );
  }

  static String _dateKey(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  static String _formatDateTime(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$y-$m-$d $hh:$mm';
  }
}

class _DayHeader extends StatelessWidget {
  final String title;
  const _DayHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Text(title, style: Theme.of(context).textTheme.titleSmall),
    );
  }
}

class _HistoryRow {
  final String? header;
  final SessionEntry? entry;

  bool get isHeader => header != null;

  _HistoryRow.header(this.header) : entry = null;
  _HistoryRow.entry(this.entry) : header = null;
}
