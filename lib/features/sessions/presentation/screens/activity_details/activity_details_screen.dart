import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tenk/features/activities/presentation/state/activities_controller.dart';
import 'package:tenk/features/sessions/presentation/state/sessions_controller.dart';
import 'package:tenk/features/timer/presentation/state/timer_controller.dart';

import 'package:tenk/ui/activity_palette.dart';
import 'package:tenk/features/sessions/presentation/widgets/activity_details/activity_entries_block.dart';
import 'package:tenk/features/sessions/presentation/widgets/activity_details/activity_stats_block.dart';
import 'package:tenk/features/timer/presentation/widgets/activity_timer_block.dart';
import 'package:tenk/features/sessions/presentation/widgets/activity_details/activity_auto_pause_banner.dart';
import 'package:tenk/features/sessions/presentation/screens/activity_details/activity_details_actions.dart';

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

  @override
  void initState() {
    super.initState();

    if (widget.autoStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        final t = context.read<TimerController>();
        if (!_didAutoStart &&
            !t.isRunning(activityId: widget.activityId) &&
            t.elapsedSeconds(activityId: widget.activityId) == 0) {
          _didAutoStart = true;
          t.start(activityId: widget.activityId);
        }
      });
    }
  }

  Color _accentFromContext(BuildContext context) {
    final a = context.read<ActivitiesController>();
    final idx = a.activities.indexWhere((x) => x.id == widget.activityId);

    if (idx == -1) return Theme.of(context).colorScheme.primary;

    return activityPalette[
    a.activities[idx].colorIndex % activityPalette.length];
  }

  String _titleFromContext(BuildContext context) {
    final a = context.read<ActivitiesController>();
    final idx = a.activities.indexWhere((x) => x.id == widget.activityId);
    if (idx == -1) return 'Activity';
    return a.activities[idx].title;
  }

  ThemeData _activityTheme(BuildContext context, Color accentColor) {
    final base = Theme.of(context);
    final cs = base.colorScheme;

    final activityScheme = cs.copyWith(
      primary: accentColor,
      onPrimary: Colors.white,
    );

    final filledStyle = FilledButton.styleFrom(
      backgroundColor: accentColor,
      foregroundColor: Colors.white,
    );

    return base.copyWith(
      colorScheme: activityScheme,
      filledButtonTheme: FilledButtonThemeData(style: filledStyle),
      dialogTheme: base.dialogTheme.copyWith(surfaceTintColor: Colors.transparent),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sessions = context.watch<SessionsController>();
    context.watch<ActivitiesController>(); // react to rename/color updates

    final title = _titleFromContext(context);
    final accent = _accentFromContext(context);
    final themed = _activityTheme(context, accent);

    final entries = sessions.entries
        .where((e) => e.activityId == widget.activityId)
        .toList();

    return Theme(
      data: themed,
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          actions: [
            PopupMenuButton<_ActivityMenuAction>(
              onSelected: (a) async {
                switch (a) {
                  case _ActivityMenuAction.rename:
                    await ActivityDetailsActions.rename(context, activityId: widget.activityId);
                    break;
                  case _ActivityMenuAction.changeColor:
                    await ActivityDetailsActions.changeColor(context, activityId: widget.activityId);
                    break;
                  case _ActivityMenuAction.delete:
                    await ActivityDetailsActions.delete(context, activityId: widget.activityId);
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
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ActivityStatsBlock(
                activityId: widget.activityId,
                accent: accent,
                onMoreStats: () {
                  // TODO: open stats screen
                },
              ),
              ActivityAutoPauseBanner(activityId: widget.activityId),
              const SizedBox(height: 16),
              ActivityTimerBlock(
                activityId: widget.activityId,
                accent: accent,
              ),
              const SizedBox(height: 16),
              ActivityEntriesBlock(
                activityId: widget.activityId,
                entries: entries,
                onImportExperience: () {
                  // TODO: open calculator screen
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
