import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:tenk/app/app_theme.dart';
import 'package:tenk/features/activities/domain/models/first_activity.dart';
import 'package:tenk/features/activities/domain/repositories/first_activity_repository.dart';
import 'package:tenk/features/activities/presentation/create_activity_screen.dart';
import 'package:tenk/features/timer/domain/controllers/daily_timer_controller.dart';
import 'package:tenk/features/timer/domain/models/daily_timer_data.dart';
import 'package:tenk/features/timer/domain/repositories/daily_timer_repository.dart';
import 'package:tenk/screens/activities/widgets/activity_add_button.dart';
import 'package:tenk/screens/activities/widgets/activity_island.dart';
import 'package:tenk/screens/activities/widgets/activity_question_mark.dart';
import 'package:tenk/ui/widgets/populated_activities_view.dart';

enum _ActivityMenuAction { edit, delete }

class ActivitiesScreen extends StatefulWidget {
  const ActivitiesScreen({
    super.key,
    this.activities = const [],
    this.selectedIndex = 0,
    this.activityName,
    this.activityIconId = 'instrument',
    this.repository,
    this.timerController,
    this.showTutorial = false,
  });

  static const screenKey = Key('activities_screen');
  static const emptyStateKey = Key('activities_empty_state');
  static const backButtonKey = Key('activities_back_button');
  static const addButtonKey = Key('activities_add_button');
  static const createOverlayKey = Key('activities_create_overlay');
  static const deleteConfirmButtonKey = Key('activity_delete_confirm');
  static const backgroundAsset = ActivityIsland.backgroundAsset;
  static const maxActivities = 5;

  final List<FirstActivity> activities;
  final int selectedIndex;

  /// Supports the existing single-activity preview entry point.
  final String? activityName;
  final String activityIconId;
  final FirstActivityRepository? repository;
  final DailyTimerController? timerController;
  final bool showTutorial;

  @override
  State<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen> {
  late List<FirstActivity> _activities;
  late int _selectedIndex;
  bool _isCreating = false;
  bool _showTutorial = false;
  int? _editingIndex;
  late final DailyTimerController _timerController;
  late final bool _ownsTimerController;

  @override
  void initState() {
    super.initState();
    _ownsTimerController = widget.timerController == null;
    _timerController =
        widget.timerController ??
        DailyTimerController(repository: _EphemeralDailyTimerRepository());
    _activities = List.of(widget.activities);
    _selectedIndex = _activities.isEmpty
        ? 0
        : widget.selectedIndex.clamp(0, _activities.length - 1).toInt();
    if (_activities.isEmpty && widget.activityName != null) {
      _activities = [
        FirstActivity(
          name: widget.activityName!,
          iconId: widget.activityIconId,
        ),
      ];
    }
  }

  @override
  void dispose() {
    if (_ownsTimerController) _timerController.dispose();
    super.dispose();
  }

  Future<void> _saveActivity(FirstActivity activity) async {
    final editingIndex = _editingIndex;
    late final List<FirstActivity> updated;
    late final int selectedIndex;
    if (editingIndex == null) {
      if (_activities.length >= ActivitiesScreen.maxActivities) return;
      updated = [..._activities, activity];
      selectedIndex = updated.length - 1;
    } else {
      updated = [..._activities]..[editingIndex] = activity;
      selectedIndex = _selectedIndex;
    }
    await widget.repository?.saveActivities(
      updated,
      selectedIndex: selectedIndex,
    );
    if (!mounted) return;
    setState(() {
      _activities = updated;
      _selectedIndex = selectedIndex;
      _isCreating = false;
      _editingIndex = null;
      if (editingIndex == null) _showTutorial = updated.length == 1;
    });
  }

  Future<void> _selectActivity(int index) async {
    if (index == _selectedIndex) return;
    setState(() {
      _selectedIndex = index;
      _showTutorial = false;
    });
    await widget.repository?.saveSelectedActivityIndex(index);
  }

  void _openCreation() {
    if (!_canAddActivity) return;
    setState(() {
      _editingIndex = null;
      _isCreating = true;
    });
  }

  void _openEditing(int index) {
    setState(() {
      _editingIndex = index;
      _isCreating = true;
    });
  }

  void _cancelActivityForm() {
    setState(() {
      _editingIndex = null;
      _isCreating = false;
    });
  }

  Future<void> _showActivityMenu(BuildContext anchorContext, int index) async {
    final anchor = anchorContext.findRenderObject()! as RenderBox;
    final origin = anchor.localToGlobal(Offset.zero);
    final screen = MediaQuery.sizeOf(context);
    final action = await showMenu<_ActivityMenuAction>(
      context: context,
      color: appContextMenuColor,
      surfaceTintColor: Colors.transparent,
      elevation: 16,
      shadowColor: appContextMenuShadowColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(appContextMenuRadius),
        side: const BorderSide(color: appContextMenuBorderColor, width: 1.2),
      ),
      clipBehavior: Clip.antiAlias,
      menuPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
      constraints: const BoxConstraints(minWidth: 144, maxWidth: 176),
      position: RelativeRect.fromLTRB(
        origin.dx,
        origin.dy + anchor.size.height,
        screen.width - origin.dx - anchor.size.width,
        screen.height - origin.dy,
      ),
      items: const [
        PopupMenuItem(
          height: 42,
          padding: EdgeInsets.symmetric(horizontal: 10),
          value: _ActivityMenuAction.edit,
          child: Row(
            children: [
              Icon(Icons.edit_outlined, size: 18, color: appInkColor),
              SizedBox(width: 10),
              Text('Edit', style: TextStyle(color: appInkColor)),
            ],
          ),
        ),
        PopupMenuItem(
          height: 42,
          padding: EdgeInsets.symmetric(horizontal: 10),
          value: _ActivityMenuAction.delete,
          child: Row(
            children: [
              Icon(
                Icons.delete_outline,
                size: 18,
                color: appDestructiveActionColor,
              ),
              SizedBox(width: 10),
              Text(
                'Delete',
                style: TextStyle(color: appDestructiveActionColor),
              ),
            ],
          ),
        ),
      ],
    );
    if (!mounted || action == null) return;
    switch (action) {
      case _ActivityMenuAction.edit:
        _openEditing(index);
        break;
      case _ActivityMenuAction.delete:
        await _confirmDeleteActivity(index);
        break;
    }
  }

