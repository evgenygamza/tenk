import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tenk/features/sessions/presentation/state/sessions_controller.dart';
import 'package:tenk/features/activities/presentation/state/activities_controller.dart';

import 'package:tenk/features/sessions/presentation/screens/add_manual_screen.dart';
import 'package:tenk/features/sessions/presentation/screens/history_screen.dart';
import 'package:tenk/features/sessions/presentation/screens/dashboard_screen.dart';

import 'package:tenk/features/sessions/presentation/widgets/stop_session_dialog.dart';
import 'package:tenk/features/sessions/presentation/widgets/edit_session_dialog.dart';
import 'package:tenk/features/sessions/presentation/widgets/confirm_delete_session_dialog.dart';
import 'package:tenk/features/sessions/presentation/widgets/session_list.dart';

import 'package:tenk/ui/progress_bar.dart';
import 'package:tenk/ui/nav_bar.dart';

enum _ActivityMenuAction { rename, changeColor, delete }

class ActivityDetailsScreen extends StatefulWidget {
  final String activityId;
  final bool autoStart;

  const ActivityDetailsScreen({
    super.key,
    required this.activityId,
    this.autoStart = false,
  });

  @override
  State<ActivityDetailsScreen> createState() => _ActivityDetailsScreenState();
}

class _ActivityDetailsScreenState extends State<ActivityDetailsScreen> {
  bool _didAutoStart = false;

  ThemeData _activityTheme(BuildContext context, Color accentColor) {
    final base = Theme.of(context);
    final cs = base.colorScheme;

    // Keep overall M3 scheme, but set the "primary" to the activity accent.
    final activityScheme = cs.copyWith(
      primary: accentColor,
      // Helps FilledButton when disabled/tonal etc.
      onPrimary: Colors.white,
    );

    final filledStyle = FilledButton.styleFrom(
      backgroundColor: accentColor,
      foregroundColor: Colors.white,
    );

    return base.copyWith(
      colorScheme: activityScheme,
      filledButtonTheme: FilledButtonThemeData(style: filledStyle),
      // Optional: make Dialog buttons consistent too
      dialogTheme: base.dialogTheme.copyWith(
        surfaceTintColor: Colors.transparent,
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    if (widget.autoStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final c = context.read<SessionsController>();

        if (!_didAutoStart && !c.isRunning && c.elapsedSeconds == 0) {
          _didAutoStart = true;
          c.startTimer();
        }
      });
    }
  }

  Color _accentFromContext(BuildContext context) {
    final a = context.read<ActivitiesController>();
    final idx = a.activities.indexWhere((x) => x.id == widget.activityId);

    if (idx == -1) return Theme.of(context).colorScheme.primary;

    return activityPalette[a.activities[idx].colorIndex %
        activityPalette.length];
  }

