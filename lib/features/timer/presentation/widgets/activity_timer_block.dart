import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tenk/features/timer/presentation/state/timer_controller.dart';
import 'package:tenk/features/sessions/presentation/state/sessions_controller.dart';
import 'package:tenk/features/sessions/presentation/widgets/stop_session_dialog.dart';
import 'package:tenk/ui/ui_tokens.dart';

class ActivityTimerBlock extends StatelessWidget {
  final String activityId;
  final Color accent;

  const ActivityTimerBlock({
    super.key,
    required this.activityId,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final timer = context.watch<TimerController>();
    final seconds = timer.elapsedSeconds(activityId: activityId);
    final isRunning = timer.isRunning(activityId: activityId);
    final isPaused = !isRunning && seconds > 0;
    final isIdle = !isRunning && seconds == 0;
    final hint = isRunning
        ? 'Running…'
        : isPaused
        ? 'Paused'
        : 'Tap Start to begin a session';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Timer', style: sectionTitleStyle(context)),
        const SizedBox(height: 6),
        Text(
          'Track time for this activity',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 12),

        Center(
          child: Text(
            _formatElapsed(seconds),
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            hint,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        const SizedBox(height: 12),

        // Controls
        if (isIdle) ...[
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => context.read<TimerController>().start(activityId: activityId),
              child: const Text('Start'),
            ),
          ),
        ] else if (isRunning) ...[
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: () => context.read<TimerController>().pause(activityId: activityId),
                  child: const Text('Pause'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: () => _stopFlow(context),
                  child: const Text('Stop'),
                ),
              ),
            ],
          ),
        ] else if (isPaused) ...[
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: () => context.read<TimerController>().start(activityId: activityId),
                  child: const Text('Resume'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: () => _stopFlow(context),
                  child: const Text('Stop'),
                ),
              ),
            ],
          ),
        ]
      ],
    );
  }

  Future<void> _stopFlow(BuildContext context) async {
    final timer = context.read<TimerController>();
    final sessions = context.read<SessionsController>();

    final seconds = timer.elapsedSeconds(activityId: activityId);
    if (seconds == 0) return;

    // Freeze while dialog is open.
    timer.pause(activityId: activityId);

    final now = DateTime.now();
    final initialEnd = now;
    final initialStart = initialEnd.subtract(Duration(seconds: seconds));

    final result = await StopSessionDialog.open(
      context,
      initialStart: initialStart,
      initialEnd: initialEnd,
    );

    if (!context.mounted) return;

    if (result == null) {
      // User cancelled: resume timer.
      timer.start(activityId: activityId);
      return;
    }

    final fixed = timer.stop(
      activityId: activityId,
      startedAt: result.startedAt,
      finishedAt: result.finishedAt,
    );

    timer.reset(activityId: activityId);

    if (fixed == null) return;

    await sessions.addTimedEntry(
      activityId: activityId,
      note: result.note,
      startedAt: fixed.start,
      finishedAt: fixed.end,
    );
  }

  static String _formatElapsed(int seconds) {
    final mm = (seconds ~/ 60).toString().padLeft(2, '0');
    final ss = (seconds % 60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }
}
