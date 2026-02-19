import 'package:flutter/material.dart';
import 'package:tenk/features/sessions/domain/models/session_entry.dart';

Future<bool> confirmDeleteSessionDialog(
  BuildContext context, {
  required SessionEntry entry,
}) async {
  final dialogContext = context;

  final ok = await showDialog<bool>(
    context: dialogContext,
    builder: (dctx) => AlertDialog(
      title: const Text('Delete session?'),
      content: Text('Delete ${entry.minutes} min entry?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dctx).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dctx).pop(true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );

  return ok ?? false;
}
