import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tenk/features/sessions/presentation/screens/add_manual_screen.dart';
import 'package:tenk/features/sessions/presentation/state/sessions_controller.dart';
import 'package:tenk/features/sessions/presentation/widgets/session_list.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<SessionsController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('TenK'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today: ${_formatHoursMinutes(c.totalMinutesToday)}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'All time: ${_formatHoursMinutes(c.totalMinutesAllTime)}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'Timer: ${_formatElapsed(c.elapsedSeconds)}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: c.isRunning ? null : () => c.startTimer(),
                    child: const Text('Start'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    onPressed: c.isRunning ? () => c.pauseTimer() : null,
                    child: const Text('Pause'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    onPressed: c.elapsedSeconds == 0
                        ? null
                        : () async {
                      context.read<SessionsController>().pauseTimer();
                      await _openStopDialog(context);
                    },
                    child: const Text('Stop'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const AddManualScreen(),
                    ),
                  );
                },
                child: const Text('Add manually'),
              ),
            ),
            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  context.read<SessionsController>().addManual(15);
                },
                child: const Text('+15 min'),
              ),
            ),
            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  context.read<SessionsController>().resetAll();
                },
                child: const Text('Reset'),
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: SessionList(entries: c.entries),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openStopDialog(BuildContext context) async {
    final c = context.read<SessionsController>();

    final now = DateTime.now();
    final endInit = now;
    final startInit = endInit.subtract(Duration(seconds: c.elapsedSeconds));

    TimeOfDay startT = TimeOfDay.fromDateTime(startInit);
    TimeOfDay endT = TimeOfDay.fromDateTime(endInit);

    final noteController = TextEditingController();

    Future<TimeOfDay?> pickTime(TimeOfDay initial) {
      return showTimePicker(
        context: context,
        initialTime: initial,
      );
    }

    DateTime combineToday(TimeOfDay t) =>
        DateTime(now.year, now.month, now.day, t.hour, t.minute);

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            var start = combineToday(startT);
            var end = combineToday(endT);

            // If end is earlier than start, assume it crosses midnight
            if (!end.isAfter(start)) {
              end = end.add(const Duration(days: 1));
            }

            final durationMinutes = end.difference(start).inMinutes;
            final invalid = durationMinutes <= 0;

            return AlertDialog(
              title: const Text('Add details'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _TimeRow(
                    label: 'Start time',
                    value: _formatTimeOfDay(startT),
                    onTap: () async {
                      final picked = await pickTime(startT);
                      if (picked == null) return;
                      setState(() => startT = picked);
                    },
                  ),
                  const SizedBox(height: 12),
                  _TimeRow(
                    label: 'End time',
                    value: _formatTimeOfDay(endT),
                    onTap: () async {
                      final picked = await pickTime(endT);
                      if (picked == null) return;
                      setState(() => endT = picked);
                    },
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Duration: ${_formatHoursMinutes(durationMinutes)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: noteController,
                    decoration: const InputDecoration(
                      labelText: 'Note (optional)',
                      hintText: 'Add a note…',
                    ),
                    minLines: 1,
                    maxLines: 3,
                  ),
                ],
              ),
              actions: [
                FilledButton(
                  onPressed: invalid
                      ? null
                      : () async {
                    final note = noteController.text.trim();
                    await c.stopAndSave(
                      note: note.isEmpty ? null : note,
                      startedAt: start,
                      finishedAt: end,
                    );
                    if (ctx.mounted) Navigator.of(ctx).pop();
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  static String _formatElapsed(int seconds) {
    final mm = (seconds ~/ 60).toString().padLeft(2, '0');
    final ss = (seconds % 60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  static String _formatHoursMinutes(int totalMinutes) {
    final h = totalMinutes ~/ 60;
    final m = totalMinutes % 60;
    if (h <= 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }

  static String _formatTimeOfDay(TimeOfDay t) {
    final hh = t.hour.toString().padLeft(2, '0');
    final mm = t.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }
}

class _TimeRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _TimeRow({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        child: Text(value),
      ),
    );
  }
}
