import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tenk/features/sessions/domain/models/session_entry.dart';
import 'package:tenk/features/sessions/presentation/state/sessions_controller.dart';
import 'package:tenk/features/sessions/presentation/screens/activity_details/activity_details_utils.dart';

import 'package:tenk/features/sessions/presentation/widgets/activity_details/activity_entries_chart.dart';
import 'package:tenk/features/sessions/presentation/widgets/edit_session_dialog.dart';
import 'package:tenk/features/sessions/presentation/widgets/confirm_delete_session_dialog.dart';
import 'package:tenk/ui/ui_tokens.dart';

enum _EntriesViewMode { chart, list }

class ActivityEntriesBlock extends StatefulWidget {
  final String activityId;
  final List<SessionEntry> entries;
  final Future<void> Function() onImportExperience;
  final Future<void> Function() onAddManual;

  const ActivityEntriesBlock({
    super.key,
    required this.activityId,
    required this.entries,
    required this.onImportExperience,
    required this.onAddManual,
  });

  @override
  State<ActivityEntriesBlock> createState() => _ActivityEntriesBlockState();
}

class _ActivityEntriesBlockState extends State<ActivityEntriesBlock> {
  _EntriesViewMode _mode = _EntriesViewMode.chart;

  int _listLimit = 10;
  static const int _listStep = 20;

  @override
  Widget build(BuildContext context) {
    final entriesSorted = [...widget.entries]
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));

    // Daily series: last 30 days
    final daily = ActivityDetailsUtils.dailyBars(
      entries: entriesSorted,
      activityId: widget.activityId,
      days: 30,
    );

    final monthly = ActivityDetailsUtils.monthlyBars(
      entries: entriesSorted,
      activityId: widget.activityId,
      months: 12,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row: Entries + List/Chart toggle
        Row(
          children: [
            Text(
              'Entries',
              style: sectionTitleStyle(context),
            ),
            const Spacer(),
            _HeaderToggle(
              mode: _mode,
              onChanged: (m) => setState(() => _mode = m),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Actions
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            FilledButton.tonalIcon(
              onPressed: () => widget.onAddManual(),
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('Add entry'),
            ),
            OutlinedButton.icon(
              onPressed: () => widget.onImportExperience(),
              icon: const Icon(Icons.file_download, size: 18),
              label: const Text('Add experience'),
            ),
          ],
        ),

        const SizedBox(height: 12),

        if (_mode == _EntriesViewMode.chart) ...[
          ActivityEntriesChart(
            daily: daily,
            monthly: monthly,
            initialMode: ActivityChartMode.daily,
          ),
        ] else ...[
          _EntriesListPreview(
            entries: entriesSorted,
            limit: _listLimit,
            onEdit: _editEntry,
            onDelete: _deleteEntry,
          ),
          const SizedBox(height: 6),
          if (entriesSorted.length > _listLimit)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => setState(() => _listLimit += _listStep),
                child: const Text('See more'),
              ),
            ),
        ],
      ],
    );
  }

  Future<void> _editEntry(SessionEntry entry) async {
    final sessions = context.read<SessionsController>();
    final updated = await showEditSessionDialog(context, entry: entry);
    if (updated == null) return;
    await sessions.updateEntry(updated);
  }

  Future<bool> _deleteEntry(SessionEntry entry) async {
    final sessions = context.read<SessionsController>();
    final ok = await confirmDeleteSessionDialog(context, entry: entry);
    if (ok != true) return false;

    await sessions.deleteEntry(entry.id);
    return true;
  }
}

class _HeaderToggle extends StatelessWidget {
  final _EntriesViewMode mode;
  final ValueChanged<_EntriesViewMode> onChanged;

  const _HeaderToggle({
    required this.mode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Widget item({
      required _EntriesViewMode value,
      required IconData icon,
      required String label,
    }) {
      final selected = mode == value;

      return InkWell(
        onTap: () => onChanged(value),
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: selected ? cs.primary : cs.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: selected ? cs.primary : cs.onSurfaceVariant,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        item(value: _EntriesViewMode.list, icon: Icons.list, label: 'List'),
        const SizedBox(width: 6),
        Text('·', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(width: 6),
        item(value: _EntriesViewMode.chart, icon: Icons.bar_chart, label: 'Chart'),
      ],
    );
  }
}

class _EntriesListPreview extends StatelessWidget {
  final List<SessionEntry> entries;
  final int limit;
  final Future<void> Function(SessionEntry entry) onEdit;
  final Future<bool> Function(SessionEntry entry) onDelete;

  const _EntriesListPreview({
    required this.entries,
    required this.limit,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Text(
        'No entries yet',
        style: Theme.of(context).textTheme.bodyMedium,
      );
    }

    final preview = entries.take(limit).toList();

    return Column(
      children: [
        for (final e in preview)
          _EntryRow(
            entry: e,
            onEdit: () => onEdit(e),
            onDelete: () => onDelete(e),
          ),
      ],
    );
  }
}

class _EntryRow extends StatelessWidget {
  final SessionEntry entry;
  final Future<void> Function() onEdit;
  final Future<bool> Function() onDelete;

  const _EntryRow({
    required this.entry,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final stamp = ActivityDetailsUtils.dateTimeLabel(entry.startedAt);
    final dur = ActivityDetailsUtils.formatHoursMinutes(entry.minutes);
    final title = entry.note?.isNotEmpty == true ? entry.note! : 'Session';

    return Dismissible(
      key: ValueKey('entry_${entry.id}'),
      direction: DismissDirection.horizontal,
      background: _SwipeBg(
        icon: Icons.edit,
        label: 'Edit',
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 16),
        tint: Colors.amber,
      ),
      secondaryBackground: _SwipeBg(
        icon: Icons.delete_outline,
        label: 'Delete',
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        tint: Colors.red,
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Edit swipe: do not dismiss the row
          await onEdit();
          return false;
        }

        if (direction == DismissDirection.endToStart) {
          // Delete swipe: run delete flow and dismiss only if actually deleted
          await onDelete();
          // We can't reliably know if user confirmed deletion unless onDelete returns bool.
          // So we keep the row and let controller update the list after deletion.
          return false;
        }

        return false;
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: 110,
                  child: Text(stamp, style: Theme.of(context).textTheme.labelLarge),
                ),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(width: 10),
                Text(dur, style: Theme.of(context).textTheme.labelLarge),
              ],
            ),
            const SizedBox(height: 5),
            const Divider(height: 1),
          ],
        ),
      ),
    );
  }
}

class _SwipeBg extends StatelessWidget {
  final IconData icon;
  final String label;
  final Alignment alignment;
  final EdgeInsets padding;
  final Color tint;

  const _SwipeBg({
    required this.icon,
    required this.label,
    required this.alignment,
    required this.padding,
    required this.tint,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      alignment: alignment,
      padding: padding,
      color: tint.withValues(alpha: 0.12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: cs.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
