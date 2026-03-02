import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tenk/features/timer/presentation/state/timer_controller.dart';
import 'package:tenk/features/sessions/presentation/state/sessions_controller.dart';
import 'package:tenk/features/sessions/presentation/widgets/stop_session_dialog.dart';

class TimerDashboardControl extends StatelessWidget {
  // The activity this control belongs to (a card on the Dashboard).
  final String activityId;

  // If true, hides Start on other activities while a timer is running elsewhere.
  final bool disableWhenOtherRunning;

  const TimerDashboardControl({
    super.key,
    required this.activityId,
    this.disableWhenOtherRunning = true,
  });

  @override
  Widget build(BuildContext context) {
    final timer = context.watch<TimerController>();

    final hasTime = timer.elapsedSeconds > 0;
    final isMine = timer.activeActivityId == activityId;

    // "Active" means: this activity owns the timer state (running or paused).
    final isActiveForThisActivity = isMine && hasTime;

    // 1) No active timer at all -> show Start.
    if (!hasTime && !timer.isRunning) {
      return FilledButton(
        onPressed: () => context.read<TimerController>().start(activityId: activityId),
        child: const Text('Start'),
      );
    }

    // 2) Timer is active for a different activity -> disable Start (or switch later).
    if (!isActiveForThisActivity) {
      return FilledButton(
        onPressed: disableWhenOtherRunning ? null : () => context.read<TimerController>().start(activityId: activityId),
        child: const Text('Start'),
      );
    }

    // When timer is running for this activity: show Pause | Time | Stop in the same space as Start.
    return FilledButton(
      onPressed: null, // Keep the same sizing slot as Start.
      style: const ButtonStyle(
        padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 10)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _MiniIconButton(
            tooltip: timer.isRunning ? 'Pause' : 'Resume',
            icon: timer.isRunning ? Icons.pause : Icons.play_arrow,
            onTap: () {
              final t = context.read<TimerController>();
              if (t.isRunning) {
                t.pause();
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
                _formatElapsed(timer.elapsedSeconds),
                maxLines: 1,
              ),
            ),
          ),
          const SizedBox(width: 8),
          _MiniIconButton(
            tooltip: 'Stop',
            icon: Icons.stop,
            onTap: timer.elapsedSeconds > 0
                ? () async {
              final t = context.read<TimerController>();

              final now = DateTime.now();
              final initialEnd = now;
              final initialStart =
              initialEnd.subtract(Duration(seconds: t.elapsedSeconds));

              // Freeze while the dialog is open.
              t.pause();

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
                startedAt: result.startedAt,
                finishedAt: result.finishedAt,
              );

              t.reset();

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
}

// timer_dashboard_control.dart
// Add this helper widget at the bottom of the file.

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
        child: Opacity(
          opacity: enabled ? 1 : 0.45,
          child: Icon(icon, size: 18),
        ),
      ),
    );
  }
}
