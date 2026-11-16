import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tenk/app/app_theme.dart';
import 'package:tenk/features/activities/domain/models/activity_goal_progress.dart';
import 'package:tenk/features/activities/domain/models/first_activity.dart';
import 'package:tenk/features/timer/domain/controllers/daily_timer_controller.dart';
import 'package:tenk/features/timer/domain/models/practice_targets.dart';
import 'package:tenk/screens/activities/widgets/activities_timer_button.dart';

/// Only this subtree refreshes once a second; the panorama remains unchanged.
class ActivitiesSessionTimer extends StatefulWidget {
  const ActivitiesSessionTimer({
    super.key,
    required this.activity,
    required this.timerController,
    required this.diameter,
    this.isVisible = true,
  });

  static const estimateKey = Key('activities_goal_eta');
  static const weeklyPracticeKey = Key('activities_weekly_practice');
  static const totalPracticeKey = Key('activities_total_practice');

  final FirstActivity activity;
  final DailyTimerController timerController;
  final double diameter;
  final bool isVisible;

  @override
  State<ActivitiesSessionTimer> createState() => _ActivitiesSessionTimerState();
}

class _ActivitiesSessionTimerState extends State<ActivitiesSessionTimer>
    with WidgetsBindingObserver {
  Timer? _ticker;
  bool _foreground = true;
  bool _reduceTransparency = false;
  static const _accessibility = MethodChannel('tenk/accessibility');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _foreground =
        WidgetsBinding.instance.lifecycleState == null ||
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
    widget.timerController.addListener(_changed);
    _syncTicker();
    _refreshMaterialPreferences();
  }

  @override
  void didUpdateWidget(covariant ActivitiesSessionTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.timerController != widget.timerController) {
      oldWidget.timerController.removeListener(_changed);
      widget.timerController.addListener(_changed);
    }
    _syncTicker();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    _syncTicker();
    if (_foreground && mounted) {
      setState(() {});
      _refreshMaterialPreferences();
    }
  }

  Future<void> _refreshMaterialPreferences() async {
    try {
      final value =
          await _accessibility.invokeMethod<bool>('reduceTransparency') ??
          false;
      if (mounted && value != _reduceTransparency) {
        setState(() => _reduceTransparency = value);
      }
    } on MissingPluginException {
      // Platforms without this system preference retain the standard material.
    } on PlatformException {
      // Keep the last known material preference if the platform is unavailable.
    }
  }

  void _changed() {
    _syncTicker();
    if (mounted) setState(() {});
  }

  void _syncTicker() {
    final shouldTick =
        _foreground &&
        widget.isVisible &&
        widget.timerController.activeActivityId == widget.activity.id;
    if (shouldTick) {
      _ticker ??= Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });
    } else {
      _ticker?.cancel();
      _ticker = null;
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    widget.timerController.removeListener(_changed);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timer = widget.timerController;
    final id = widget.activity.id;
    final weekly = timer.totalForCurrentWeek(id);
    final totalMinutes =
        widget.activity.initialMinutes + timer.totalFor(id).inMinutes;
    final history = timer.practiceHistoryDays(
      id,
      maxDays: ActivityGoalProgress.defaultPaceWindowDays,
    );
    final days = history == 0
        ? ActivityGoalProgress.defaultPaceWindowDays
        : history;
    final goal = ActivityGoalProgress.calculate(
      totalMinutes: totalMinutes,
      recentMinutes: timer.totalForLastDays(id, days: days).inMinutes,
      paceWindowDays: days,
    );
    final completed = goal.estimatedDays == 0;
    final estimate = goal.estimatedDays;
    final compact = widget.diameter < 260;
    final textScale = MediaQuery.textScalerOf(context);
    final largeText = textScale.scale(16) > 22;
    const textStyle = TextStyle(
      color: Colors.white,
      fontSize: 14,
      fontWeight: FontWeight.w600,
      shadows: [
        Shadow(
          color: appTimerTextShadowColor,
          blurRadius: 6,
          offset: Offset(0, 1),
        ),
      ],
    );
    final numberStyle = textStyle.copyWith(
      fontSize: compact ? 30 : 36,
      fontWeight: FontWeight.w700,
      height: 1.1,
    );
    final captionStyle = textStyle.copyWith(
      fontSize: compact ? 18 : 20,
      fontWeight: FontWeight.w500,
      height: 1.2,
    );
    final number = completed
        ? 'Goal reached'
        : '$estimate ${estimate == 1 ? 'day' : 'days'}';
    double measure(String text, TextStyle style) {
      final painter = TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: Directionality.of(context),
        textScaler: textScale,
      )..layout(maxWidth: widget.diameter);
      final height = painter.height;
      painter.dispose();
      return height;
    }

    // Reserve enough room for wrapped accessibility captions in either state.
    final numberHeight = <double>[
      measure('Goal reached', numberStyle),
      measure('9999 days', numberStyle),
      if (estimate != null) measure(number, numberStyle),
    ].reduce((a, b) => a > b ? a : b);
    return Column(
      children: [
        // Reserve the caption even without a usable pace to keep the center fixed.
        SizedBox(
          width: widget.diameter,
          height: numberHeight + measure('to your goal', captionStyle) + 4,
          child: estimate == null
              ? null
              : Column(
                  key: ActivitiesSessionTimer.estimateKey,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      number,
                      textAlign: TextAlign.center,
                      style: numberStyle,
                    ),
                    if (!completed)
                      Text(
                        'to your goal',
                        textAlign: TextAlign.center,
                        style: captionStyle,
                      ),
                  ],
                ),
        ),
        SizedBox(
          height: compact ? appTimerCompactContentGap : appTimerContentGap,
        ),
        ActivitiesTimerButton(
          timerController: timer,
          activityId: id,
          weeklyProgress:
              (weekly.inMilliseconds / weeklyPracticeTarget.inMilliseconds)
                  .clamp(0.0, 1.0)
                  .toDouble(),
          diameter: widget.diameter,
          reduceTransparency: _reduceTransparency,
        ),
        SizedBox(
          height: compact ? appTimerCompactContentGap : appTimerContentGap,
        ),
        if (largeText && timer.activeActivityId == id)
          Text('Today', style: textStyle, textAlign: TextAlign.center),
        Text(
          'This week · ${_formatMinutes(weekly.inMinutes)} / ${_formatMinutes(weeklyPracticeTarget.inMinutes)}',
          key: ActivitiesSessionTimer.weeklyPracticeKey,
          style: textStyle,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          'Total · ${_formatMinutes(totalMinutes)}',
          key: ActivitiesSessionTimer.totalPracticeKey,
          style: textStyle,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _formatMinutes(int minutes) {
    final hours = minutes ~/ 60;
    final remainder = minutes % 60;
    if (hours == 0) return '${remainder}m';
    if (remainder == 0) return '${hours}h';
    return '${hours}h ${remainder}m';
  }
}
