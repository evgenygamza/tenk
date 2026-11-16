import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:tenk/app/app_theme.dart';
import 'package:tenk/features/activities/domain/models/first_activity.dart';
import 'package:tenk/features/activities/presentation/activity_icon_catalog.dart';
import 'package:tenk/features/timer/domain/controllers/daily_timer_controller.dart';
import 'package:tenk/screens/activities/widgets/activity_add_button.dart';
import 'package:tenk/screens/activities/widgets/activity_landmark.dart';
import 'package:tenk/screens/activities/widgets/activities_timer_button.dart';
import 'package:tenk/screens/activities/widgets/activities_session_timer.dart';
import 'package:tenk/ui/widgets/activity_panorama_layout.dart';
import 'package:tenk/ui/widgets/translucent_panel.dart';

typedef ActivityFinishBuilder =
    Widget Function(BuildContext context, FirstActivity activity);

class PopulatedActivitiesView extends StatefulWidget {
  const PopulatedActivitiesView({
    super.key,
    required this.activities,
    required this.timerController,
    this.selectedIndex = 0,
    this.showTutorial = false,
    this.onPreviewBack,
    this.onSelectActivity,
    this.onLongPressActivity,
    this.onAddActivity,
    this.activityFinishBuilder,
    this.showAddActivity = true,
  });

  static const viewKey = Key('populated_activities_view');
  static const tutorialKey = Key('activities_tutorial');
  static const dismissTutorialKey = Key('activities_dismiss_tutorial');
  static const startSessionKey = ActivitiesTimerButton.toggleButtonKey;
  static const goalKey = Key('activities_goal');
  static const etaKey = ActivitiesSessionTimer.estimateKey;
  static const weeklyPracticeKey = ActivitiesSessionTimer.weeklyPracticeKey;
  static const activitySelectorKey = Key('activities_selector');
  static const addActivityVisualKey = Key('activities_add_visual');
  static const previewBackKey = Key('activities_preview_back');
  static const panoramaPageViewKey = Key('activities_panorama_page_view');

  static const backgroundAsset = 'lib/ui/graphics/activities_panorama.png';
  static const panoramaArtworkKey = Key('activities_panorama_artwork');

  final List<FirstActivity> activities;
  final DailyTimerController timerController;
  final int selectedIndex;
  final bool showTutorial;
  final VoidCallback? onPreviewBack;
  final ValueChanged<int>? onSelectActivity;
  final void Function(BuildContext context, int index)? onLongPressActivity;
  final VoidCallback? onAddActivity;
  final ActivityFinishBuilder? activityFinishBuilder;
  final bool showAddActivity;

  @override
  State<PopulatedActivitiesView> createState() =>
      _PopulatedActivitiesViewState();
}

class _PopulatedActivitiesViewState extends State<PopulatedActivitiesView> {
  late bool _showTutorial;
  late final PageController _pageController;
  double _horizontalDragDelta = 0;

  @override
  void initState() {
    super.initState();
    _showTutorial = widget.showTutorial;
    _pageController = PageController(initialPage: widget.selectedIndex);
  }

