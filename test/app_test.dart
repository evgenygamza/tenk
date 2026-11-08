import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:tenk/app/app_theme.dart';
import 'package:tenk/app/app.dart';
import 'package:tenk/features/activities/domain/models/first_activity.dart';
import 'package:tenk/features/activities/domain/repositories/first_activity_repository.dart';
import 'package:tenk/features/timer/domain/models/daily_timer_data.dart';
import 'package:tenk/features/timer/domain/repositories/daily_timer_repository.dart';
import 'package:tenk/screens/activities/activities_screen.dart';
import 'package:tenk/features/activities/presentation/create_activity_screen.dart';
import 'package:tenk/ui/widgets/populated_activities_view.dart';
import 'package:tenk/screens/welcome/welcome_screen.dart';
import 'package:tenk/ui/widgets/active_timer_geo_widget.dart';

class _Repository implements FirstActivityRepository {
  List<FirstActivity> activities = [];
  int selectedIndex = 0;
  FirstActivity? get activity => activities.isEmpty ? null : activities.first;
  set activity(FirstActivity? value) =>
      activities = value == null ? [] : [value];
  int loads = 0;
  bool fail = false;
  Completer<List<FirstActivity>>? pending;

  @override
  Future<List<FirstActivity>> loadActivities() async {
    loads++;
    if (fail) throw Exception('read failed');
    return pending == null ? activities : pending!.future;
  }

  @override
  Future<void> saveActivities(
    List<FirstActivity> activities, {
    int? selectedIndex,
  }) async {
    this.activities = List.of(activities);
    this.selectedIndex =
        selectedIndex ?? (activities.isEmpty ? 0 : activities.length - 1);
  }

  @override
  Future<int> loadSelectedActivityIndex() async => selectedIndex;

  @override
  Future<void> saveSelectedActivityIndex(int index) async =>
      selectedIndex = index;
}

class _TimerRepository implements DailyTimerRepository {
  DailyTimerData data;

  _TimerRepository(this.data);

  @override
  Future<DailyTimerData> load() async => data;

