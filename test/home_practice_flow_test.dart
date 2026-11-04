import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tenk/features/activities/domain/models/first_activity.dart';
import 'package:tenk/features/timer/domain/controllers/daily_timer_controller.dart';
import 'package:tenk/features/timer/domain/models/daily_timer_data.dart';
import 'package:tenk/features/timer/domain/repositories/daily_timer_repository.dart';
import 'package:tenk/screens/activities/activities_screen.dart';
import 'package:tenk/screens/activities/widgets/activity_island.dart';
import 'package:tenk/screens/activities/widgets/activity_landmark.dart';
import 'package:tenk/ui/widgets/populated_activities_view.dart';

class _MemoryTimerRepository implements DailyTimerRepository {
  DailyTimerData data = const DailyTimerData();

  @override
  Future<DailyTimerData> load() async => data;

  @override
  Future<void> save(DailyTimerData data) async {
    this.data = data;
  }
}

void main() {
  Future<void> pumpActivities(
    WidgetTester tester, {
    bool showTutorial = true,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ActivitiesScreen(
          activityName: 'Гитара',
          showTutorial: showTutorial,
        ),
      ),
    );
  }

  testWidgets('Activities shows a dismissible first-practice tutorial', (
    tester,
  ) async {
    await pumpActivities(tester);

    expect(find.byKey(PopulatedActivitiesView.tutorialKey), findsOneWidget);
    expect(
      find.text('Start tracking your first activity to begin your journey.'),
      findsOneWidget,
    );

    final dismissButton = find.byKey(
      PopulatedActivitiesView.dismissTutorialKey,
    );
    await tester.ensureVisible(dismissButton);
    await tester.tap(dismissButton);
    await tester.pumpAndSettle();

    expect(find.byKey(PopulatedActivitiesView.tutorialKey), findsNothing);
    expect(find.byKey(PopulatedActivitiesView.startSessionKey), findsOneWidget);
  });

  testWidgets('Activities timer starts and stops in place', (tester) async {
    await pumpActivities(tester, showTutorial: false);

    final timerButton = find.byKey(PopulatedActivitiesView.startSessionKey);
    await tester.tap(timerButton);
    await tester.pumpAndSettle();

    expect(find.byType(ActivitiesScreen), findsOneWidget);
    expect(find.byKey(ActivitiesScreen.screenKey), findsOneWidget);
    expect(find.text('Гитара'), findsOneWidget);
    expect(find.byIcon(Icons.pause_rounded), findsOneWidget);
    expect(find.byTooltip('Stop timer'), findsOneWidget);
    expect(find.text('00:00:00'), findsNothing);

    await tester.tap(timerButton);
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
    expect(find.byTooltip('Start timer'), findsOneWidget);
  });

  testWidgets(
    'switching activities while running disables the other timer button',
    (tester) async {
      final timer = DailyTimerController(
        repository: _MemoryTimerRepository(),
        clock: () => DateTime(2026, 11, 4, 10),
      );
      addTearDown(timer.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: ActivitiesScreen(
            activities: const [
              FirstActivity(name: 'Гитара', iconId: 'instrument', id: 'guitar'),
              FirstActivity(name: 'Пианино', iconId: 'music', id: 'piano'),
            ],
            timerController: timer,
            showTutorial: false,
          ),
        ),
      );

      await tester.tap(find.byKey(PopulatedActivitiesView.startSessionKey));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey('activities_selector_item_1')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Пианино'), findsOneWidget);
      expect(timer.status, DailyTimerStatus.running);
      expect(timer.activeActivityId, 'guitar');
      expect(
        find.byTooltip('Timer is active for another activity'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
      expect(
        tester
            .widget<FilledButton>(
              find.byKey(PopulatedActivitiesView.startSessionKey),
            )
            .onPressed,
        isNull,
      );
    },
  );

  testWidgets('stopping allows another activity timer to start', (
    tester,
  ) async {
    final repository = _MemoryTimerRepository();
    var now = DateTime(2026, 11, 4, 10);
    final timer = DailyTimerController(
      repository: repository,
      clock: () => now,
    );
    addTearDown(timer.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: ActivitiesScreen(
          activities: const [
            FirstActivity(name: 'Гитара', iconId: 'instrument', id: 'guitar'),
            FirstActivity(name: 'Пианино', iconId: 'music', id: 'piano'),
          ],
          timerController: timer,
          showTutorial: false,
        ),
      ),
    );

    final timerButton = find.byKey(PopulatedActivitiesView.startSessionKey);
    await tester.tap(timerButton);
    await tester.pumpAndSettle();
    now = now.add(const Duration(minutes: 2));
    await tester.tap(find.byKey(const ValueKey('activities_selector_item_1')));
    await tester.pumpAndSettle();

    expect(find.text('Пианино'), findsOneWidget);
    expect(
      find.byTooltip('Timer is active for another activity'),
      findsOneWidget,
    );
    expect(timer.status, DailyTimerStatus.running);
    expect(timer.activeActivityId, 'guitar');
    expect(
      tester
          .widget<FilledButton>(
            find.byKey(PopulatedActivitiesView.startSessionKey),
          )
          .onPressed,
      isNull,
    );
    expect(timer.totalFor('guitar'), const Duration(minutes: 2));

    await tester.tap(find.byKey(const ValueKey('activities_selector_item_0')));
    await tester.pumpAndSettle();
    await tester.tap(timerButton);
    await tester.pumpAndSettle();
    expect(timer.status, DailyTimerStatus.stopped);
    expect(timer.activeActivityId, isNull);
    expect(timer.totalFor('guitar'), const Duration(minutes: 2));

    await tester.tap(find.byKey(const ValueKey('activities_selector_item_1')));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Start timer'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(
            find.byKey(PopulatedActivitiesView.startSessionKey),
          )
          .onPressed,
      isNotNull,
    );
    await tester.tap(timerButton);
    await tester.pumpAndSettle();
    expect(timer.status, DailyTimerStatus.running);
    expect(timer.activeActivityId, 'piano');
  });

  testWidgets('long press opens activity menu while timer is running', (
    tester,
  ) async {
    final timer = DailyTimerController(
      repository: _MemoryTimerRepository(),
      clock: () => DateTime(2026, 11, 4, 10),
    );
    addTearDown(timer.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: ActivitiesScreen(
          activities: const [
            FirstActivity(name: 'Гитара', iconId: 'instrument', id: 'guitar'),
            FirstActivity(name: 'Пианино', iconId: 'music', id: 'piano'),
          ],
          timerController: timer,
          showTutorial: false,
        ),
      ),
    );

    await tester.tap(find.byKey(PopulatedActivitiesView.startSessionKey));
    await tester.pumpAndSettle();
    await tester.longPress(
      find.byKey(const ValueKey('activities_selector_item_1')),
    );
    await tester.pumpAndSettle();

    expect(timer.status, DailyTimerStatus.running);
    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
  });

  testWidgets('Activities shows the visual activity goal and selector', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    try {
      await pumpActivities(tester, showTutorial: false);

      expect(find.text('Гитара'), findsOneWidget);
      expect(find.text('TENK'), findsNothing);
      expect(find.bySemanticsLabel('100 hours'), findsOneWidget);
      expect(find.text('18 days to your goal'), findsOneWidget);
      expect(find.byIcon(Icons.library_music), findsAtLeastNWidgets(1));
      expect(
        find.byKey(const ValueKey('activities_selector_item_0')),
        findsOneWidget,
      );
      expect(find.byKey(ActivityLandmark.landmarkKey), findsOneWidget);
      expect(
        find.byKey(PopulatedActivitiesView.activitySelectorKey),
        findsOneWidget,
      );
      expect(
        find.byKey(PopulatedActivitiesView.addActivityVisualKey),
        findsOneWidget,
      );
      expect(
        find.byKey(PopulatedActivitiesView.startSessionKey),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('10,000-hour goal uses its dedicated landmark design', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    try {
      await tester.pumpWidget(
        const MaterialApp(
          home: Center(
            child: SizedBox(
              width: 180,
              height: 200,
              child: ActivityLandmark(hours: 10000),
            ),
          ),
        ),
      );

      expect(find.byKey(ActivityLandmark.landmarkKey), findsOneWidget);
      expect(find.bySemanticsLabel('10000 hours'), findsOneWidget);
    } finally {
      semantics.dispose();
    }
  });

  testWidgets(
    'Activities keeps the visual layout scrollable on a compact screen',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 568);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      await pumpActivities(tester, showTutorial: false);

      expect(find.byKey(PopulatedActivitiesView.goalKey), findsOneWidget);
      final islandSize = tester.getSize(
        find.byKey(PopulatedActivitiesView.goalKey),
      );
      final fitted = applyBoxFit(
        BoxFit.cover,
        ActivityIsland.artworkSize,
        islandSize,
      );
      final imageOffset = Offset(
        (islandSize.width - fitted.destination.width) / 2,
        (islandSize.height - fitted.destination.height) / 2,
      );
      final roadTip =
          imageOffset +
          Offset(
            fitted.destination.width * ActivityIsland.roadEndpointAnchor.dx,
            fitted.destination.height * ActivityIsland.roadEndpointAnchor.dy,
          );
      final landmarkRect = tester.getRect(
        find.byKey(ActivityLandmark.landmarkKey),
      );
      expect(landmarkRect.center.dx, closeTo(roadTip.dx, 1));
      expect(landmarkRect.bottom, closeTo(roadTip.dy, 1));
      await tester.ensureVisible(
        find.byKey(PopulatedActivitiesView.addActivityVisualKey),
      );
      expect(
        find.byKey(PopulatedActivitiesView.addActivityVisualKey),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
