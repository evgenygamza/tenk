import 'package:flutter/material.dart';

class AddManualResult {
  final int minutes;
  final String? note;

  const AddManualResult({
    required this.minutes,
    this.note,
  });
}

class AddManualDialog {
  static Future<AddManualResult?> open(BuildContext context) {
    final hoursCtrl = TextEditingController();
    final minutesCtrl = TextEditingController();
    final noteCtrl = TextEditingController();

    return showDialog<AddManualResult?>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Add manual entry'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: hoursCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Hours'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: minutesCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Minutes'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: noteCtrl,
                decoration: const InputDecoration(labelText: 'Note (optional)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(null),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final h = int.tryParse(hoursCtrl.text.trim()) ?? 0;
                final m = int.tryParse(minutesCtrl.text.trim()) ?? 0;
                final total = h * 60 + m;

                if (total <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Enter a positive time')),
                  );
                  return;
                }

                final note = noteCtrl.text.trim();
                Navigator.of(ctx).pop(
                  AddManualResult(
                    minutes: total,
                    note: note.isEmpty ? null : note,
                  ),
                );
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
