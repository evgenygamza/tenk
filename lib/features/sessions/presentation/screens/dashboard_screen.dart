import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tenk/features/activities/domain/models/activity.dart';
import 'package:tenk/features/activities/presentation/state/activities_controller.dart';
import 'package:tenk/features/sessions/presentation/screens/activity_details_screen.dart';
import 'package:tenk/features/sessions/presentation/screens/history_screen.dart';
import 'package:tenk/features/sessions/presentation/state/sessions_controller.dart';
import 'package:tenk/features/sessions/presentation/widgets/nav_bar.dart';
import 'package:tenk/features/sessions/presentation/widgets/progress_bar.dart';
import 'package:tenk/ui/ui_tokens.dart';

const activityPalette = [
  Color(0xFF22C55E), // green
  Color(0xFF06B6D4), // cyan
  Color(0xFFF97316), // orange
  Color(0xFFA855F7), // purple
  Color(0xFFEC4899), // pink
];

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<SessionsController>();
    final a = context.watch<ActivitiesController>();
    final activities = a.activities;

    final navInset =
        (UiTokens.navHeight * 0.55) +
            UiTokens.navPadding.bottom +
            MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Activities'),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: открыть Settings
              debugPrint('Settings tapped');
            },
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                padding: EdgeInsets.only(bottom: navInset),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.92,
                ),
                itemCount: activities.length + 1, // +add card
                itemBuilder: (context, index) {
                  if (index == activities.length) {
                    return _AddActivityCard(
                      onTap: () => _openAddActivityDialog(context),
                    );
                  }

                  final act = activities[index];
                  final color =
                  activityPalette[act.colorIndex % activityPalette.length];
                  final total = c.totalMinutesAllTime(act.id);

                  return _ActivityCard(
                    title: act.title,
                    totalMinutes: total,
                    progressColor: color,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => ActivityDetailsScreen(
                            activityId: act.id,
                            autoStart: false,
                          ),
                        ),
                      );
                    },
                    onStart: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => ActivityDetailsScreen(
                            activityId: act.id,
                            autoStart: true,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),

          // Floating nav pill over content
          Align(
            alignment: Alignment.bottomCenter,
            child: NavBar(
              selectedIndex: 0,
              onDestinationSelected: (i) {
                if (i == 1) {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const HistoryScreen(),
                    ),
                  );
                  return;
                }
                // TODO: other tabs later
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

  // ---------- ADD ACTIVITY DIALOG ----------
  Future<void> _openAddActivityDialog(BuildContext context) async {
    final activities = context.read<ActivitiesController>();
    final titleCtrl = TextEditingController();
    int selected = 0;

    try {
      final result = await showDialog<(String, int)>(
        context: context,
        builder: (ctx) {
          return StatefulBuilder(
            builder: (ctx, setState) {
              Widget colorDot(int i) {
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
              }

              return AlertDialog(
                title: const Text('New activity'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleCtrl,
                      autofocus: true,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        hintText: 'e.g. Guitar',
                      ),
                      onSubmitted: (_) => Navigator.of(ctx)
                          .pop((titleCtrl.text.trim(), selected)),
                    ),
                    const SizedBox(height: 14),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Color',
                        style: Theme.of(ctx).textTheme.labelLarge,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: List.generate(activityPalette.length, colorDot),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(null),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.of(ctx)
                        .pop((titleCtrl.text.trim(), selected)),
                    child: const Text('Create'),
                  ),
                ],
              );
            },
          );
        },
      );

      if (result == null) return;

      final title = result.$1.trim();
      if (title.isEmpty) return;

      final id = DateTime.now().microsecondsSinceEpoch.toString();
      await activities.add(
        Activity(id: id, title: title, colorIndex: result.$2),
      );
    } finally {
      titleCtrl.dispose();
    }
  }
}

class _ActivityCard extends StatelessWidget {
  final String title;
  final Color progressColor;
  final VoidCallback? onTap;
  final VoidCallback? onStart;
  final int totalMinutes;

  const _ActivityCard({
    required this.title,
    required this.progressColor,
    this.onTap,
    this.onStart,
    this.totalMinutes = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.titleMedium),
              const SizedBox(height: 10),
              ProgressBar(
                totalMinutesAllTime: totalMinutes,
                compact: true,
                color: progressColor,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: progressColor,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: onStart,
                  child: const Text('Start'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddActivityCard extends StatelessWidget {
  final VoidCallback? onTap;

  const _AddActivityCard({this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_circle_outline,
                size: 40,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 10),
              Text('Add activity', style: theme.textTheme.titleMedium),
            ],
          ),
        ),
      ),
    );
  }
}