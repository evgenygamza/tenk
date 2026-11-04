import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:tenk/app/app_theme.dart';
import 'package:tenk/features/activities/domain/models/first_activity.dart';
import 'package:tenk/features/activities/presentation/activity_icon_catalog.dart';
import 'package:tenk/screens/activities/widgets/activity_add_button.dart';
import 'package:tenk/screens/activities/widgets/activity_island.dart';
import 'package:tenk/screens/activities/widgets/activity_landmark.dart';
import 'package:tenk/ui/widgets/translucent_panel.dart';

class PopulatedActivitiesView extends StatefulWidget {
  const PopulatedActivitiesView({
    super.key,
    required this.activities,
    this.selectedIndex = 0,
    this.showTutorial = false,
    this.onPreviewBack,
    this.onSelectActivity,
    this.onLongPressActivity,
    this.onAddActivity,
    this.showAddActivity = true,
  });

  static const viewKey = Key('populated_activities_view');
  static const tutorialKey = Key('activities_tutorial');
  static const dismissTutorialKey = Key('activities_dismiss_tutorial');
  static const startSessionKey = Key('activities_start_session');
  static const goalKey = Key('activities_goal');
  static const etaKey = Key('activities_goal_eta');
  static const activitySelectorKey = Key('activities_selector');
  static const addActivityVisualKey = Key('activities_add_visual');
  static const previewBackKey = Key('activities_preview_back');

  static const backgroundAsset = ActivityIsland.backgroundAsset;

  final List<FirstActivity> activities;
  final int selectedIndex;
  final bool showTutorial;
  final VoidCallback? onPreviewBack;
  final ValueChanged<int>? onSelectActivity;
  final void Function(BuildContext context, int index)? onLongPressActivity;
  final VoidCallback? onAddActivity;
  final bool showAddActivity;

  @override
  State<PopulatedActivitiesView> createState() =>
      _PopulatedActivitiesViewState();
}

class _PopulatedActivitiesViewState extends State<PopulatedActivitiesView> {
  late bool _showTutorial;

  @override
  void initState() {
    super.initState();
    _showTutorial = widget.showTutorial;
  }

