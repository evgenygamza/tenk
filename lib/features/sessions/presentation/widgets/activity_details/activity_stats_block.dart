import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tenk/features/sessions/presentation/state/sessions_controller.dart';
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

    // TODO (later): real ETA from pace. For now: mock based on some simple heuristic.
    final etaDays = _mockEtaDays(totalMinutes);

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
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${etaDays}d',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                'to goal',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 72, top: 6),
                  child: ProgressBar(
                    totalMinutesAllTime: totalMinutes,
                    color: accent,
                  ),
                ),
                // Positioned(
                //   right: 0,
                //   top: 0,
                //   child: TextButton(
                //     onPressed: onMoreStats,
                //     child: const Text('More'),
                //   ),
                // ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 6),
        const SizedBox(height: 12),

        // Tiles row
        Row(
          children: [
            Expanded(
              child: _MiniTile(
                title: 'All time',
                value: _formatHoursMinutes(totalMinutes),
                icon: Icons.all_inclusive,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MiniTile(
                title: 'This week',
                value: _mockThisWeek(totalMinutes),
                icon: Icons.date_range,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MiniTile(
                title: 'Pace',
                value: _mockPace(),
                icon: Icons.speed,
              ),
            ),
          ],
        ),

        // (optional small today line; can remove if you want even cleaner)
        const SizedBox(height: 10),
        Text(
          'Today: ${_formatHoursMinutes(todayMinutes)}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  // ---------- mocks / helpers (we’ll replace with real stats later) ----------

  static int _mockEtaDays(int totalMinutes) {
    // super rough: as you progress, ETA decreases
    if (totalMinutes <= 60) return 30;
    if (totalMinutes <= 5 * 60) return 21;
    if (totalMinutes <= 10 * 60) return 14;
    if (totalMinutes <= 20 * 60) return 12;
    return 9;
  }

  static String _mockThisWeek(int totalMinutes) {
    // placeholder until we aggregate per-week
    final h = (totalMinutes ~/ 60).clamp(0, 12);
    return '${h}h';
  }

  static String _mockPace() => '32m/d';

  static String _formatHoursMinutes(int totalMinutes) {
    final h = totalMinutes ~/ 60;
    final m = totalMinutes % 60;
    if (h <= 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
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
