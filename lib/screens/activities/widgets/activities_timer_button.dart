import 'package:flutter/material.dart';
import 'package:tenk/app/app_theme.dart';
import 'package:tenk/features/timer/domain/controllers/daily_timer_controller.dart';
import 'package:tenk/ui/widgets/session_timer_widget.dart';

/// Connects the visual control to the shared timer and persistence errors.
class ActivitiesTimerButton extends StatelessWidget {
  const ActivitiesTimerButton({
    super.key,
    required this.timerController,
    required this.activityId,
    this.weeklyProgress = 0,
    this.diameter = appTimerRunningDiameter,
    this.reduceTransparency = false,
  });

  static const toggleButtonKey = Key('activities_start_session');

  final DailyTimerController timerController;
  final String activityId;
  final double weeklyProgress;
  final double diameter;
  final bool reduceTransparency;

  @override
  Widget build(BuildContext context) {
    final otherActivity =
        timerController.activeActivityId != null &&
        timerController.activeActivityId != activityId;
    final running =
        !otherActivity && timerController.status == DailyTimerStatus.running;
    final actionLabel = otherActivity
        ? 'Timer is active for another activity'
        : running
        ? 'Stop timer'
        : 'Start timer';
    return SessionTimerWidget(
      running: running,
      dailyElapsed: timerController.totalForToday(activityId),
      weeklyProgress: weeklyProgress,
      actionLabel: actionLabel,
      buttonKey: toggleButtonKey,
      diameter: diameter,
      reduceTransparency: reduceTransparency,
      onPressed: otherActivity || timerController.isSaving
          ? null
          : () => _toggle(context, running),
    );
  }

  Future<void> _toggle(BuildContext context, bool running) async {
    try {
      if (running) {
        await timerController.stop();
      } else {
        await timerController.start(activityId);
      }
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            running
                ? 'Could not save practice. Timer is still running. Try Stop again.'
                : 'Could not start timer. Please try again.',
          ),
        ),
      );
    }
  }
}