  @override
  void didUpdateWidget(covariant PopulatedActivitiesView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.showTutorial != widget.showTutorial) {
      _showTutorial = widget.showTutorial;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedActivity = widget.activities[widget.selectedIndex];
    return Stack(
      key: PopulatedActivitiesView.viewKey,
      fit: StackFit.expand,
      children: [
        ActivityIsland(
          key: PopulatedActivitiesView.goalKey,
          summitContent: const ActivityLandmark(hours: 100),
          summitSizeFactor: const Size(0.2, 0.105),
          summitAnchor: ActivityIsland.roadEndpointAnchor,
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x180B271B), Color(0x120B271B), Color(0x5C0B271B)],
              stops: [0, 0.48, 1],
            ),
          ),
        ),
        SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxHeight < 700;
              final horizontalPadding = constraints.maxWidth < 360
                  ? 20.0
                  : 28.0;
              final verticalPadding = compact ? 8.0 : 10.0;

              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  verticalPadding,
                  horizontalPadding,
                  verticalPadding,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: (constraints.maxHeight - verticalPadding * 2)
                        .clamp(0, double.infinity)
                        .toDouble(),
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            if (widget.onPreviewBack != null)
                              IconButton(
                                key: PopulatedActivitiesView.previewBackKey,
                                onPressed: widget.onPreviewBack,
                                icon: const Icon(Icons.arrow_back),
                                color: appInkColor,
                                constraints: const BoxConstraints.tightFor(
                                  width: 40,
                                  height: 40,
                                ),
                                padding: EdgeInsets.zero,
                              )
                            else
                              const SizedBox(width: 40, height: 40),
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 260),
                                    transitionBuilder: (child, animation) =>
                                        ScaleTransition(
                                          scale: animation,
                                          child: FadeTransition(
                                            opacity: animation,
                                            child: child,
                                          ),
                                        ),
                                    child: Icon(
                                      activityIconFor(
                                        selectedActivity.iconId,
                                      ).icon,
                                      key: ValueKey(selectedActivity.iconId),
                                      color: appInkColor,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: AnimatedSwitcher(
                                      duration: const Duration(
                                        milliseconds: 260,
                                      ),
                                      transitionBuilder: (child, animation) =>
                                          FadeTransition(
                                            opacity: animation,
                                            child: child,
                                          ),
                                      child: Text(
                                        selectedActivity.name,
                                        key: ValueKey(selectedActivity.name),
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: appInkColor,
                                          fontSize: compact ? 23 : 27,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 1.4,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 40, height: 40),
                          ],
                        ),
                        SizedBox(height: compact ? 8 : 12),
                        const Text(
                          '18 days to your goal',
                          key: PopulatedActivitiesView.etaKey,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            shadows: [
                              Shadow(
                                color: Color(0x66000000),
                                blurRadius: 10,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: compact ? 2 : 4),
                        const Spacer(flex: 3),
                        Text(
                          'Every hour brings you closer\nto mastery.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: compact ? 25 : 30,
                            fontWeight: FontWeight.w700,
                            height: 1.12,
                            letterSpacing: -0.3,
                            shadows: const [
                              Shadow(
                                color: Color(0x88000000),
                                blurRadius: 12,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                        if (_showTutorial) ...[
                          SizedBox(height: compact ? 12 : 18),
                          _tutorialCard(context),
                        ],
                        SizedBox(height: compact ? 14 : 20),
                        _glassButton(
                          child: const Text('Start Session'),
                          onPressed: null,
                        ),
                        SizedBox(height: compact ? 14 : 22),
                        Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _ActivitySelector(
                                activities: widget.activities,
                                selectedIndex: widget.selectedIndex,
                                onSelected: widget.onSelectActivity,
                                onLongPressActivity: widget.onLongPressActivity,
                              ),
                              SizedBox(width: compact ? 10 : 14),
                              if (widget.showAddActivity)
                                ActivityAddButton(
                                  key: PopulatedActivitiesView
                                      .addActivityVisualKey,
                                  compact: compact,
                                  onPressed: widget.onAddActivity,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _tutorialCard(BuildContext context) {
    return TranslucentPanel(
      key: PopulatedActivitiesView.tutorialKey,
      radius: 18,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'First step',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: appInkColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Start your first session to begin your journey.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: appInkColor),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              key: PopulatedActivitiesView.dismissTutorialKey,
              onPressed: () => setState(() => _showTutorial = false),
              child: const Text('Got it'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _glassButton({
    required Widget child,
    required VoidCallback? onPressed,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(36),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: SizedBox(
          height: 68,
          child: OutlinedButton(
            key: PopulatedActivitiesView.startSessionKey,
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              disabledForegroundColor: Colors.white,
              backgroundColor: Colors.white.withValues(alpha: 0.18),
              disabledBackgroundColor: Colors.white.withValues(alpha: 0.18),
              side: BorderSide(
                color: Colors.white.withValues(alpha: 0.82),
                width: 1.5,
              ),
              shape: const StadiumBorder(),
              textStyle: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _ActivitySelector extends StatelessWidget {
  const _ActivitySelector({
    required this.activities,
    required this.selectedIndex,
    required this.onSelected,
    required this.onLongPressActivity,
  });

  final List<FirstActivity> activities;
  final int selectedIndex;
  final ValueChanged<int>? onSelected;
  final void Function(BuildContext context, int index)? onLongPressActivity;

  @override
  Widget build(BuildContext context) {
    final available = (MediaQuery.sizeOf(context).width - 152)
        .clamp(0, 280)
        .toDouble();
    final contentWidth = activities.length * 48.0 + 19;
    return SizedBox(
      width: math.min(available, contentWidth).toDouble(),
      child: ClipRRect(
        key: PopulatedActivitiesView.activitySelectorKey,
        borderRadius: BorderRadius.circular(40),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.82),
                width: 1.4,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x44202A22),
                  blurRadius: 14,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var index = 0; index < activities.length; index++)
                    _ActivityIcon(
                      key: ValueKey('activities_selector_item_$index'),
                      icon: activityIconFor(activities[index].iconId).icon,
                      selected: index == selectedIndex,
                      onTap: onSelected == null
                          ? null
                          : () => onSelected!(index),
                      onLongPress: onLongPressActivity == null
                          ? null
                          : (iconContext) =>
                                onLongPressActivity!(iconContext, index),
                      label: activities[index].name,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActivityIcon extends StatelessWidget {
  const _ActivityIcon({
    super.key,
    required this.icon,
    required this.selected,
    required this.onTap,
    required this.onLongPress,
    required this.label,
  });

  final IconData icon;
  final bool selected;
  final VoidCallback? onTap;
  final ValueChanged<BuildContext>? onLongPress;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      button: true,
      selected: selected,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress == null ? null : () => onLongPress!(context),
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 48,
          height: 46,
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: const EdgeInsets.all(5),
              decoration: selected
                  ? BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.32),
                      shape: BoxShape.circle,
                    )
                  : null,
              child: Icon(icon, color: Colors.white, size: 25),
            ),
          ),
        ),
      ),
    );
  }
}
