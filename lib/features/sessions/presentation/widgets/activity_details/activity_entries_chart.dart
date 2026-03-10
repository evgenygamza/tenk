import 'package:flutter/material.dart';
import 'package:tenk/features/sessions/presentation/screens/activity_details/activity_details_utils.dart';

enum ActivityChartMode { daily, monthly }

class ActivityChartBar {
  final String label; // e.g. "9" or "Mon"
  final int minutes;
  const ActivityChartBar({required this.label, required this.minutes});
}

/// One chart widget that can render Daily (scrollable) and Weekly (7 bars),
/// with an internal toggle.
class ActivityEntriesChart extends StatefulWidget {
  final List<ActivityChartBar> daily;  // typically last N days
  final List<ActivityChartBar> monthly; //
  final ActivityChartMode initialMode;

  const ActivityEntriesChart({
    super.key,
    required this.daily,
    required this.monthly,
    this.initialMode = ActivityChartMode.daily,
  });

  @override
  State<ActivityEntriesChart> createState() => _ActivityEntriesChartState();
}

class _ActivityEntriesChartState extends State<ActivityEntriesChart> {
  late ActivityChartMode _mode = widget.initialMode;

  // Only for daily scroll view
  final ScrollController _dailyController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (_mode == ActivityChartMode.daily) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _jumpDailyToEnd());
    }
  }

  @override
  void didUpdateWidget(covariant ActivityEntriesChart oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If daily data changed and we're in daily mode, keep pinned to the end.
    if (_mode == ActivityChartMode.daily &&
        widget.daily.length != oldWidget.daily.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _jumpDailyToEnd());
    }
  }

  void _jumpDailyToEnd() {
    if (!_dailyController.hasClients) return;
    _dailyController.jumpTo(_dailyController.position.maxScrollExtent);
  }

  @override
  void dispose() {
    _dailyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final bars = _mode == ActivityChartMode.daily ? widget.daily : widget.monthly;

    if (bars.isEmpty) {
      return Text(
        'No entries yet',
        style: Theme.of(context).textTheme.bodyMedium,
      );
    }

    final maxMinutes = bars.fold<int>(0, (m, b) => b.minutes > m ? b.minutes : m);

    // Layout presets
    final chartHeight = 120.0;
    final barWidth = 18.0;
    const barGap = 1.0;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        children: [
          SizedBox(
            height: chartHeight + 26, // bars + labels
            child: _mode == ActivityChartMode.daily
                ? SingleChildScrollView(
              controller: _dailyController,
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (final b in widget.daily) ...[
                      _Bar(
                        minutes: b.minutes,
                        maxMinutes: maxMinutes,
                        width: barWidth,
                        height: chartHeight,
                        label: b.label,
                      ),
                      const SizedBox(width: barGap),
                    ],
                  ],
                ),
              ),
            )
                : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (final b in widget.monthly)
                    _Bar(
                      minutes: b.minutes,
                      maxMinutes: maxMinutes,
                      width: barWidth,
                      height: chartHeight,
                      label: b.label,
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 6),

          // Toggle inside block (bottom, small)
          _ModeToggle(
            mode: _mode,
            onChanged: (m) {
              setState(() => _mode = m);
              if (m == ActivityChartMode.daily) {
                WidgetsBinding.instance.addPostFrameCallback((_) => _jumpDailyToEnd());
              }
            },
          ),
        ],
      ),
    );
  }
}

class _ModeToggle extends StatelessWidget {
  final ActivityChartMode mode;
  final ValueChanged<ActivityChartMode> onChanged;

  const _ModeToggle({required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Widget item(ActivityChartMode value, String text) {
      final selected = mode == value;
      return InkWell(
        onTap: () => onChanged(value),
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Text(
            text,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: selected ? cs.primary : cs.onSurfaceVariant,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        item(ActivityChartMode.daily, 'Daily'),
        Text(' · ', style: Theme.of(context).textTheme.labelLarge),
        item(ActivityChartMode.monthly, 'Monthly'),
      ],
    );
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

    // Heat intensity (0..1)
    final t = maxMinutes <= 0 ? 0.0 : (minutes / maxMinutes).clamp(0.0, 1.0);
    final barH = (height * t).clamp(2.0, height);

    // Make spacing stable: fixed "cell" width per bar (bar + label)
    // Also make bars thicker.
    final barW = width + 8;        // thicker bar
    final cellW = barW + 8;       // fixed cell width so labels don't affect spacing

    // Heatmap-like color buckets
    Color barColor() {
      if (minutes <= 0) return cs.outlineVariant;
      if (t < 0.25) return cs.primary.withValues(alpha: 0.35);
      if (t < 0.55) return cs.primary.withValues(alpha: 0.55);
      if (t < 0.85) return cs.primary.withValues(alpha: 0.75);
      return cs.primary;
    }

    return SizedBox(
      width: cellW,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Tooltip(
            message: ActivityDetailsUtils.formatHoursMinutes(minutes),
            child: Container(
              width: barW,
              height: barH,
              decoration: BoxDecoration(
                color: barColor(),
                borderRadius: BorderRadius.zero, // no rounding
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: cellW,
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
        ],
      ),
    );
  }
}