  @override
  Future<void> save(DailyTimerData data) async {
    this.data = data;
  }
}

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  tearDown(() {
    SharedPreferencesAsyncPlatform.instance = null;
  });

  testWidgets('first launch opens Welcome and empty activities', (
    tester,
  ) async {
    final repository = _Repository();
    await tester.pumpWidget(App(firstActivityRepository: repository));
    await tester.pumpAndSettle();
    expect(find.byType(WelcomeScreen), findsOneWidget);
    await tester.tap(find.byKey(WelcomeScreen.startButtonKey));
    await tester.pumpAndSettle();
    expect(find.byType(ActivitiesScreen), findsOneWidget);
    expect(find.byKey(ActivitiesScreen.emptyStateKey), findsOneWidget);
    expect(find.byType(CreateActivityScreen), findsNothing);
    expect(repository.loads, 1);
  });

  testWidgets('empty Activities opens and cancels the embedded form', (
    tester,
  ) async {
    final repository = _Repository();
    await tester.pumpWidget(App(firstActivityRepository: repository));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(WelcomeScreen.startButtonKey));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(ActivitiesScreen.addButtonKey));
    await tester.pumpAndSettle();

    expect(find.byType(ActivitiesScreen), findsOneWidget);
    expect(find.byType(CreateActivityScreen), findsOneWidget);
    expect(find.byKey(ActivitiesScreen.createOverlayKey), findsOneWidget);
    expect(repository.activity, isNull);

    await tester.tap(find.byKey(CreateActivityScreen.cancelButtonKey));
    await tester.pumpAndSettle();
    expect(find.byKey(ActivitiesScreen.emptyStateKey), findsOneWidget);
    expect(find.byType(CreateActivityScreen), findsNothing);
  });

  testWidgets(
    'system back cancels the embedded form before leaving Activities',
    (tester) async {
      await tester.pumpWidget(App(firstActivityRepository: _Repository()));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(WelcomeScreen.startButtonKey));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(ActivitiesScreen.addButtonKey));
      await tester.pumpAndSettle();

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.byType(CreateActivityScreen), findsNothing);
      expect(find.byKey(ActivitiesScreen.emptyStateKey), findsOneWidget);
    },
  );

  testWidgets('waits for loading without flashing onboarding', (tester) async {
    final repository = _Repository()
      ..pending = Completer<List<FirstActivity>>();
    await tester.pumpWidget(App(firstActivityRepository: repository));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(WelcomeScreen), findsNothing);
    repository.pending!.complete([
      const FirstActivity(name: 'Гитара', iconId: 'instrument'),
    ]);
    await tester.pumpAndSettle();
    expect(find.byType(PopulatedActivitiesView), findsOneWidget);
    expect(find.text('Гитара'), findsOneWidget);
    await tester.pump();
    expect(repository.loads, 1);
  });

  testWidgets('saved activity survives an app restart', (tester) async {
    final repository = _Repository();
    await tester.pumpWidget(App(firstActivityRepository: repository));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(WelcomeScreen.startButtonKey));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(ActivitiesScreen.addButtonKey));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(CreateActivityScreen.nameFieldKey),
      'Гитара',
    );
    await tester.tap(
      find.byKey(const ValueKey('create_activity_icon_instrument')),
    );
    final saveButton = find.byKey(CreateActivityScreen.saveButtonKey);
    await tester.ensureVisible(saveButton);
    await tester.pumpAndSettle();
    await tester.tap(saveButton);
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(App(firstActivityRepository: repository));
    await tester.pumpAndSettle();
    expect(find.byType(PopulatedActivitiesView), findsOneWidget);
    expect(find.text('Гитара'), findsOneWidget);
    expect(find.byIcon(Icons.library_music), findsAtLeastNWidgets(1));
    expect(find.byType(WelcomeScreen), findsNothing);
    expect(
      tester.state<NavigatorState>(find.byType(Navigator)).canPop(),
      isFalse,
    );
    expect(repository.loads, 2);
  });

  testWidgets('filled Activities adds, switches, and restores activities', (
    tester,
  ) async {
    final repository = _Repository()
      ..activities = [
        const FirstActivity(name: 'Гитара', iconId: 'instrument'),
      ];
    await tester.pumpWidget(App(firstActivityRepository: repository));
    await tester.pumpAndSettle();
    expect(find.text('Гитара'), findsOneWidget);

    await tester.tap(find.byKey(PopulatedActivitiesView.addActivityVisualKey));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(CreateActivityScreen.nameFieldKey),
      'Пианино',
    );
    final saveButton = find.byKey(CreateActivityScreen.saveButtonKey);
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(repository.activities, hasLength(2));
    expect(find.text('Пианино'), findsOneWidget);

    final panoramaRect = tester.getRect(
      find.byKey(PopulatedActivitiesView.panoramaPageViewKey),
    );
    await tester.dragFrom(
      Offset(panoramaRect.left + 50, panoramaRect.center.dy),
      Offset(panoramaRect.width * 0.75, 0),
    );
    await tester.pumpAndSettle();
    expect(find.text('Гитара'), findsOneWidget);
    expect(repository.selectedIndex, 0);

    await tester.dragFrom(
      Offset(panoramaRect.right - 50, panoramaRect.center.dy),
      Offset(-panoramaRect.width * 0.75, 0),
    );
    await tester.pumpAndSettle();
    expect(find.text('Пианино'), findsOneWidget);
    expect(repository.selectedIndex, 1);

    await tester.tap(find.byKey(const ValueKey('activities_selector_item_0')));
    await tester.pumpAndSettle();
    expect(find.text('Гитара'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('activities_selector_item_1')));
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(App(firstActivityRepository: repository));
    await tester.pumpAndSettle();
    expect(find.text('Пианино'), findsOneWidget);
    expect(repository.selectedIndex, 1);
  });

  testWidgets(
    'active timer widget stays above the form and returns to its activity',
    (tester) async {
      final repository = _Repository()
        ..activities = [
          const FirstActivity(id: 'activity-1', name: 'Music', iconId: 'music'),
          const FirstActivity(
            id: 'activity-2',
            name: 'English',
            iconId: 'running',
          ),
        ]
        ..selectedIndex = 1;
      final timerRepository = _TimerRepository(
        DailyTimerData(
          activeActivityId: 'activity-1',
          runningSinceMilliseconds: DateTime(
            2026,
            11,
            5,
            10,
          ).millisecondsSinceEpoch,
        ),
      );
      await tester.pumpWidget(
        App(
          firstActivityRepository: repository,
          dailyTimerRepository: timerRepository,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(WelcomeScreen), findsNothing);
      expect(find.byKey(ActiveTimerGeoWidget.widgetKey), findsOneWidget);
      expect(find.text('English'), findsOneWidget);

      await tester.tap(
        find.byKey(PopulatedActivitiesView.addActivityVisualKey),
      );
      await tester.pumpAndSettle();
      expect(find.byType(CreateActivityScreen), findsOneWidget);
      expect(find.byKey(ActiveTimerGeoWidget.widgetKey), findsOneWidget);

      await tester.tap(find.byKey(CreateActivityScreen.cancelButtonKey));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(ActiveTimerGeoWidget.widgetKey));
      await tester.pumpAndSettle();

      expect(find.text('Music'), findsOneWidget);
      expect(find.byKey(ActiveTimerGeoWidget.widgetKey), findsNothing);
      expect(find.byType(CreateActivityScreen), findsNothing);
      expect(timerRepository.data.activeActivityId, 'activity-1');
    },
  );

  testWidgets('activity finish content is built from its activity', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(393, 852);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    const activities = [
      FirstActivity(id: 'guitar', name: 'Гитара', iconId: 'instrument'),
      FirstActivity(id: 'music', name: 'Пианино', iconId: 'music'),
    ];
    await tester.pumpWidget(
      MaterialApp(
        home: ActivitiesScreen(
          activities: activities,
          selectedIndex: 1,
          activityFinishBuilder: (context, activity) => Text(
            'Finish for ${activity.name}',
            key: ValueKey('generated_activity_finish_${activity.id}'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Finish for Пианино'), findsOneWidget);
    final finishRect = tester.getRect(
      find.byKey(const ValueKey('generated_activity_finish_music')),
    );
    final finishSlotRect = tester.getRect(
      find.byKey(const ValueKey('activities_finish_anchor_1')),
    );
    final viewportRect = tester.getRect(
      find.byKey(PopulatedActivitiesView.panoramaPageViewKey),
    );
    expect(finishRect.center.dx, closeTo(finishSlotRect.center.dx, 1));
    expect(finishRect.bottom, closeTo(finishSlotRect.bottom, 1));
    expect(finishSlotRect.center.dx, closeTo(viewportRect.center.dx, 1));
    expect(
      finishSlotRect.bottom,
      closeTo(viewportRect.top + viewportRect.height * 920 / 2600, 1),
    );
  });

  testWidgets('panorama crosses the sea between activity frames', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(393, 852);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    final repository = _Repository()
      ..activities = [
        const FirstActivity(name: 'Music', iconId: 'music'),
        const FirstActivity(name: 'Reading', iconId: 'reading'),
      ];
    await tester.pumpWidget(App(firstActivityRepository: repository));
    await tester.pumpAndSettle();

    final artwork = find.byKey(PopulatedActivitiesView.panoramaArtworkKey);
    final viewport = tester.getRect(
      find.byKey(PopulatedActivitiesView.panoramaPageViewKey),
    );
    final firstArtwork = tester.getRect(artwork);
    final sourcePixelScale = firstArtwork.width / 8400;
    expect(
      firstArtwork.left + 900 * sourcePixelScale,
      closeTo(viewport.center.dx, 1),
    );

    await tester.tap(find.byKey(const ValueKey('activities_selector_item_1')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 180));

    final middleArtwork = tester.getRect(artwork);
    final middleCameraSourceX =
        (viewport.center.dx - middleArtwork.left) / sourcePixelScale;
    expect(middleCameraSourceX, allOf(greaterThan(1500), lessThan(1970)));
    expect(middleArtwork.top, closeTo(firstArtwork.top, 0.01));
    expect(middleArtwork.size, firstArtwork.size);
    expect(
      find.byKey(const ValueKey('activities_finish_anchor_0')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('activities_finish_anchor_1')),
      findsNothing,
    );

    await tester.pumpAndSettle();
    final secondArtwork = tester.getRect(artwork);
    expect(
      secondArtwork.left + 2570 * sourcePixelScale,
      closeTo(viewport.center.dx, 1),
    );
    expect(firstArtwork.left - secondArtwork.left, greaterThan(viewport.width));
    expect(secondArtwork.top, closeTo(firstArtwork.top, 0.01));
    final secondFinish = tester.getRect(
      find.byKey(const ValueKey('activities_finish_anchor_1')),
    );
    expect(secondFinish.center.dx, closeTo(viewport.center.dx, 1));
    expect(
      secondFinish.bottom,
      closeTo(secondArtwork.top + 920 * sourcePixelScale, 1),
    );
    expect(repository.selectedIndex, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('hides add control when five activities are saved', (
    tester,
  ) async {
    final repository = _Repository()
      ..activities = List.generate(
        ActivitiesScreen.maxActivities,
        (index) => FirstActivity(name: 'Activity $index', iconId: 'instrument'),
      );
    await tester.pumpWidget(App(firstActivityRepository: repository));
    await tester.pumpAndSettle();

    expect(
      find.byKey(PopulatedActivitiesView.activitySelectorKey),
      findsOneWidget,
    );
    expect(
      find.byKey(PopulatedActivitiesView.addActivityVisualKey),
      findsNothing,
    );

    await tester.tap(find.byKey(const ValueKey('activities_selector_item_4')));
    await tester.pumpAndSettle();
    expect(repository.selectedIndex, 4);
    final pageController = tester
        .widget<PageView>(
          find.byKey(PopulatedActivitiesView.panoramaPageViewKey),
        )
        .controller!;
    expect(pageController.page, 4);

    final panoramaRect = tester.getRect(
      find.byKey(PopulatedActivitiesView.panoramaPageViewKey),
    );
    await tester.dragFrom(
      Offset(panoramaRect.right - 50, panoramaRect.center.dy),
      Offset(-panoramaRect.width * 0.75, 0),
    );
    await tester.pumpAndSettle();
    expect(repository.selectedIndex, 4);
    expect(pageController.page, 4);
  });

  testWidgets('long press edits the selected activity in place', (
    tester,
  ) async {
    final repository = _Repository()
      ..activities = [
        const FirstActivity(name: 'Гитара', iconId: 'instrument'),
        const FirstActivity(name: 'Пианино', iconId: 'music'),
      ]
      ..selectedIndex = 1;
    await tester.pumpWidget(App(firstActivityRepository: repository));
    await tester.pumpAndSettle();

    await tester.longPress(
      find.byKey(const ValueKey('activities_selector_item_1')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    expect(find.text('Edit activity'), findsOneWidget);
    final nameField = tester.widget<TextField>(
      find.byKey(CreateActivityScreen.nameFieldKey),
    );
    expect(nameField.controller!.text, 'Пианино');
    await tester.enterText(
      find.byKey(CreateActivityScreen.nameFieldKey),
      'Электропиано',
    );
    final saveButton = find.byKey(CreateActivityScreen.saveButtonKey);
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(repository.activities, [
      const FirstActivity(name: 'Гитара', iconId: 'instrument'),
      const FirstActivity(name: 'Электропиано', iconId: 'music'),
    ]);
    expect(repository.selectedIndex, 1);
  });

  testWidgets('long-press menu matches the Activities glass design', (
    tester,
  ) async {
    final repository = _Repository()
      ..activities = [
        const FirstActivity(name: 'Гитара', iconId: 'instrument'),
      ];
    await tester.pumpWidget(App(firstActivityRepository: repository));
    await tester.pumpAndSettle();

    await tester.longPress(
      find.byKey(const ValueKey('activities_selector_item_0')),
    );
    await tester.pumpAndSettle();

    final menuPanels = tester
        .widgetList<Material>(find.byType(Material))
        .where((material) => material.color == appContextMenuColor)
        .toList();
    expect(menuPanels, hasLength(1));
    expect(menuPanels.single.elevation, 16);
    expect(menuPanels.single.shape, isA<RoundedRectangleBorder>());
    expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline), findsOneWidget);
  });

  testWidgets('long press deletes an activity after confirmation', (
    tester,
  ) async {
    final repository = _Repository()
      ..activities = [
        const FirstActivity(name: 'Гитара', iconId: 'instrument'),
        const FirstActivity(name: 'Пианино', iconId: 'music'),
      ]
      ..selectedIndex = 1;
    await tester.pumpWidget(App(firstActivityRepository: repository));
    await tester.pumpAndSettle();

    await tester.longPress(
      find.byKey(const ValueKey('activities_selector_item_0')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(repository.activities, hasLength(2));

    await tester.longPress(
      find.byKey(const ValueKey('activities_selector_item_0')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(ActivitiesScreen.deleteConfirmButtonKey));
    await tester.pumpAndSettle();

    expect(repository.activities, [
      const FirstActivity(name: 'Пианино', iconId: 'music'),
    ]);
    expect(repository.selectedIndex, 0);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(App(firstActivityRepository: repository));
    await tester.pumpAndSettle();
    expect(find.text('Пианино'), findsOneWidget);
    expect(repository.selectedIndex, 0);

    await tester.longPress(
      find.byKey(const ValueKey('activities_selector_item_0')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(ActivitiesScreen.deleteConfirmButtonKey));
    await tester.pumpAndSettle();
    expect(repository.activities, isEmpty);
    expect(find.byKey(ActivitiesScreen.emptyStateKey), findsOneWidget);
  });

  testWidgets('blank stored name keeps creation accessible', (tester) async {
    await tester.pumpWidget(
      App(
        firstActivityRepository: _Repository()
          ..activity = const FirstActivity(name: '  ', iconId: 'sparkles'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(WelcomeScreen), findsOneWidget);
  });

  testWidgets('load failure allows retry without losing saved activity', (
    tester,
  ) async {
    final repository = _Repository()
      ..activity = const FirstActivity(name: 'Рисование', iconId: 'art')
      ..fail = true;
    await tester.pumpWidget(App(firstActivityRepository: repository));
    await tester.pumpAndSettle();
    expect(find.text('Could not load your activity'), findsOneWidget);
    expect(find.byType(WelcomeScreen), findsNothing);
    expect(find.byType(PopulatedActivitiesView), findsNothing);
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.text('Could not load your activity'), findsOneWidget);
    repository.fail = false;
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.text('Рисование'), findsOneWidget);
    expect(find.byType(PopulatedActivitiesView), findsOneWidget);
    expect(repository.loads, 3);
    expect(tester.takeException(), isNull);
  });

  testWidgets('load retry can resolve to Welcome', (tester) async {
    final repository = _Repository()..fail = true;
    await tester.pumpWidget(App(firstActivityRepository: repository));
    await tester.pumpAndSettle();
    repository.fail = false;
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.byType(WelcomeScreen), findsOneWidget);
  });

  testWidgets(
    'Activities displays a long activity on a small screen with large text',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 568);
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      const name = 'Рисование и изучение пейзажей';
      await tester.pumpWidget(
        App(
          firstActivityRepository: _Repository()
            ..activity = FirstActivity(name: name, iconId: 'art'),
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text(name));
      expect(find.text(name), findsOneWidget);
      expect(find.byType(PopulatedActivitiesView), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