  @override
  void didUpdateWidget(covariant PopulatedActivitiesView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex &&
        (_pageController.page?.round() ?? widget.selectedIndex) !=
            widget.selectedIndex) {
      _pageController.animateToPage(
        widget.selectedIndex,
        duration: const Duration(milliseconds: 360),
        curve: Curves.easeInOutCubic,
      );
    }
    if (oldWidget.showTutorial != widget.showTutorial) {
      _showTutorial = widget.showTutorial;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.timerController,
      builder: (context, _) => _buildView(context),
    );
  }

  Widget _buildView(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragStart: (_) => _horizontalDragDelta = 0,
      onHorizontalDragUpdate: (details) {
        _horizontalDragDelta += details.delta.dx;
      },
      onHorizontalDragEnd: _handleHorizontalDragEnd,
      child: Stack(
        key: PopulatedActivitiesView.viewKey,
        fit: StackFit.expand,
        children: [
          LayoutBuilder(
            key: PopulatedActivitiesView.goalKey,
            builder: (context, constraints) => IgnorePointer(
              child: AnimatedBuilder(
                animation: _pageController,
                builder: (context, _) => _PanoramaBackdrop(
                  layout: ActivityPanoramaLayout(
                    viewport: constraints.biggest,
                    page: _pageController.hasClients
                        ? _pageController.page ??
                              widget.selectedIndex.toDouble()
                        : widget.selectedIndex.toDouble(),
                  ),
                  activities: widget.activities,
                  finishBuilder: widget.activityFinishBuilder,
                ),
              ),
            ),
          ),
          const IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x180B271B),
                    Color(0x120B271B),
                    Color(0x5C0B271B),
                  ],
                  stops: [0, 0.48, 1],
                ),
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxHeight < 700;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, pageConstraints) => PageView.builder(
                          key: PopulatedActivitiesView.panoramaPageViewKey,
                          controller: _pageController,
                          itemCount: widget.activities.length,
                          onPageChanged: widget.onSelectActivity,
                          itemBuilder: (context, index) => _buildActivityPage(
                            context,
                            index,
                            pageConstraints,
                            compact,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        20,
                        compact ? 8 : 12,
                        20,
                        compact ? 8 : 10,
                      ),
                      child: Center(
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
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityPage(
    BuildContext context,
    int index,
    BoxConstraints constraints,
    bool compact,
  ) {
    final activity = widget.activities[index];
    final horizontalPadding = constraints.maxWidth < 360 ? 20.0 : 28.0;
    final verticalPadding = compact ? 8.0 : 10.0;
    return ExcludeSemantics(
      excluding: index != widget.selectedIndex,
      child: SingleChildScrollView(
        key: ValueKey('activities_page_${activity.id}'),
        primary: false,
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: (constraints.maxHeight - verticalPadding * 2)
                .clamp(0.0, double.infinity)
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
                              activityIconFor(activity.iconId).icon,
                              key: ValueKey(activity.iconId),
                              color: appInkColor,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 260),
                              transitionBuilder: (child, animation) =>
                                  FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  ),
                              child: Text(
                                activity.name,
                                key: ValueKey(activity.name),
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

                const Spacer(flex: 2),
                ActivitiesSessionTimer(
                  key: ValueKey('activities_timer_${activity.id}'),
                  activity: activity,
                  timerController: widget.timerController,
                  isVisible: index == widget.selectedIndex,
                  diameter: math.min(
                    appTimerRunningDiameter,
                    math.min(
                      constraints.maxWidth - horizontalPadding * 2,
                      (constraints.maxHeight - 220)
                          .clamp(240.0, appTimerRunningDiameter)
                          .toDouble(),
                    ),
                  ),
                ),
                if (_showTutorial && index == widget.selectedIndex) ...[
                  SizedBox(height: compact ? 12 : 18),
                  _tutorialCard(context),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleHorizontalDragEnd(DragEndDetails details) {
    if (!_pageController.hasClients || widget.activities.length < 2) return;

    final currentPage = _pageController.page?.round() ?? widget.selectedIndex;
    final width = MediaQuery.sizeOf(context).width;
    final velocity = details.primaryVelocity ?? 0;
    final direction = _horizontalDragDelta.abs() >= width * 0.2
        ? _horizontalDragDelta.sign
        : velocity.abs() >= 500
        ? velocity.sign
        : 0;
    if (direction == 0) return;

    final nextPage = (currentPage + (direction < 0 ? 1 : -1))
        .clamp(0, widget.activities.length - 1)
        .toInt();
    if (nextPage == currentPage) return;
    _pageController.animateToPage(
      nextPage,
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeInOutCubic,
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
            'Start tracking your first activity to begin your journey.',
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
}

class _PanoramaBackdrop extends StatelessWidget {
  const _PanoramaBackdrop({
    required this.layout,
    required this.activities,
    required this.finishBuilder,
  });

  final ActivityPanoramaLayout layout;
  final List<FirstActivity> activities;
  final ActivityFinishBuilder? finishBuilder;

  @override
  Widget build(BuildContext context) {
    final decodeWidth =
        (layout.renderedArtworkSize.width *
                MediaQuery.devicePixelRatioOf(context))
            .ceil()
            .clamp(1, ActivityPanoramaLayout.artworkSize.width.toInt());
    return Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        Positioned(
          left: layout.artworkOffset.dx,
          top: layout.artworkOffset.dy,
          width: layout.renderedArtworkSize.width,
          height: layout.renderedArtworkSize.height,
          child: Image.asset(
            PopulatedActivitiesView.backgroundAsset,
            key: PopulatedActivitiesView.panoramaArtworkKey,
            fit: BoxFit.fill,
            cacheWidth: decodeWidth,
          ),
        ),
        for (var index = 0; index < activities.length; index++)
          if (layout.finishRect(index).overlaps(Offset.zero & layout.viewport))
            Positioned.fromRect(
              rect: layout.finishRect(index),
              child: ExcludeSemantics(
                excluding: index != layout.page.round(),
                child: KeyedSubtree(
                  key: ValueKey('activities_finish_anchor_$index'),
                  child:
                      finishBuilder?.call(context, activities[index]) ??
                      const ActivityLandmark(hours: 100),
                ),
              ),
            ),
      ],
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
