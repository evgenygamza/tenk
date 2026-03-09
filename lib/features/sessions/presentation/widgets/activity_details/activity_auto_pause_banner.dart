import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tenk/features/timer/presentation/state/timer_controller.dart';
import 'package:tenk/features/sessions/presentation/state/sessions_controller.dart';
import 'package:tenk/features/sessions/presentation/widgets/stop_session_dialog.dart';

class ActivityAutoPauseBanner extends StatelessWidget {
  final String activityId;

  const ActivityAutoPauseBanner({
    super.key,
    required this.activityId,
  });

  @override
  Widget build(BuildContext context) {
    final timer = context.watch<TimerController>();
    if (!timer.isAutoPaused(activityId: activityId)) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Material(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              const Icon(Icons.warning_amber_rounded),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Auto-paused after 24h. Please review the end time.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              TextButton(
                onPressed: () => _review(context),
                child: const Text('Review'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _review(BuildContext context) async {
    final t = context.read<TimerController>();
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

    if (result == null) {
      // Keep it paused; user can review later.
      return;
    }

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
  }
}
