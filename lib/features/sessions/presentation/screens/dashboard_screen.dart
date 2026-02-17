import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tenk/features/sessions/presentation/state/sessions_controller.dart';
import 'activity_details_screen.dart';

const activityPalette = [
  Color(0xFF22C55E), // green
  Color(0xFF06B6D4), // cyan
  Color(0xFFF97316), // orange
  Color(0xFFA855F7), // purple
  Color(0xFFEC4899), // pink
];

const stubActivities = [
  ActivityStub(id: 'guitar', title: 'Guitar', progress: 0.62, colorIndex: 3),
  ActivityStub(id: 'running', title: 'Running', progress: 0.35, colorIndex: 1),
  ActivityStub(id: 'sql', title: 'SQL', progress: 0.82, colorIndex: 2),
];

class ActivityStub {
  final String id;
  final String title;
  final double progress;
  final int colorIndex;

  const ActivityStub({
    required this.id,
    required this.title,
    required this.progress,
    required this.colorIndex,
  });
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<SessionsController>();
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.92,
            ),
            itemCount: stubActivities.length + 1, // + Add card
            itemBuilder: (context, index) {
              if (index == stubActivities.length) {
                return const _AddActivityCardStub();
              }

              final a = stubActivities[index];
              return _ActivityCardStub(
                title: a.title,
                progress: a.progress,
                progressColor: activityPalette[a.colorIndex % activityPalette.length],
                todayMinutes: c.totalMinutesToday(a.id),

                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ActivityDetailsScreen(
                        activityTitle: a.title,
                        activityId: a.id,
                        autoStart: false,
                      ),
                    ),
                  );
                },

                onStart: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ActivityDetailsScreen(
                        activityTitle: a.title,
                        activityId: a.id,
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
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (i) {
          // TODO: навигация между вкладками
          debugPrint('Tab $i');
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.grid_view_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.tune_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class _ActivityCardStub extends StatelessWidget {
  final String title;
  final double progress;
  final Color? progressColor;
  final VoidCallback? onTap;
  final VoidCallback? onStart;
  final int todayMinutes;

  const _ActivityCardStub({
    required this.title,
    this.progress = 0.25,
    this.progressColor,
    this.onTap,
    this.onStart,
    this.todayMinutes = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = progressColor ?? scheme.primary;

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
              Text('Today: ${todayMinutes}m', style: theme.textTheme.bodyMedium),
              const SizedBox(height: 10),
              LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                color: color,
                backgroundColor: scheme.surfaceContainerHighest,
                minHeight: 8,
                borderRadius: const BorderRadius.all(Radius.circular(999)),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
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

class _AddActivityCardStub extends StatelessWidget {
  const _AddActivityCardStub();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // TODO: открыть Create Activity
          debugPrint('Add activity');
        },
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add_circle_outline, size: 36),
                const SizedBox(height: 10),
                Text('Add activity', style: theme.textTheme.titleMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
