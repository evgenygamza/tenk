import 'package:flutter/material.dart';
import 'package:tenk/features/sessions/presentation/screens/activity_details/activity_details_utils.dart';

class ProgressBar extends StatelessWidget {
  final int totalMinutesAllTime;
  final bool compact;
  final Color? color;

  const ProgressBar({
    super.key,
    required this.totalMinutesAllTime,
    this.compact = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final total = totalMinutesAllTime;
    final goalMinutes = ActivityDetailsUtils.currentGoalMinutes(total);
    final prevMinutes = ActivityDetailsUtils.previousGoalMinutes(total);

    final denom = goalMinutes - prevMinutes;
    final progress = denom <= 0
        ? 0.0
        : ((total - prevMinutes) / denom).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Progress: ${_fmt(total)} / ${_fmt(goalMinutes)}',
          style: compact
              ? Theme.of(context).textTheme.bodySmall
              : Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(value: progress, color: color),
        const SizedBox(height: 6),
        Text(
          '${_fmt(prevMinutes)} → ${_fmt(goalMinutes)}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  String _fmt(int minutes) {
    final h = minutes / 60.0;
    if (h < 100) return '${h.toStringAsFixed(1)}h';
    return '${h.round()}h';
  }
}
