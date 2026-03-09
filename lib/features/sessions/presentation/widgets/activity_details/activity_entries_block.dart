import 'package:flutter/material.dart';
import 'package:tenk/features/sessions/domain/models/session_entry.dart';
import 'package:tenk/features/sessions/presentation/screens/add_manual_screen.dart';
import 'package:tenk/features/sessions/presentation/screens/activity_details/activity_details_utils.dart';

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
    final cs = Theme.of(context).colorScheme;

    final entriesSorted = [...widget.entries]
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));

    // aggregate for chart: last 30 days (inclusive)
    final series = _buildDailySeries(entriesSorted, days: 30);
    final maxMinutes = series.isEmpty
        ? 0
        : series.map((x) => x.minutes).reduce((a, b) => a > b ? a : b);

    return Card(
      elevation: 0,
      color: cs.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: cs.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Text('Entries', style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                _HeaderToggle(
                  mode: _mode,
                  onChanged: (m) => setState(() => _mode = m),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Actions row
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FilledButton.tonalIcon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => AddManualScreen(activityId: widget.activityId),
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

            // Content
            if (_mode == _EntriesViewMode.chart) ...[
              _EntriesBarChart(
                series: series,
                maxMinutes: maxMinutes,
              ),
            ] else ...[
              _EntriesListPreview(entries: entriesSorted),
            ],

            const SizedBox(height: 10),

            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('See more: TODO')),
                  );
                },
                child: const Text('See more'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds daily minutes for the last [days] days (today included).
  List<_DayBucket> _buildDailySeries(List<SessionEntry> entries, {required int days}) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // map dayStart -> minutes
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
}

class _EntriesBarChart extends StatelessWidget {
  final List<_DayBucket> series;
  final int maxMinutes;

  const _EntriesBarChart({
    required this.series,
    required this.maxMinutes,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (series.isEmpty) {
      return Text(
        'No entries yet',
        style: Theme.of(context).textTheme.bodyMedium,
      );
    }

    // Chart layout
    const chartHeight = 120.0;
    const barWidth = 14.0;
    const barGap = 10.0;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: SizedBox(
        height: chartHeight + 26, // bars + labels
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final b in series) ...[
                  _Bar(
                    minutes: b.minutes,
                    maxMinutes: maxMinutes,
                    width: barWidth,
                    height: chartHeight,
                    label: _shortDayLabel(b.day),
                  ),
                  const SizedBox(width: barGap),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _shortDayLabel(DateTime d) {
    // just day-of-month: 1..31
    return '${d.day}';
  }
}

class _Bar extends StatelessWidget {
  final int minutes;
  final int maxMinutes;
  final double width;
  final double height;
  final String label;

  const _Bar({
    required this.minutes,
    required this.maxMinutes,
    required this.width,
    required this.height,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final t = maxMinutes <= 0 ? 0.0 : (minutes / maxMinutes).clamp(0.0, 1.0);
    final barH = (height * t).clamp(2.0, height);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Tooltip(
          message: minutes == 0
              ? '0m'
              : ActivityDetailsUtils.formatHoursMinutes(minutes),
          child: Container(
            width: width,
            height: barH,
            decoration: BoxDecoration(
              color: minutes == 0 ? cs.outlineVariant : cs.primary,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall,
        ),
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

    final preview = entries.take(5).toList();

    return Column(
      children: [
        for (final e in preview) ...[
          _EntryRow(entry: e),
        ],
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

    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              width: 54,
              child: Text(
                time,
                style: Theme.of(context).textTheme.labelLarge,
              ),
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
        Divider(height: 1),
      ],
    );
  }
}

class _DayBucket {
  final DateTime day;
  final int minutes;
  const _DayBucket({required this.day, required this.minutes});
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