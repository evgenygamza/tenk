import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tenk/features/sessions/presentation/state/sessions_controller.dart';
import 'package:tenk/features/sessions/presentation/screens/activity_details/activity_details_utils.dart';
import 'package:tenk/ui/progress_bar.dart';

class ActivityStatsBlock extends StatelessWidget {
  final String activityId;
  final Color accent;
  final VoidCallback onMoreStats;

  const ActivityStatsBlock({
    super.key,
    required this.activityId,
    required this.accent,
    required this.onMoreStats,
  });

  @override
  Widget build(BuildContext context) {
    final sessions = context.watch<SessionsController>();

    // Data
    final totalMinutes = sessions.totalMinutesAllTime(activityId);
    final todayMinutes = sessions.totalMinutesToday(activityId);
    final thisWeekMinutes = ActivityDetailsUtils.minutesThisWeek(
      entries: sessions.entries,
      activityId: activityId,
    );

    final etaDays = ActivityDetailsUtils.etaDaysToCurrentGoal(
      entries: sessions.entries,
      activityId: activityId,
      totalMinutesAllTime: totalMinutes,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Optional header
        Row(
          children: [
            Text(
              'Stats',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Spacer(),
            TextButton(
              onPressed: onMoreStats,
              child: const Text('More stats →'),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Main number (ETA)
        if (etaDays == null) ...[
          Text(
            'No data yet 👀',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Track a few sessions to get ETA',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ] else ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${etaDays} days',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  'to current goal',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
        ],

        Padding(
          padding: const EdgeInsets.all(12),
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: ProgressBar(
              totalMinutesAllTime: totalMinutes,
              color: accent,
            ),
          ),
        ),

        const SizedBox(height: 6),

        // Tiles row
        Row(
          children: [
            Expanded(
              child: _MiniTile(
                title: 'All time',
                value: ActivityDetailsUtils.formatHoursMinutes(totalMinutes),
                icon: Icons.all_inclusive,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MiniTile(
                title: 'This week',
                value: ActivityDetailsUtils.formatHoursMinutes(thisWeekMinutes),
                icon: Icons.date_range,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MiniTile(
                title: 'Pace',
                value: ActivityDetailsUtils.pacePerDayLabel(
                  entries: sessions.entries,
                  activityId: activityId,
                ),
                icon: Icons.speed,
              ),
            ),
          ],
        ),

        // (optional small today line; can remove if you want even cleaner)
        const SizedBox(height: 10),
        Text(
          'Today: ${ActivityDetailsUtils.formatHoursMinutes(todayMinutes)}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _MiniTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _MiniTile({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),

          Row(
            children: [
              Icon(icon, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.labelMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
