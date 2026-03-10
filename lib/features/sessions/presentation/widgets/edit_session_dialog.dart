import 'dart:math';
import 'package:flutter/material.dart';

import 'package:tenk/features/sessions/domain/models/session_entry.dart';

Future<SessionEntry?> showEditSessionDialog(
    BuildContext context, {
      required SessionEntry entry,
    }) {
  return showDialog<SessionEntry?>(
    context: context,
    builder: (ctx) => _EditSessionDialog(entry: entry),
  );
}

class _EditSessionDialog extends StatefulWidget {
  const _EditSessionDialog({required this.entry});

  final SessionEntry entry;

  @override
  State<_EditSessionDialog> createState() => _EditSessionDialogState();
}

class _EditSessionDialogState extends State<_EditSessionDialog> {
  late final TextEditingController _startCtrl;
  late final TextEditingController _endCtrl;
  late final TextEditingController _noteCtrl;

  String? _error;

  SessionEntry get entry => widget.entry;
  DateTime get baseDate => entry.startedAt;

  @override
  void initState() {
    super.initState();

    final endInitial = entry.startedAt.add(Duration(minutes: entry.minutes));

    _startCtrl = TextEditingController(text: _formatTime(entry.startedAt));
    _endCtrl = TextEditingController(text: _formatTime(endInitial));
    _noteCtrl = TextEditingController(text: entry.note ?? '');
  }

  @override
  void dispose() {
    _startCtrl.dispose();
    _endCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _clearError() {
    if (_error != null) {
      setState(() {
        _error = null;
      });
    }
  }

  void _save() {
    final s = _parseHHmm(_startCtrl.text);
    final e = _parseHHmm(_endCtrl.text);

    if (s == null || e == null) {
      setState(() {
        _error = 'Time format: HH:mm';
      });
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
      setState(() {
        _error = 'End must be after Start';
      });
      return;
    }

    final updated = SessionEntry(
      id: entry.id,
      activityId: entry.activityId,
      startedAt: start,
      minutes: max(1, minutes),
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
    );

    Navigator.of(context).pop(updated);
  }

  @override
  Widget build(BuildContext context) {
    final preview = _previewDurationMinutes(
      baseDate,
      _startCtrl.text,
      _endCtrl.text,
    );

    return AlertDialog(
      title: const Text('Edit session'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _startCtrl,
            decoration: const InputDecoration(
              labelText: 'Start (HH:mm)',
              hintText: '09:30',
            ),
            keyboardType: TextInputType.datetime,
            onChanged: (_) => _clearError(),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _endCtrl,
            decoration: const InputDecoration(
              labelText: 'End (HH:mm)',
              hintText: '10:15',
            ),
            keyboardType: TextInputType.datetime,
            onChanged: (_) => _clearError(),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _noteCtrl,
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
          if (_error != null) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _error!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
    );
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
