import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:tenk/screens/activities/widgets/activity_island.dart';
import 'package:tenk/screens/activities/widgets/activity_landmark.dart';

class PopulatedActivitiesView extends StatefulWidget {
  const PopulatedActivitiesView({
    super.key,
    required this.activityName,
    this.showTutorial = false,
    this.onPreviewBack,
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

  final String activityName;
  final bool showTutorial;
  final VoidCallback? onPreviewBack;

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
  Widget build(BuildContext context) {
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
                                color: const Color(0xFF075039),
                                constraints: const BoxConstraints.tightFor(
                                  width: 40,
                                  height: 40,
                                ),
                                padding: EdgeInsets.zero,
                              )
                            else
                              const SizedBox(width: 40, height: 40),
                            Expanded(
                              child: Text(
                                widget.activityName,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Color(0xFF075039),
                                  fontSize: compact ? 23 : 27,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.4,
                                ),
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
                              const _ActivitySelector(),
                              SizedBox(width: compact ? 10 : 14),
                              _AddActivityVisual(compact: compact),
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
    return ClipRRect(
      key: PopulatedActivitiesView.tutorialKey,
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xDDF4EFE3),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(0.75)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'First step',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF273128),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Start your first session to begin your journey.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF454E45),
                ),
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
        ),
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
              backgroundColor: Colors.white.withOpacity(0.18),
              disabledBackgroundColor: Colors.white.withOpacity(0.18),
              side: BorderSide(
                color: Colors.white.withOpacity(0.82),
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
  const _ActivitySelector();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      key: PopulatedActivitiesView.activitySelectorKey,
      borderRadius: BorderRadius.circular(40),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.22),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(
              color: Colors.white.withOpacity(0.82),
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
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ActivityEmoji(emoji: '🎸', selected: true),
              _SelectorDivider(),
              _ActivityEmoji(emoji: '🎹'),
              _SelectorDivider(),
              _ActivityEmoji(emoji: '🏃'),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityEmoji extends StatelessWidget {
  const _ActivityEmoji({required this.emoji, this.selected = false});

  final String emoji;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      height: 48,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: selected
              ? BoxDecoration(
                  color: Colors.white.withOpacity(0.28),
                  shape: BoxShape.circle,
                )
              : null,
          child: Text(emoji, style: const TextStyle(fontSize: 29, height: 1)),
        ),
      ),
    );
  }
}

class _SelectorDivider extends StatelessWidget {
  const _SelectorDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 34,
      color: Colors.white.withOpacity(0.55),
    );
  }
}

class _AddActivityVisual extends StatelessWidget {
  const _AddActivityVisual({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 62.0 : 72.0;
    return Semantics(
      key: PopulatedActivitiesView.addActivityVisualKey,
      label: 'Add activity',
      button: true,
      enabled: false,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.22),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.88),
                width: 1.5,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x44202A22),
                  blurRadius: 14,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 42),
          ),
        ),
      ),
    );
  }
}
