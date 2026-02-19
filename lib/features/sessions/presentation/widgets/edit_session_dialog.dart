import 'dart:math';
import 'package:flutter/material.dart';

import 'package:tenk/features/sessions/domain/models/session_entry.dart';

Future<SessionEntry?> showEditSessionDialog(
  BuildContext context, {
  required SessionEntry entry,
}) async {
  final baseDate = entry.startedAt;
  final endInitial = entry.startedAt.add(Duration(minutes: entry.minutes));

  final startCtrl = TextEditingController(text: _formatTime(baseDate));
  final endCtrl = TextEditingController(text: _formatTime(endInitial));
  final noteCtrl = TextEditingController(text: entry.note ?? '');

  try {
    return await showDialog<SessionEntry?>(
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
                        style: Theme.of(ctx).textTheme.bodySmall,
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
                  onPressed: () => Navigator.of(ctx).pop(null),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
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
                      activityId: entry.activityId,
                      startedAt: start,
                      minutes: max(1, minutes),
                      note: noteCtrl.text.trim().isEmpty
                          ? null
                          : noteCtrl.text.trim(),
                    );

                    Navigator.of(ctx).pop(updated);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  } finally {
    startCtrl.dispose();
    endCtrl.dispose();
    noteCtrl.dispose();
  }
}

// ---- helpers ----
String _formatTime(DateTime dt) {
  final hh = dt.hour.toString().padLeft(2, '0');
  final mm = dt.minute.toString().padLeft(2, '0');
  return '$hh:$mm';
}

String _formatHoursMinutes(int totalMinutes) {
  final h = totalMinutes ~/ 60;
  final m = totalMinutes % 60;
  if (h <= 0) return '${m}m';
  if (m == 0) return '${h}h';
  return '${h}h ${m}m';
}

(int, int)? _parseHHmm(String input) {
  final s = input.trim();
  final m = RegExp(r'^([01]?\d|2[0-3]):([0-5]\d)$').firstMatch(s);
  if (m == null) return null;
  return (int.parse(m.group(1)!), int.parse(m.group(2)!));
}

int? _previewDurationMinutes(DateTime base, String startTxt, String endTxt) {
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
