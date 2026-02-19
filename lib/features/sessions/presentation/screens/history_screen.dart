import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tenk/features/activities/presentation/state/activities_controller.dart';
import 'package:tenk/features/sessions/presentation/state/sessions_controller.dart';
import 'package:tenk/features/sessions/presentation/widgets/session_list.dart';
import 'package:tenk/features/sessions/presentation/widgets/edit_session_dialog.dart';
import 'package:tenk/features/sessions/presentation/widgets/confirm_delete_session_dialog.dart';
import 'package:tenk/features/sessions/presentation/widgets/nav_bar.dart';

import 'activity_details_screen.dart';
import 'dashboard_screen.dart'; // activityPalette

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sessions = context.watch<SessionsController>();
    final activitiesC = context.watch<ActivitiesController>();

    final byId = {
      for (final a in activitiesC.activities) a.id: a,
    };

    final items = [...sessions.entries]
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));

    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SessionList(
                entries: items,
                onDelete: (id) => context.read<SessionsController>().deleteEntry(id),
                confirmDelete: (ctx, e) => confirmDeleteSessionDialog(ctx, entry: e),
                onEdit: (entry) async {
                  final sessions = context.read<SessionsController>();
                  final dialogContext = context;
                  final updated = await showEditSessionDialog(dialogContext, entry: entry);
                  if (updated == null) return;
                  await sessions.updateEntry(updated);
                },
                leadingBuilder: (ctx, e) {
                  final act = byId[e.activityId];
                  final title = act?.title ?? e.activityId;
                  final color = act == null
                      ? Theme.of(ctx).colorScheme.primary
                      : activityPalette[act.colorIndex % activityPalette.length];

                  return InkWell(
                    borderRadius: BorderRadius.circular(999),
                    onTap: () {
                      if (act == null) return;

                      Navigator.of(ctx).push(
                        MaterialPageRoute<void>(
                          builder: (_) => ActivityDetailsScreen(
                            activityId: act.id,
                            autoStart: false,
                          ),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 8),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 90),
                          child: Text(
                            title,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(ctx).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: NavBar(
              selectedIndex: 1,
              onDestinationSelected: (i) {
                if (i == 0) {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const DashboardScreen()),
                  );
                  return;
                }
                // TODO: Settings позже
                debugPrint('Tab $i');
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.grid_view_rounded),
                  label: 'Home',
                ),
                NavigationDestination(icon: Icon(Icons.history), label: 'History'),
                NavigationDestination(
                  icon: Icon(Icons.tune_rounded),
                  label: 'Settings',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
