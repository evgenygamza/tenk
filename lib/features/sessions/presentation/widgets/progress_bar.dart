import 'package:flutter/material.dart';

class ProgressBar extends StatelessWidget {
  final int totalMinutesAllTime;
  final List<int> thresholdsHours;
  final bool compact;
  final Color? color;

  const ProgressBar({
    super.key,
    required this.totalMinutesAllTime,
    this.thresholdsHours = const [10, 50, 100, 1000, 2000, 5000, 10000],
    this.compact = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final hours = totalMinutesAllTime / 60.0;

    final (from, to) = _rangeFor(hours, thresholdsHours);
    final base = (from / to).clamp(0.0, 1.0); // например 10/100 = 0.1
    final within = ((hours - from) / (to - from)).clamp(0.0, 1.0);
    final progress = (base + within * (1 - base)).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Progress: ${_fmt(hours)}h / ${_fmt(to)}h',
          style: compact
              ? Theme.of(context).textTheme.bodySmall
              : Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: progress,
          color: color,
        ),
        const SizedBox(height: 6),
        Text(
          '${_fmt(from)}h → ${_fmt(to)}h',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  (double, double) _rangeFor(double hours, List<int> thresholds) {
    double prev = 0;

    for (final t in thresholds) {
      final target = t.toDouble();
      if (hours < target) return (prev, target);
      prev = target;
    }

    // If we are above the last threshold, keep growing the target.
    var target = thresholds.isEmpty ? 10.0 : thresholds.last.toDouble();
    while (hours >= target) {
      prev = target;
      target *= 2;
    }
    return (prev, target);
  }

  String _fmt(double value) {
    // Show 1 decimal below 100h, then round.
    if (value < 100) return value.toStringAsFixed(1);
    return value.round().toString();
  }
}