  Future<void> _confirmDeleteActivity(int index) async {
    final activity = _activities[index];
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete activity?'),
        content: Text('Delete “${activity.name}” from your activities?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            key: ActivitiesScreen.deleteConfirmButtonKey,
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (!mounted || shouldDelete != true) return;

    final updated = [..._activities]..removeAt(index);
    final nextSelectedIndex = updated.isEmpty
        ? 0
        : index < _selectedIndex
        ? _selectedIndex - 1
        : index == _selectedIndex
        ? math.min(index, updated.length - 1).toInt()
        : _selectedIndex;
    await widget.repository?.saveActivities(
      updated,
      selectedIndex: nextSelectedIndex,
    );
    if (!mounted) return;
    setState(() {
      _activities = updated;
      _selectedIndex = nextSelectedIndex;
      _showTutorial = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).height < 700;
    final canNavigateBack = Navigator.of(context).canPop();
    final isPopulated = _activities.isNotEmpty;

    return PopScope<void>(
      canPop: !_isCreating,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _isCreating) setState(() => _isCreating = false);
      },
      child: Scaffold(
        key: ActivitiesScreen.screenKey,
        body: Stack(
          fit: StackFit.expand,
          children: [
            if (isPopulated)
              PopulatedActivitiesView(
                activities: _activities,
                selectedIndex: _selectedIndex,
                showTutorial: widget.showTutorial || _showTutorial,
                timerController: _timerController,
                onSelectActivity: _selectActivity,
                onLongPressActivity: _showActivityMenu,
                onAddActivity: _canAddActivity ? _openCreation : null,
                showAddActivity:
                    _activities.length < ActivitiesScreen.maxActivities,
              )
            else
              _emptyState(compact, canNavigateBack),
            if (_isCreating && widget.repository != null) ...[
              ModalBarrier(
                key: ActivitiesScreen.createOverlayKey,
                color: Colors.black.withValues(alpha: 0.24),
                dismissible: false,
              ),
              CreateActivityScreen(
                initialActivity: _editingIndex == null
                    ? null
                    : _activities[_editingIndex!],
                onCancel: _cancelActivityForm,
                onSaved: _saveActivity,
              ),
            ],
          ],
        ),
      ),
    );
  }

  bool get _canAddActivity =>
      widget.repository != null &&
      _activities.length < ActivitiesScreen.maxActivities;

  Widget _emptyState(bool compact, bool canNavigateBack) {
    return Stack(
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
                if (_canAddActivity)
                  ActivityAddButton(
                    key: ActivitiesScreen.addButtonKey,
                    compact: compact,
                    onPressed: _openCreation,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _EphemeralDailyTimerRepository implements DailyTimerRepository {
  DailyTimerData _data = const DailyTimerData();

  @override
  Future<DailyTimerData> load() async => _data;

  @override
  Future<void> save(DailyTimerData data) async => _data = data;
}
