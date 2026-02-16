import 'package:flutter/material.dart';

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
          child: GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.92,
            children: [
              _ActivityCardStub(
                title: 'Guitar',
                progress: 0.62,
                progressColor: activityPalette[3], // purple
              ),
              _ActivityCardStub(
                title: 'Running',
                progress: 0.35,
                progressColor: activityPalette[1], // cyan
              ),
              _ActivityCardStub(
                title: 'SQL',
                progress: 0.82,
                progressColor: activityPalette[2], // orange
              ),
              const _AddActivityCardStub(),
            ],
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

  const _ActivityCardStub({
    required this.title,
    this.progress = 0.25,
    this.progressColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final color = progressColor ?? scheme.primary;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          debugPrint('Open $title');
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.titleMedium),
              const SizedBox(height: 10),
              Text('Today: 0m', style: theme.textTheme.bodyMedium),
              const SizedBox(height: 10),

              // Progress (цветной)
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
                  onPressed: () => debugPrint('Start $title'),
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
