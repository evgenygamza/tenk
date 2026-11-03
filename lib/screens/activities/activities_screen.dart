import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:tenk/app/app_theme.dart';
import 'package:tenk/features/activities/domain/models/first_activity.dart';
import 'package:tenk/features/activities/domain/repositories/first_activity_repository.dart';
import 'package:tenk/features/activities/presentation/create_activity_screen.dart';
import 'package:tenk/screens/activities/widgets/activity_island.dart';
import 'package:tenk/screens/activities/widgets/activity_question_mark.dart';
import 'package:tenk/ui/widgets/populated_activities_view.dart';

class ActivitiesScreen extends StatefulWidget {
  const ActivitiesScreen({
    super.key,
    this.activityName,
    this.activityIconId = 'instrument',
    this.repository,
    this.showTutorial = false,
  });

  static const screenKey = Key('activities_screen');
  static const emptyStateKey = Key('activities_empty_state');
  static const backButtonKey = Key('activities_back_button');
  static const addButtonKey = Key('activities_add_button');
  static const createOverlayKey = Key('activities_create_overlay');
  static const backgroundAsset = ActivityIsland.backgroundAsset;

  final String? activityName;
  final String activityIconId;
  final FirstActivityRepository? repository;
  final bool showTutorial;

  @override
  State<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen> {
  FirstActivity? _savedActivity;
  bool _isCreating = false;
  bool _showTutorial = false;

  @override
  Widget build(BuildContext context) {
    final activityName = widget.activityName ?? _savedActivity?.name;
    final activityIconId = widget.activityName == null
        ? _savedActivity?.iconId ?? widget.activityIconId
        : widget.activityIconId;
    if (activityName != null) {
      return Scaffold(
        key: ActivitiesScreen.screenKey,
        body: PopulatedActivitiesView(
          activityName: activityName,
          activityIconId: activityIconId,
          showTutorial: widget.showTutorial || _showTutorial,
        ),
      );
    }

    final compact = MediaQuery.sizeOf(context).height < 700;
    final canNavigateBack = Navigator.of(context).canPop();

    return PopScope<void>(
      canPop: !_isCreating,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _isCreating) {
          setState(() => _isCreating = false);
        }
      },
      child: Scaffold(
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
                          IconButton(
                            key: ActivitiesScreen.backButtonKey,
                            tooltip: 'Back to Welcome',
                            onPressed: () => Navigator.of(context).maybePop(),
                            icon: const Icon(Icons.arrow_back),
                            color: appInkColor,
                            constraints: const BoxConstraints.tightFor(
                              width: 40,
                              height: 40,
                            ),
                            padding: EdgeInsets.zero,
                          )
                        else
                          const SizedBox(width: 40),
                        const Expanded(
                          child: Text(
                            'TENK',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: appInkColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 6,
                            ),
                          ),
                        ),
                        const SizedBox(width: 40),
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
                      onPressed: widget.repository == null
                          ? null
                          : () => setState(() => _isCreating = true),
                    ),
                  ],
                ),
              ),
            ),
            if (_isCreating && widget.repository != null) ...[
              ModalBarrier(
                key: ActivitiesScreen.createOverlayKey,
                color: Colors.black.withValues(alpha: 0.24),
                dismissible: false,
              ),
              CreateActivityScreen(
                repository: widget.repository!,
                onCancel: () => setState(() => _isCreating = false),
                onSaved: (activity) => setState(() {
                  _savedActivity = activity;
                  _isCreating = false;
                  _showTutorial = true;
                }),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AddActivityVisual extends StatelessWidget {
  const _AddActivityVisual({required this.compact, required this.onPressed});

  final bool compact;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 68.0 : 76.0;

    return Semantics(
      key: ActivitiesScreen.addButtonKey,
      label: 'Add activity',
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
