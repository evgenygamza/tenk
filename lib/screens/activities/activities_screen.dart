import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:tenk/screens/activities/widgets/activity_island.dart';
import 'package:tenk/screens/activities/widgets/activity_question_mark.dart';
import 'package:tenk/ui/widgets/populated_activities_view.dart';

class ActivitiesScreen extends StatefulWidget {
  const ActivitiesScreen({
    super.key,
    this.activityName,
    this.showTutorial = false,
  });

  static const screenKey = Key('activities_screen');
  static const emptyStateKey = Key('activities_empty_state');
  static const backButtonKey = Key('activities_back_button');
  static const addButtonKey = Key('activities_add_button');
  static const backgroundAsset = ActivityIsland.backgroundAsset;

  final String? activityName;
  final bool showTutorial;

  @override
  State<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen> {
  static const _previewActivityName = 'Guitar';

  String? _previewName;

  String? get _activityName => widget.activityName ?? _previewName;

  @override
  Widget build(BuildContext context) {
    final activityName = _activityName;
    if (activityName != null) {
      return Scaffold(
        key: ActivitiesScreen.screenKey,
        body: PopulatedActivitiesView(
          activityName: activityName,
          showTutorial: widget.showTutorial,
          onPreviewBack: widget.activityName == null
              ? () => setState(() => _previewName = null)
              : null,
        ),
      );
    }

    final compact = MediaQuery.sizeOf(context).height < 700;
    final canNavigateBack = Navigator.of(context).canPop();

    return Scaffold(
      key: ActivitiesScreen.screenKey,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const ActivityIsland(
            summitContent: ActivityQuestionMark(),
            summitSizeFactor: Size(0.12, 0.095),
            summitAnchor: ActivityIsland.roadEndpointAnchor,
            floatFactor: 0.2,
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.center,
                end: Alignment.bottomCenter,
                colors: [Color(0x080B271B), Color(0x700B271B)],
                stops: [0.3, 1],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                compact ? 24 : 32,
                compact ? 16 : 24,
                compact ? 24 : 32,
                compact ? 16 : 24,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      if (canNavigateBack)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.58),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                          child: IconButton(
                            key: ActivitiesScreen.backButtonKey,
                            tooltip: 'Back to Welcome',
                            onPressed: () => Navigator.of(context).maybePop(),
                            constraints: const BoxConstraints.tightFor(
                              width: 44,
                              height: 44,
                            ),
                            padding: EdgeInsets.zero,
                            icon: const Icon(
                              Icons.arrow_back_rounded,
                              color: Color(0xFF075039),
                              size: 24,
                            ),
                          ),
                        )
                      else
                        const SizedBox(width: 44),
                      const Expanded(
                        child: Text(
                          'TENK',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF075039),
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 6,
                          ),
                        ),
                      ),
                      const SizedBox(width: 44),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    key: ActivitiesScreen.emptyStateKey,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      children: [
                        Text(
                          'Add your first\nactivity',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: compact ? 32 : 38,
                            fontWeight: FontWeight.w700,
                            height: 1.08,
                            letterSpacing: -0.6,
                            shadows: const [
                              Shadow(
                                color: Color(0x88000000),
                                blurRadius: 14,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: compact ? 12 : 18),
                        Text(
                          'Tap “+” to start your journey.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: compact ? 17 : 19,
                            height: 1.4,
                            shadows: const [
                              Shadow(
                                color: Color(0x88000000),
                                blurRadius: 10,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  _AddActivityVisual(
                    compact: compact,
                    onPressed: () => setState(() {
                      _previewName = _previewActivityName;
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddActivityVisual extends StatelessWidget {
  const _AddActivityVisual({required this.compact, required this.onPressed});

  final bool compact;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 68.0 : 76.0;

    return Semantics(
      key: ActivitiesScreen.addButtonKey,
      label: 'Preview sample activity',
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.24),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.88),
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
                child: const Icon(Icons.add, color: Colors.white, size: 44),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
