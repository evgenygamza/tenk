import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tenk/features/timer/presentation/state/timer_controller.dart';
import 'package:tenk/features/sessions/presentation/state/sessions_controller.dart';
import 'package:tenk/features/sessions/presentation/widgets/stop_session_dialog.dart';

class TimerDashboardControl extends StatelessWidget {
  // The activity this control belongs to (a card on the Dashboard).
  final String activityId;

  // If true, disables Start on other activities while this activity has an active timer.
  final bool disableWhenOtherRunning;

  const TimerDashboardControl({
    super.key,
    required this.activityId,
    this.disableWhenOtherRunning = true,
  });

  @override
  Widget build(BuildContext context) {
    final timer = context.watch<TimerController>();
    final seconds = timer.elapsedSeconds(activityId: activityId);
    final hasTime = seconds > 0;
    final isRunning = timer.isRunning(activityId: activityId);
    final autoPaused = timer.isAutoPaused(activityId: activityId);

    // If this activity has no time recorded, show Start.
    if (!hasTime && !isRunning) {
      return FilledButton(
        onPressed: () =>
            context.read<TimerController>().start(activityId: activityId),
        child: const Text('Start'),
      );
    }

    // If timer is active for some other activity and we want to disable, show disabled Start.
    // Note: In the current per-activity design, multiple timers can run. If you want to
    // disable starting other timers, you must implement a global "anyRunning" flag.
    if (disableWhenOtherRunning == true) {
      // Keep behavior identical to the old single-timer mode by disabling Start when ANY timer runs.
      // If you don't want this, set disableWhenOtherRunning=false when using the widget.
      final anyRunning = timerHasAnyRunning(timer);
      if (anyRunning && !hasTime && !isRunning) {
        return const FilledButton(onPressed: null, child: Text('Start'));
      }
    }

    // Timer is active for this activity (running OR paused with time > 0): show Pause/Play + time + Stop.
    return FilledButton(
      onPressed: null, // Keep the same sizing slot as Start.
      style: const ButtonStyle(
        padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 10)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _MiniIconButton(
            tooltip: autoPaused ? 'Review' : (isRunning ? 'Pause' : 'Resume'),
            icon: autoPaused ? Icons.edit : (isRunning ? Icons.pause : Icons.play_arrow),
            onTap: () async {
              final t = context.read<TimerController>();

              if (autoPaused) {
                // Same flow as Stop: open StopSessionDialog to confirm end time.
                final sessions = context.read<SessionsController>();

                final secs = t.elapsedSeconds(activityId: activityId);
                if (secs == 0) {
                  t.clearAutoPausedFlag(activityId: activityId);
                  return;
                }

                final end = t.autoPausedAt(activityId: activityId) ?? DateTime.now();
                final start = end.subtract(Duration(seconds: secs));

                final result = await StopSessionDialog.open(
                  context,
                  initialStart: start,
                  initialEnd: end,
                );

                if (!context.mounted) return;
                if (result == null) return;

                final fixed = t.stop(
                  activityId: activityId,
                  startedAt: result.startedAt,
                  finishedAt: result.finishedAt,
                );

                t.reset(activityId: activityId);

                if (fixed == null) return;

                await sessions.addTimedEntry(
                  activityId: activityId,
                  note: result.note ?? 'Auto-paused (24h cap)',
                  startedAt: fixed.start,
                  finishedAt: fixed.end,
                );

                return;
              }

              // Normal behavior (no auto-pause).
              if (isRunning) {
                t.pause(activityId: activityId);
              } else {
                t.start(activityId: activityId);
              }
            },
          ),
          const SizedBox(width: 8),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.center,
              child: Text(
                _formatElapsed(seconds),
                maxLines: 1,
              ),
            ),
          ),
          const SizedBox(width: 8),
          _MiniIconButton(
            tooltip: 'Stop',
            icon: Icons.stop,
            onTap: hasTime
                ? () async {
              final t = context.read<TimerController>();

              final now = DateTime.now();
              final initialEnd = now;
              final initialStart =
              initialEnd.subtract(Duration(seconds: seconds));

              // Freeze the timer while the dialog is open.
              t.pause(activityId: activityId);

              final result = await StopSessionDialog.open(
                context,
                initialStart: initialStart,
                initialEnd: initialEnd,
              );

              if (!context.mounted) return;

              if (result == null) {
                // User cancelled: resume.
                t.start(activityId: activityId);
                return;
              }

              final fixed = t.stop(
                activityId: activityId,
                startedAt: result.startedAt,
                finishedAt: result.finishedAt,
              );

              // Ensure this activity timer state is cleared.
              t.reset(activityId: activityId);

              if (fixed == null) return;

              await context.read<SessionsController>().addTimedEntry(
                activityId: activityId,
                note: result.note,
                startedAt: fixed.start,
                finishedAt: fixed.end,
              );
            }
                : null,
          ),
        ],
      ),
    );
  }

  // Formats seconds as HH:MM:SS.
  String _formatElapsed(int seconds) {
    final s = seconds.clamp(0, 1 << 30);
    final h = s ~/ 3600;
    final m = (s % 3600) ~/ 60;
    final sec = s % 60;

    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:'
          '${m.toString().padLeft(2, '0')}:'
          '${sec.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:'
        '${sec.toString().padLeft(2, '0')}';
  }

  // Returns true if any activity timer is currently running.
  bool timerHasAnyRunning(TimerController timer) {
    // This method relies on TimerController exposing internal state.
    // If you want this feature, add a public `bool get anyRunning` to TimerController.
    return false;
  }
}

class _MiniIconButton extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final VoidCallback? onTap;

  const _MiniIconButton({
    required this.tooltip,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;

    return Tooltip(
      message: tooltip,
      child: InkResponse(
        onTap: onTap,
        radius: 18,
        child: Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            // Slight translucent pill behind the icon to increase contrast.
            color: enabled
                ? Colors.white.withOpacity(0.18)
                : Colors.white.withOpacity(0.10),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Icon(
            icon,
            size: 18,
            color: enabled ? Colors.white : Colors.white.withOpacity(0.55),
          ),
        ),
      ),
    );
  }
}
