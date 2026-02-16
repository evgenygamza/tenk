import 'package:flutter/material.dart';

class ProgressBar extends StatelessWidget {
  final int totalMinutesAllTime;
  final List<int> thresholdsHours;

  const ProgressBar({
    super.key,
    required this.totalMinutesAllTime,
    this.thresholdsHours = const [10, 100, 1000, 2000, 5000, 10000],
  });

  @override
  Widget build(BuildContext context) {
    final hours = totalMinutesAllTime / 60.0;

    final (from, to) = _rangeFor(hours, thresholdsHours);
    final progress = ((hours - from) / (to - from)).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Progress: ${_fmt(hours)}h / ${_fmt(to)}h',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(value: progress),
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
