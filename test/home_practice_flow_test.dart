import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tenk/features/activities/domain/models/first_activity.dart';
import 'package:tenk/features/timer/domain/controllers/daily_timer_controller.dart';
import 'package:tenk/features/timer/domain/models/daily_timer_data.dart';
import 'package:tenk/features/timer/domain/repositories/daily_timer_repository.dart';
import 'package:tenk/screens/activities/activities_screen.dart';
import 'package:tenk/screens/activities/widgets/activity_landmark.dart';
import 'package:tenk/ui/widgets/populated_activities_view.dart';
import 'package:tenk/ui/widgets/session_timer_widget.dart';

class _MemoryTimerRepository implements DailyTimerRepository {
  DailyTimerData data = const DailyTimerData();

  @override
  Future<DailyTimerData> load() async => data;

  @override
  Future<void> save(DailyTimerData data) async {
    this.data = data;
  }
}

String _dayKey(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

void main() {
  Future<void> pumpActivities(
    WidgetTester tester, {
    bool showTutorial = true,
    List<FirstActivity>? activities,
    DailyTimerController? timerController,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ActivitiesScreen(
          activities: activities ?? const [],
          activityName: activities == null ? 'Гитара' : null,
          timerController: timerController,
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

  testWidgets(
    'each timer moves with its activity page and restores that activity’s daily counter',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(400, 800);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      var now = DateTime(2026, 11, 16, 10);
      final repository = _MemoryTimerRepository()
        ..data = DailyTimerData(
          totals: {
            '2026-11-16': {
              'guitar': const Duration(minutes: 2).inMilliseconds,
              'piano': const Duration(minutes: 4).inMilliseconds,
            },
          },
        );
      final timer = DailyTimerController(
        repository: repository,
        clock: () => now,
      );
      addTearDown(timer.dispose);
      await timer.load();
      await timer.start('guitar');
      now = now.add(const Duration(seconds: 8));
      await pumpActivities(
        tester,
        showTutorial: false,
        timerController: timer,
        activities: const [
          FirstActivity(id: 'guitar', name: 'Guitar', iconId: 'instrument'),
          FirstActivity(id: 'piano', name: 'Piano', iconId: 'music'),
        ],
      );
      final guitarPage = find.byKey(const ValueKey('activities_timer_guitar'));
      final guitarButton = find.descendant(
        of: guitarPage,
        matching: find.byType(FilledButton),
      );
      final originalButtonRect = tester.getRect(guitarButton);
      final originalX = originalButtonRect.center.dx;
      expect(find.text('02:08'), findsOneWidget);
      final gesture = await tester.startGesture(originalButtonRect.center);
      // Cross the drag threshold before measuring a live page displacement.
      await gesture.moveBy(const Offset(-20, 0));
      await gesture.moveBy(const Offset(-120, 0));
      await tester.pump();
      expect(tester.getCenter(guitarPage).dx, lessThan(originalX - 50));
      expect(tester.getCenter(guitarButton).dx, lessThan(originalX - 50));
      await gesture.moveBy(const Offset(-200, 0));
      await gesture.up();
      await tester.pumpAndSettle();
      final pianoPage = find.byKey(const ValueKey('activities_timer_piano'));
      final pianoVisual = tester.widget<SessionTimerWidget>(
        find.descendant(
          of: pianoPage,
          matching: find.byType(SessionTimerWidget),
        ),
      );
      expect(pianoVisual.running, isFalse);
      expect(pianoVisual.onPressed, isNull);
      expect(pianoVisual.dailyElapsed, const Duration(minutes: 4));
      expect(pianoVisual.weeklyProgress, closeTo(4 / 180, 0.00001));
      expect(timer.activeActivityId, 'guitar');
      await tester.tap(
        find.byKey(const ValueKey('activities_selector_item_0')),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 180));
      final pianoButton = find.descendant(
        of: pianoPage,
        matching: find.byType(FilledButton),
      );
      expect(tester.getCenter(pianoButton).dx, greaterThan(originalX + 50));
      expect(tester.getCenter(guitarButton).dx, lessThan(originalX - 50));
      await tester.pumpAndSettle();
      expect(find.text('02:08'), findsOneWidget);
      final guitarVisual = tester.widget<SessionTimerWidget>(
        find.descendant(
          of: guitarPage,
          matching: find.byType(SessionTimerWidget),
        ),
      );
      expect(guitarVisual.running, isTrue);
      expect(guitarVisual.dailyElapsed, const Duration(minutes: 2, seconds: 8));
      await tester.pumpWidget(const SizedBox.shrink());
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
    final timer = DailyTimerController(
      repository: _MemoryTimerRepository()
        ..data = DailyTimerData(
          totals: {
            for (var offset = 0; offset < 30; offset++)
              _dayKey(DateTime(2026, 11, 4).subtract(Duration(days: offset))): {
                'guitar': const Duration(minutes: 45).inMilliseconds,
              },
          },
        ),
      clock: () => DateTime(2026, 11, 4),
    );
    addTearDown(timer.dispose);
    await timer.load();
    try {
      await pumpActivities(
        tester,
        showTutorial: false,
        activities: const [
          FirstActivity(
            name: 'Гитара',
            iconId: 'instrument',
            id: 'guitar',
            initialMinutes: 300,
          ),
        ],
        timerController: timer,
      );

      expect(find.text('Гитара'), findsOneWidget);
      expect(find.text('TENK'), findsNothing);
      expect(find.text('to your goal'), findsOneWidget);
      expect(find.text('Total · 27h 30m'), findsOneWidget);
      expect(find.text('This week · 2h 15m / 3h'), findsOneWidget);
      expect(find.text('30 days'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(
        find.text('Every hour brings you closer\nto mastery.'),
        findsNothing,
      );
      expect(find.bySemanticsLabel('100 hours'), findsOneWidget);
      expect(find.byIcon(Icons.library_music), findsAtLeastNWidgets(1));
      expect(
        find.byKey(const ValueKey('activities_selector_item_0')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('activities_finish_anchor_0')),
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

  testWidgets('Activities hides the goal estimate without recent practice', (
    tester,
  ) async {
    final timer = DailyTimerController(
      repository: _MemoryTimerRepository(),
      clock: () => DateTime(2026, 11, 4),
    );
    addTearDown(timer.dispose);
    await timer.load();
    await pumpActivities(
      tester,
      showTutorial: false,
      activities: const [
        FirstActivity(
          name: 'Гитара',
          iconId: 'instrument',
          id: 'guitar',
          initialMinutes: 300,
        ),
      ],
      timerController: timer,
    );

    expect(find.text('Total · 5h'), findsOneWidget);
    expect(find.text('This week · 0m / 3h'), findsOneWidget);
    expect(find.byKey(PopulatedActivitiesView.etaKey), findsNothing);
  });

  testWidgets('Activities uses the shorter history for a new activity', (
    tester,
  ) async {
    final timer = DailyTimerController(
      repository: _MemoryTimerRepository()
        ..data = DailyTimerData(
          totals: {
            '2026-11-01': {'guitar': const Duration(hours: 1).inMilliseconds},
            '2026-11-04': {'guitar': const Duration(hours: 1).inMilliseconds},
          },
        ),
      clock: () => DateTime(2026, 11, 4),
    );
    addTearDown(timer.dispose);
    await timer.load();
    await pumpActivities(
      tester,
      showTutorial: false,
      activities: const [
        FirstActivity(name: 'Гитара', iconId: 'instrument', id: 'guitar'),
      ],
      timerController: timer,
    );

    expect(find.text('Total · 2h'), findsOneWidget);
    expect(find.text('This week · 1h / 3h'), findsOneWidget);
    expect(find.text('16 days'), findsOneWidget);
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
      final finishSlotRect = tester.getRect(
        find.byKey(const ValueKey('activities_finish_anchor_0')),
      );
      expect(islandSize, const Size(320, 568));
      expect(finishSlotRect.center.dx, closeTo(160, 1));
      expect(finishSlotRect.bottom, closeTo(177.3333, 1));
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
