import 'package:flutter/material.dart';
import 'package:tenk/app/app_theme.dart';
import 'package:tenk/features/timer/domain/controllers/daily_timer_controller.dart';

class ActivitiesTimerButton extends StatelessWidget {
  const ActivitiesTimerButton({
    super.key,
    required this.timerController,
    required this.activityId,
  });

  static const toggleButtonKey = Key('activities_start_session');

  final DailyTimerController timerController;
  final String activityId;

  @override
  Widget build(BuildContext context) {
    final status = timerController.status;
    final isForActiveActivity =
        timerController.activeActivityId == null ||
        timerController.activeActivityId == activityId;
    final actionLabel = !isForActiveActivity
        ? 'Timer is active for another activity'
        : switch (status) {
            DailyTimerStatus.idle => 'Start timer',
            DailyTimerStatus.running => 'Pause timer',
            DailyTimerStatus.paused => 'Resume timer',
          };
    final icon = switch (status) {
      DailyTimerStatus.idle => Icons.play_arrow_rounded,
      DailyTimerStatus.running => Icons.pause_rounded,
      DailyTimerStatus.paused => Icons.play_arrow_rounded,
    };

    return Tooltip(
      message: actionLabel,
      child: Semantics(
        label: actionLabel,
        button: true,
        enabled: isForActiveActivity,
        child: SizedBox(
          width: 112,
          height: 112,
          child: FilledButton(
            key: ActivitiesTimerButton.toggleButtonKey,
            onPressed: isForActiveActivity
                ? () {
                    switch (status) {
                      case DailyTimerStatus.idle:
                        timerController.start(activityId);
                        break;
                      case DailyTimerStatus.running:
                        timerController.pause();
                        break;
                      case DailyTimerStatus.paused:
                        timerController.resume();
                        break;
                    }
                  }
                : null,
            style: FilledButton.styleFrom(
              backgroundColor: appMossColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.zero,
              shape: const CircleBorder(),
              elevation: 8,
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: Icon(icon, key: ValueKey(status), size: 52),
            ),
          ),
        ),
      ),
    );
  }
}
