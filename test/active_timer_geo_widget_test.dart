import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tenk/features/activities/domain/models/first_activity.dart';
import 'package:tenk/features/timer/domain/controllers/daily_timer_controller.dart';
import 'package:tenk/features/timer/domain/models/daily_timer_data.dart';
import 'package:tenk/features/timer/domain/repositories/daily_timer_repository.dart';
import 'package:tenk/ui/widgets/active_timer_geo_widget.dart';

class _MemoryDailyTimerRepository implements DailyTimerRepository {
  DailyTimerData data = const DailyTimerData();

  @override
  Future<DailyTimerData> load() async => data;

  @override
  Future<void> save(DailyTimerData data) async {
    this.data = data;
  }
}

void main() {
  const activities = [
    FirstActivity(id: 'left', name: 'Walking', iconId: 'running'),
    FirstActivity(id: 'right', name: 'Reading', iconId: 'reading'),
  ];

  Future<DailyTimerController> startTimer(String activityId) async {
    final controller = DailyTimerController(
      repository: _MemoryDailyTimerRepository(),
      clock: () => DateTime(2026, 11, 5, 10),
    );
    await controller.start(activityId);
    return controller;
  }

  Widget host(
    DailyTimerController controller, {
    int selectedIndex = 0,
    ValueChanged<FirstActivity>? onTap,
  }) => MaterialApp(
    home: Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const ColoredBox(color: Colors.blueGrey),
          Positioned.fill(
            child: ActiveTimerGeoWidget(
              activities: activities,
              selectedIndex: selectedIndex,
              timerController: controller,
              onTap: onTap ?? (_) {},
            ),
          ),
        ],
      ),
    ),
  );

  testWidgets('is hidden when the timer is stopped', (tester) async {
    final controller = DailyTimerController(
      repository: _MemoryDailyTimerRepository(),
    );
    await tester.pumpWidget(host(controller));

    expect(find.byKey(ActiveTimerGeoWidget.widgetKey), findsNothing);
    controller.dispose();
  });

  testWidgets('disappears when the running timer is stopped', (tester) async {
    final controller = await startTimer('left');
    await tester.pumpWidget(host(controller, selectedIndex: 1));
    await tester.pump();
    expect(find.byKey(ActiveTimerGeoWidget.widgetKey), findsOneWidget);

    await controller.stop();
    await tester.pump();

    expect(find.byKey(ActiveTimerGeoWidget.widgetKey), findsNothing);
    controller.dispose();
  });

  testWidgets(
    'shows opposite the current activity and selects the running activity',
    (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final controller = await startTimer('right');
      await tester.pumpWidget(host(controller));
      await tester.pump();

      final widgetFinder = find.byKey(ActiveTimerGeoWidget.widgetKey);
      expect(find.text('In progress'), findsOneWidget);
      expect(find.byIcon(Icons.menu_book), findsOneWidget);
      expect(tester.getTopLeft(widgetFinder).dx, greaterThan(200));

      FirstActivity? tappedActivity;
      await tester.pumpWidget(
        host(controller, onTap: (activity) => tappedActivity = activity),
      );
      await tester.tap(widgetFinder);
      await tester.pump();

      expect(tappedActivity, activities.last);
      expect(controller.status, DailyTimerStatus.running);
      controller.dispose();
    },
  );

  testWidgets('is hidden on the screen for the running activity', (
    tester,
  ) async {
    final controller = await startTimer('right');
    await tester.pumpWidget(host(controller, selectedIndex: 1));

    expect(find.byKey(ActiveTimerGeoWidget.widgetKey), findsNothing);
    controller.dispose();
  });

  testWidgets('places the running left-side activity on the left', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = await startTimer('left');
    await tester.pumpWidget(host(controller, selectedIndex: 1));
    await tester.pump();

    expect(
      tester.getTopLeft(find.byKey(ActiveTimerGeoWidget.widgetKey)).dx,
      lessThan(200),
    );
    expect(find.byIcon(Icons.directions_run), findsOneWidget);
    controller.dispose();
  });
}
