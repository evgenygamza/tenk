import 'package:flutter/material.dart';

import 'package:tenk/features/sessions/domain/models/session_entry.dart';
import 'package:tenk/features/sessions/presentation/screens/add_manual_screen.dart';
import 'package:tenk/features/sessions/presentation/screens/activity_details/activity_details_utils.dart';
import 'package:tenk/features/sessions/presentation/widgets/activity_details/activity_entries_chart.dart';

enum _EntriesViewMode { chart, list }

class ActivityEntriesBlock extends StatefulWidget {
  final String activityId;
  final List<SessionEntry> entries;
  final VoidCallback onImportExperience;

  const ActivityEntriesBlock({
    super.key,
    required this.activityId,
    required this.entries,
    required this.onImportExperience,
  });

  @override
  State<ActivityEntriesBlock> createState() => _ActivityEntriesBlockState();
}

class _ActivityEntriesBlockState extends State<ActivityEntriesBlock> {
  _EntriesViewMode _mode = _EntriesViewMode.chart;

  @override
  Widget build(BuildContext context) {
    final entriesSorted = [...widget.entries]
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));

    // Daily series: last 30 days
    final dailyBuckets = _buildDailySeries(entriesSorted, days: 30);
    final daily = dailyBuckets
        .map((b) => ActivityChartBar(label: _dailyLabel(b.day), minutes: b.minutes))
        .toList();

    // Monthly series: last 12 months totals
    final monthly = _buildMonthlyTotalsSeries(entriesSorted, months: 12);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row: Entries + List/Chart toggle
        Row(
          children: [
            Text(
              'Entries',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
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
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        AddManualScreen(activityId: widget.activityId),
                  ),
                );
              },
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('Manual'),
            ),
            OutlinedButton.icon(
              onPressed: widget.onImportExperience,
              icon: const Icon(Icons.file_download, size: 18),
              label: const Text('Import'),
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
          _EntriesListPreview(entries: entriesSorted),
        ],
      ],
    );
  }

  // ---------- helpers ----------

  List<_DayBucket> _buildDailySeries(List<SessionEntry> entries,
      {required int days}) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final map = <DateTime, int>{};

    for (final e in entries) {
      if (e.activityId != widget.activityId) continue;
      final d = DateTime(e.startedAt.year, e.startedAt.month, e.startedAt.day);
      map[d] = (map[d] ?? 0) + e.minutes;
    }

    final out = <_DayBucket>[];
    for (var i = days - 1; i >= 0; i--) {
      final d = today.subtract(Duration(days: i));
      out.add(_DayBucket(day: d, minutes: map[d] ?? 0));
    }
    return out;
  }

  List<ActivityChartBar> _buildMonthlyTotalsSeries(
      List<SessionEntry> entries, {
        int months = 12,
      }) {
    final now = DateTime.now();
    final thisMonth = DateTime(now.year, now.month, 1);

    DateTime addMonths(DateTime d, int delta) {
      final y = d.year + ((d.month - 1 + delta) ~/ 12);
      final m = ((d.month - 1 + delta) % 12) + 1;
      return DateTime(y, m, 1);
    }

    // monthStart -> minutes
    final map = <DateTime, int>{};

    for (final e in entries) {
      if (e.activityId != widget.activityId) continue;
      final mStart = DateTime(e.startedAt.year, e.startedAt.month, 1);
      map[mStart] = (map[mStart] ?? 0) + e.minutes;
    }

    final out = <ActivityChartBar>[];
    for (var i = months - 1; i >= 0; i--) {
      final mStart = addMonths(thisMonth, -i);
      final minutes = map[mStart] ?? 0;

      // Label: month, show year on January
      final label = _monthLabel(mStart);

      out.add(ActivityChartBar(label: label, minutes: minutes));
    }
    return out;
  }

  String _mon(int m) {
    const names = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    return names[(m - 1).clamp(0, 11)];
  }

  String _dailyLabel(DateTime d) {
    return d.day == 1 ? '${_mon(d.month)} 1' : '${d.day}';
  }

  String _monthLabel(DateTime monthStart) {
    // show year on January
    return monthStart.month == 1
        ? '${monthStart.year} Jan'
        : _mon(monthStart.month);
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

  const _EntriesListPreview({required this.entries});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Text(
        'No entries yet',
        style: Theme.of(context).textTheme.bodyMedium,
      );
    }

    final preview = entries.take(6).toList();

    return Column(
      children: [
        for (final e in preview) _EntryRow(entry: e),
      ],
    );
  }
}

class _EntryRow extends StatelessWidget {
  final SessionEntry entry;

  const _EntryRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    final time =
        '${entry.startedAt.hour.toString().padLeft(2, '0')}:${entry.startedAt.minute.toString().padLeft(2, '0')}';
    final dur = ActivityDetailsUtils.formatHoursMinutes(entry.minutes);
    final title = entry.note?.isNotEmpty == true ? entry.note! : 'Session';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 54,
                child: Text(time, style: Theme.of(context).textTheme.labelLarge),
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
          const SizedBox(height: 8),
          const Divider(height: 1),
        ],
      ),
    );
  }
}

class _DayBucket {
  final DateTime day;
  final int minutes;
  const _DayBucket({required this.day, required this.minutes});
}