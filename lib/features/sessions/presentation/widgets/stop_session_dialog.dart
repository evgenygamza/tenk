import 'package:flutter/material.dart';

class StopSessionResult {
  final DateTime startedAt;
  final DateTime finishedAt;
  final String? note;

  const StopSessionResult({
    required this.startedAt,
    required this.finishedAt,
    this.note,
  });
}

class StopSessionDialog extends StatefulWidget {
  final DateTime initialStart;
  final DateTime initialEnd;

  const StopSessionDialog({
    super.key,
    required this.initialStart,
    required this.initialEnd,
  });

  /// Convenience helper: returns null if cancelled.
  static Future<StopSessionResult?> open(
    BuildContext context, {
    required DateTime initialStart,
    required DateTime initialEnd,
  }) {
    return showDialog<StopSessionResult>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) =>
          StopSessionDialog(initialStart: initialStart, initialEnd: initialEnd),
    );
  }

  @override
  State<StopSessionDialog> createState() => _StopSessionDialogState();
}

class _StopSessionDialogState extends State<StopSessionDialog> {
  late TimeOfDay _startT;
  late TimeOfDay _endT;

  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _startT = TimeOfDay.fromDateTime(widget.initialStart);
    _endT = TimeOfDay.fromDateTime(widget.initialEnd);
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<TimeOfDay?> _pick(TimeOfDay initial) {
    return showTimePicker(context: context, initialTime: initial);
  }

  DateTime _combineToday(DateTime baseDay, TimeOfDay t) {
    return DateTime(baseDay.year, baseDay.month, baseDay.day, t.hour, t.minute);
  }

  static String _hhmm(TimeOfDay t) {
    final hh = t.hour.toString().padLeft(2, '0');
    final mm = t.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  static String _formatHoursMinutes(int totalMinutes) {
    final h = totalMinutes ~/ 60;
    final m = totalMinutes % 60;
    if (h <= 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    var start = _combineToday(now, _startT);
    var end = _combineToday(now, _endT);

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
            value: _hhmm(_startT),
            onTap: () async {
              final picked = await _pick(_startT);
              if (!mounted || picked == null) return;
              setState(() => _startT = picked);
            },
          ),
          const SizedBox(height: 12),
          _TimeRow(
            label: 'End time',
            value: _hhmm(_endT),
            onTap: () async {
              final picked = await _pick(_endT);
              if (!mounted || picked == null) return;
              setState(() => _endT = picked);
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
            controller: _noteController,
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
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: invalid
              ? null
              : () {
                  final note = _noteController.text.trim();
                  Navigator.of(context).pop(
                    StopSessionResult(
                      startedAt: start,
                      finishedAt: end,
                      note: note.isEmpty ? null : note,
                    ),
                  );
                },
          child: const Text('Save'),
        ),
      ],
    );
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