  String _titleFromContext(BuildContext context) {
    final a = context.read<ActivitiesController>();
    final idx = a.activities.indexWhere((x) => x.id == widget.activityId);

    if (idx == -1) return 'Activity';
    return a.activities[idx].title;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<SessionsController>();
    context.watch<ActivitiesController>();
    final title = _titleFromContext(context);
    final accent = _accentFromContext(context);
    final themed = _activityTheme(context, accent);
    final entries = c.entries
        .where((e) => e.activityId == widget.activityId)
        .toList();

    return Theme(
      data: themed,
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          backgroundColor: _accentFromContext(context),
          foregroundColor: Colors.white,
          actions: [
            PopupMenuButton<_ActivityMenuAction>(
              onSelected: (a) async {
                switch (a) {
                  case _ActivityMenuAction.rename:
                    await _renameActivity();
                    break;
                  case _ActivityMenuAction.changeColor:
                    await _changeColor();
                    break;
                  case _ActivityMenuAction.delete:
                    await _deleteActivity();
                    break;
                }
              },
              itemBuilder: (ctx) => const [
                PopupMenuItem(
                  value: _ActivityMenuAction.rename,
                  child: Text('Rename'),
                ),
                PopupMenuItem(
                  value: _ActivityMenuAction.changeColor,
                  child: Text('Change color'),
                ),
                PopupMenuItem(
                  value: _ActivityMenuAction.delete,
                  child: Text('Delete'),
                ),
              ],
            ),
          ],
        ),
        body: Stack(
          children: [
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today: ${_formatHoursMinutes(c.totalMinutesToday(widget.activityId))}',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'All time: ${_formatHoursMinutes(c.totalMinutesAllTime(widget.activityId))}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    ProgressBar(
                      totalMinutesAllTime: c.totalMinutesAllTime(
                        widget.activityId,
                      ),
                      color: _accentFromContext(context),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Timer: ${_formatElapsed(c.elapsedSeconds)}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton(
                            onPressed: c.isRunning
                                ? null
                                : () => c.startTimer(),
                            child: const Text('Start'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FilledButton(
                            onPressed: c.isRunning
                                ? () => c.pauseTimer()
                                : null,
                            child: const Text('Pause'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FilledButton(
                            onPressed: c.elapsedSeconds == 0
                                ? null
                                : () async {
                                    final sessions = context
                                        .read<SessionsController>();

                                    sessions.pauseTimer();

                                    final now = DateTime.now();
                                    final initialEnd = now;
                                    final initialStart = initialEnd.subtract(
                                      Duration(
                                        seconds: sessions.elapsedSeconds,
                                      ),
                                    );

                                    final result = await StopSessionDialog.open(
                                      context,
                                      initialStart: initialStart,
                                      initialEnd: initialEnd,
                                    );

                                    if (!context.mounted || result == null) {
                                      return;
                                    }

                                    await sessions.stopAndSave(
                                      activityId: widget.activityId,
                                      note: result.note,
                                      startedAt: result.startedAt,
                                      finishedAt: result.finishedAt,
                                    );
                                  },
                            child: const Text('Stop'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          final themed = _activityTheme(
                            context,
                            _accentFromContext(context),
                          );
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => Theme(
                                data: themed,
                                child: AddManualScreen(
                                  activityId: widget.activityId,
                                ),
                              ),
                            ),
                          );
                        },
                        child: const Text('Add manually'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          context.read<SessionsController>().addManual(
                            widget.activityId,
                            60,
                          );
                        },
                        child: const Text('+1 hour'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          context.read<SessionsController>().resetActivity(
                            widget.activityId,
                          );
                        },
                        child: const Text('Reset'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: SessionList(
                        entries: entries,
                        onDelete: (id) =>
                            context.read<SessionsController>().deleteEntry(id),
                        confirmDelete: (ctx, e) =>
                            confirmDeleteSessionDialog(ctx, entry: e),
                        onEdit: (entry) async {
                          final sessions = context.read<SessionsController>();
                          final dialogContext = context;
                          final updated = await showEditSessionDialog(
                            dialogContext,
                            entry: entry,
                          );
                          if (updated == null) return;
                          await sessions.updateEntry(updated);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: NavBar(
                selectedIndex: 0,
                onDestinationSelected: (i) {
                  if (i == 1) {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const DashboardScreen(),
                      ),
                    );
                    return;
                  }
                  if (i == 2) {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const HistoryScreen(),
                      ),
                    );
                    return;
                  }
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
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _renameActivity() async {
    final activities = context.read<ActivitiesController>();
    final idx = activities.activities.indexWhere(
      (a) => a.id == widget.activityId,
    );
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

    if (!mounted) return;
    setState(() {});
  }

  Future<void> _changeColor() async {
    final activities = context.read<ActivitiesController>();
    final idx = activities.activities.indexWhere(
      (a) => a.id == widget.activityId,
    );
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
                          ? const Icon(
                              Icons.check,
                              size: 18,
                              color: Colors.white,
                            )
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
    if (!mounted) return;
    setState(
      () {},
    ); // чтобы AppBar/акценты обновились, если ты их читаешь из контроллера
  }

  Future<void> _deleteActivity() async {
    // capture dependencies up-front
    final sessions = context.read<SessionsController>();
    final activities = context.read<ActivitiesController>();
    final nav = Navigator.of(context);
    final dialogContext = context;

    final ok = await showDialog<bool>(
      context: dialogContext,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Delete activity?'),
          content: const Text(
            'This will delete the activity and all its sessions.',
          ),
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

    await sessions.resetActivity(widget.activityId);
    await activities.delete(widget.activityId);

    if (!mounted) return;
    nav.pop();
  }

  // ---------- helpers ----------
  static String _formatElapsed(int seconds) {
    final mm = (seconds ~/ 60).toString().padLeft(2, '0');
    final ss = (seconds % 60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  static String _formatHoursMinutes(int totalMinutes) {
    final h = totalMinutes ~/ 60;
    final m = totalMinutes % 60;
    if (h <= 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }
}
