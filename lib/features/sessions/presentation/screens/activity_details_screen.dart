import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tenk/features/sessions/domain/models/session_entry.dart';
import 'package:tenk/features/sessions/presentation/screens/add_manual_screen.dart';
import 'package:tenk/features/sessions/presentation/state/sessions_controller.dart';
import 'package:tenk/features/sessions/presentation/widgets/progress_bar.dart';
import 'package:tenk/features/sessions/presentation/widgets/session_list.dart';

class ActivityDetailsScreen extends StatelessWidget {
  const ActivityDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<SessionsController>();

    return Scaffold(
      appBar: AppBar(title: const Text('TenK')),
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

            ProgressBar(totalMinutesAllTime: c.totalMinutesAllTime),
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
              child: SessionList(
                entries: c.entries,
                onDelete: (id) =>
                    context.read<SessionsController>().deleteEntry(id),
                onEdit: (entry) => _openEditDialog(context, entry),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- STOP DIALOG (time picker version stays for MVP) ----------
  Future<void> _openStopDialog(BuildContext context) async {
    final c = context.read<SessionsController>();

    final now = DateTime.now();
    final endInit = now;
    final startInit = endInit.subtract(Duration(seconds: c.elapsedSeconds));

    TimeOfDay startT = TimeOfDay.fromDateTime(startInit);
    TimeOfDay endT = TimeOfDay.fromDateTime(endInit);

    final noteController = TextEditingController();

    Future<TimeOfDay?> pickTime(TimeOfDay initial) {
      return showTimePicker(context: context, initialTime: initial);
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

            if (end.isAtSameMomentAs(start)) {
              end = end.add(const Duration(minutes: 1));
            } else if (end.isBefore(start)) {
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

  // ---------- EDIT DIALOG (plain HH:mm input) ----------
  Future<void> _openEditDialog(BuildContext context, SessionEntry entry) async {
    final baseDate = entry.startedAt;
    final endInitial = entry.startedAt.add(Duration(minutes: entry.minutes));

    final startCtrl = TextEditingController(text: _formatTime(baseDate));
    final endCtrl = TextEditingController(text: _formatTime(endInitial));
    final noteCtrl = TextEditingController(text: entry.note ?? '');

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            String? error;
            final preview = _previewDurationMinutes(
              baseDate,
              startCtrl.text,
              endCtrl.text,
            );

            return AlertDialog(
              title: const Text('Edit session'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: startCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Start (HH:mm)',
                      hintText: '09:30',
                    ),
                    keyboardType: TextInputType.datetime,
                    onChanged: (_) => setState(() => error = null),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: endCtrl,
                    decoration: const InputDecoration(
                      labelText: 'End (HH:mm)',
                      hintText: '10:15',
                    ),
                    keyboardType: TextInputType.datetime,
                    onChanged: (_) => setState(() => error = null),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: noteCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Note (optional)',
                    ),
                    minLines: 1,
                    maxLines: 3,
                  ),
                  if (preview != null) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Duration: ${_formatHoursMinutes(preview)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                  if (error != null) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () async {
                    final s = _parseHHmm(startCtrl.text);
                    final e = _parseHHmm(endCtrl.text);
                    if (s == null || e == null) {
                      setState(() => error = 'Time format: HH:mm');
                      return;
                    }

                    final start = DateTime(
                      baseDate.year,
                      baseDate.month,
                      baseDate.day,
                      s.$1,
                      s.$2,
                    );
                    var end = DateTime(
                      baseDate.year,
                      baseDate.month,
                      baseDate.day,
                      e.$1,
                      e.$2,
                    );
                    if (!end.isAfter(start)) {
                      end = end.add(const Duration(days: 1));
                    }

                    final minutes = end.difference(start).inMinutes;
                    if (minutes <= 0) {
                      setState(() => error = 'End must be after Start');
                      return;
                    }

                    final updated = SessionEntry(
                      id: entry.id,
                      startedAt: start,
                      minutes: max(1, minutes),
                      note: noteCtrl.text.trim().isEmpty
                          ? null
                          : noteCtrl.text.trim(),
                    );

                    await context
                        .read<SessionsController>()
                        .updateEntry(updated);

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

  // ---------- helpers ----------
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

  static String _formatTime(DateTime dt) {
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  static (int, int)? _parseHHmm(String input) {
    final s = input.trim();
    final m = RegExp(r'^([01]?\d|2[0-3]):([0-5]\d)$').firstMatch(s);
    if (m == null) return null;
    return (int.parse(m.group(1)!), int.parse(m.group(2)!));
  }

  static int? _previewDurationMinutes(
      DateTime base,
      String startTxt,
      String endTxt,
      ) {
    final s = _parseHHmm(startTxt);
    final e = _parseHHmm(endTxt);
    if (s == null || e == null) return null;

    final start = DateTime(base.year, base.month, base.day, s.$1, s.$2);
    var end = DateTime(base.year, base.month, base.day, e.$1, e.$2);
    if (!end.isAfter(start)) end = end.add(const Duration(days: 1));

    final mins = end.difference(start).inMinutes;
    if (mins <= 0) return null;
    return mins;
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
