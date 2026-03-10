import 'package:flutter/material.dart';

class ImportExperienceResult {
  final int minutes;
  final String? note;

  const ImportExperienceResult({
    required this.minutes,
    this.note,
  });
}

class ImportExperienceDialog {
  static Future<ImportExperienceResult?> open(BuildContext context) {
    final hoursCtrl = TextEditingController();
    final minutesCtrl = TextEditingController();
    final noteCtrl = TextEditingController(text: 'Imported experience');

    return showDialog<ImportExperienceResult?>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Import experience'),
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
                  // quick feedback, no fancy validation yet
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Enter a positive time')),
                  );
                  return;
                }

                final note = noteCtrl.text.trim();
                Navigator.of(ctx).pop(
                  ImportExperienceResult(
                    minutes: total,
                    note: note.isEmpty ? null : note,
                  ),
                );
              },
              child: const Text('Import'),
            ),
          ],
        );
      },
    );
  }
}
