import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tenk/features/activities/presentation/state/activities_controller.dart';
import 'package:tenk/features/sessions/presentation/state/sessions_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const _SectionTitle('Data'),

            const SizedBox(height: 8),

            ListTile(
              title: const Text('Reset all sessions'),
              subtitle: const Text(
                'Deletes all tracked time (keeps activities).',
              ),
              trailing: const Icon(Icons.delete_outline),
              onTap: () => _resetAllSessions(context),
            ),

            const Divider(height: 24),

            ListTile(
              title: const Text('Delete all activities'),
              subtitle: const Text(
                'Deletes activities and all their sessions.',
              ),
              trailing: const Icon(Icons.delete_forever_outlined),
              onTap: () => _deleteAllActivities(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _resetAllSessions(BuildContext context) async {
    final sessions = context.read<SessionsController>();
    final activities = context.read<ActivitiesController>();
    final nav = Navigator.of(context);

    final ok = await _confirm(
      context,
      title: 'Reset all sessions?',
      message: 'This will delete all sessions for all activities.',
      confirmText: 'Reset',
    );
    if (ok != true) return;

    await sessions.resetAll();
    await activities.resetAll();
    nav.pop(); // optional: close Settings after action, or remove this line
  }

  Future<void> _deleteAllActivities(BuildContext context) async {
    final sessions = context.read<SessionsController>();
    final activities = context.read<ActivitiesController>();
    final nav = Navigator.of(context);

    final ok = await _confirm(
      context,
      title: 'Delete all activities?',
      message: 'This will delete ALL activities and ALL their sessions.',
      confirmText: 'Delete',
    );
    if (ok != true) return;

    await sessions.resetAll();
    await activities.resetAll();
    nav.pop(); // optional
  }

  Future<bool?> _confirm(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmText,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: Theme.of(context).textTheme.titleSmall);
  }
}
