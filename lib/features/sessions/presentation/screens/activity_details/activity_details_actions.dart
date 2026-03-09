import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tenk/features/activities/presentation/state/activities_controller.dart';
import 'package:tenk/features/sessions/presentation/state/sessions_controller.dart';
import 'package:tenk/ui/activity_palette.dart';

class ActivityDetailsActions {
  static Future<void> rename(BuildContext context, {required String activityId}) async {
    final activities = context.read<ActivitiesController>();
    final idx = activities.activities.indexWhere((a) => a.id == activityId);
    if (idx == -1) return;

    final current = activities.activities[idx];
    final ctrl = TextEditingController(text: current.title);

    final newTitle = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Rename activity'),
          content: TextField(
            controller: ctrl,
            autofocus: true,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(labelText: 'Title'),
            onSubmitted: (_) => Navigator.of(ctx).pop(ctrl.text.trim()),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(null),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(ctrl.text.trim()),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    final t = (newTitle ?? '').trim();
    if (t.isEmpty) return;

    await activities.update(current.copyWith(title: t));
  }

  static Future<void> changeColor(BuildContext context, {required String activityId}) async {
    final activities = context.read<ActivitiesController>();
    final idx = activities.activities.indexWhere((a) => a.id == activityId);
    if (idx == -1) return;

    final current = activities.activities[idx];
    int selected = current.colorIndex;

    final picked = await showDialog<int>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              title: const Text('Change color'),
              content: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: List.generate(activityPalette.length, (i) {
                  final color = activityPalette[i];
                  final isSelected = i == selected;

                  return InkWell(
                    onTap: () => setState(() => selected = i),
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(ctx).colorScheme.onSurface
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, size: 18, color: Colors.white)
                          : null,
                    ),
                  );
                }),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(null),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(ctx).pop(selected),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (picked == null) return;

    await activities.update(current.copyWith(colorIndex: picked));
  }

  static Future<void> delete(BuildContext context, {required String activityId}) async {
    final sessions = context.read<SessionsController>();
    final activities = context.read<ActivitiesController>();
    final nav = Navigator.of(context);

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Delete activity?'),
          content: const Text('This will delete the activity and all its sessions.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (ok != true) return;

    await sessions.resetActivity(activityId);
    await activities.delete(activityId);

    if (context.mounted) {
      nav.pop();
    }
  }
}
