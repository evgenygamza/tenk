import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tenk/features/activities/domain/models/activity.dart';
import 'package:tenk/features/activities/presentation/state/activities_controller.dart';
import 'package:tenk/features/sessions/domain/models/session_entry.dart';
import 'package:tenk/features/sessions/presentation/screens/activity_details/activity_details_screen.dart';
import 'package:tenk/features/sessions/presentation/screens/dashboard_screen.dart';
import 'package:tenk/features/sessions/presentation/screens/history_screen.dart';
import 'package:tenk/features/sessions/presentation/screens/activity_details/activity_details_utils.dart';
import 'package:tenk/features/sessions/presentation/state/sessions_controller.dart';
import 'package:tenk/features/sessions/presentation/widgets/activity_details/activity_entries_chart.dart';
import 'package:tenk/features/timer/presentation/state/timer_controller.dart';
import 'package:tenk/features/timer/presentation/state/timer_storage.dart';
import 'package:tenk/ui/progress_bar.dart';

import 'fakes/fake_activities_repository.dart';
import 'fakes/fake_sessions_repository.dart';

void main() {
  late FakeActivitiesRepository repo;
  late ActivitiesController activities;
  late SessionsController sessions;
  late TimerController timer;

  setUp(() async {
    repo = FakeActivitiesRepository(
      seed: const [
        Activity(id: 'guitar', title: 'Guitar', colorIndex: 0),
        Activity(id: 'piano', title: 'Piano', colorIndex: 1),
      ],
    );
    activities = ActivitiesController(repo);
    sessions = SessionsController(
      FakeSessionsRepository(
        seed: [
          SessionEntry(
            id: 'session',
            activityId: 'guitar',
            startedAt: DateTime.now(),
            minutes: 30,
          ),
        ],
      ),
    );
    timer = TimerController(TimerStorage());
    await Future<void>.delayed(Duration.zero);
  });

  tearDown(() {
    activities.dispose();
    sessions.dispose();
    timer.dispose();
  });

  Widget app(Widget home) => MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: activities),
      ChangeNotifierProvider.value(value: sessions),
      ChangeNotifierProvider.value(value: timer),
    ],
    child: MaterialApp(home: home),
  );

  Future<void> openMenu(WidgetTester tester) async {
    await tester.tap(find.byTooltip('Show menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Existing experience…'));
    await tester.pumpAndSettle();
  }

  Future<void> enter(WidgetTester tester, String label, String value) async {
    final field = find.byKey(ValueKey(label));
    await tester.ensureVisible(field);
    await tester.enterText(field, value);
    await tester.pumpAndSettle();
  }

  Future<void> save(WidgetTester tester) async {
    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'menu saves prior experience; progress updates across screens without changing session stats',
    (tester) async {
      await tester.pumpWidget(app(const DashboardScreen()));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Guitar'));
      await tester.pumpAndSettle();
      await openMenu(tester);
      await enter(tester, 'Years', '1');
      await enter(tester, 'Hours per week', '10');
      await save(tester);

      expect(activities.activities.first.initialMinutes, 31284);
      expect((await repo.getActivities()).first.initialMinutes, 31284);
      expect(find.text('Existing experience: 521h 24m'), findsOneWidget);
      expect(find.text('521h 54m'), findsOneWidget);
      expect(find.text('Today: 30m'), findsOneWidget);
      expect(find.text('30m'), findsOneWidget);
      expect(find.text('1m/d'), findsOneWidget);
      expect(find.text('28686 days'), findsOneWidget);
      expect(sessions.entries.length, 1);
      expect(sessions.totalMinutesToday('guitar'), 30);
      expect(
        ActivityDetailsAggregate.minutesThisWeek(
          entries: sessions.entries,
          activityId: 'guitar',
        ),
        30,
      );
      expect(
        ActivityDetailsAggregate.minutesLastNDays(
          entries: sessions.entries,
          activityId: 'guitar',
          days: 30,
        ),
        30,
      );

      await tester.ensureVisible(find.byType(ActivityEntriesChart));
      final chart = tester.widget<ActivityEntriesChart>(
        find.byType(ActivityEntriesChart),
      );
      expect(chart.daily.fold<int>(0, (sum, bar) => sum + bar.minutes), 30);
      expect(chart.monthly.fold<int>(0, (sum, bar) => sum + bar.minutes), 30);
      await tester.pageBack();
      await tester.pumpAndSettle();
      final progress = tester
          .widgetList<ProgressBar>(find.byType(ProgressBar))
          .toList();
      expect(progress[0].totalMinutesAllTime, 31314);
      expect(progress[1].totalMinutesAllTime, 0);

      await tester.pumpWidget(app(const HistoryScreen()));
      await tester.pumpAndSettle();
      expect(find.text('30 min'), findsOneWidget);
      expect(find.byType(ListTile), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'entries action shares the saved total; repeated save, cancel and clear do not duplicate experience',
    (tester) async {
      await activities.setInitialMinutes('guitar', 120);
      await tester.pumpWidget(
        app(const ActivityDetailsScreen(activityId: 'guitar')),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Existing experience'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Existing experience'));
      await tester.pumpAndSettle();
      expect(find.text('Current: 2h'), findsOneWidget);
      await save(tester);
      expect(activities.activities.first.initialMinutes, 120);
      expect(sessions.entries.length, 1);

      await openMenu(tester);
      await enter(tester, 'Hours', '3');
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(activities.activities.first.initialMinutes, 120);
      await openMenu(tester);
      await enter(tester, 'Hours', '3');
      await save(tester);
      expect(activities.activities.first.initialMinutes, 180);
      await openMenu(tester);
      await enter(tester, 'Hours', '0');
      await enter(tester, 'Minutes', '0');
      await save(tester);
      expect(activities.activities.first.initialMinutes, 0);
      expect(sessions.entries.single.minutes, 30);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'storage failure is visible and preserves the previous experience',
    (tester) async {
      await activities.setInitialMinutes('guitar', 60);
      repo.failSave = true;
      await tester.pumpWidget(
        app(const ActivityDetailsScreen(activityId: 'guitar')),
      );
      await tester.pumpAndSettle();
      await openMenu(tester);
      await enter(tester, 'Hours', '2');
      await save(tester);
      expect(
        find.text('Could not save experience. Please retry.'),
        findsOneWidget,
      );
      expect(activities.activities.first.initialMinutes, 60);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'completed final goal stays full, including experience above 10000 hours',
    (tester) async {
      for (final minutes in [600000, 700000]) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: ProgressBar(totalMinutesAllTime: minutes)),
          ),
        );
        expect(
          tester
              .widget<LinearProgressIndicator>(
                find.byType(LinearProgressIndicator),
              )
              .value,
          1,
        );
      }
    },
  );

  testWidgets(
    'prior experience without sessions does not invent a practice pace or ETA',
    (tester) async {
      await activities.setInitialMinutes('piano', 6000);
      await tester.pumpWidget(
        app(const ActivityDetailsScreen(activityId: 'piano')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Existing experience: 100h'), findsOneWidget);
      expect(find.text('100h'), findsOneWidget);
      expect(find.text('Today: 0m'), findsOneWidget);
      expect(find.text('0m/d'), findsOneWidget);
      expect(find.text('No data yet 👀'), findsOneWidget);
      expect(
        sessions.entries.where((entry) => entry.activityId == 'piano'),
        isEmpty,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
