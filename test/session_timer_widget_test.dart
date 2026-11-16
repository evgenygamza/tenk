import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tenk/features/activities/domain/models/first_activity.dart';
import 'package:tenk/features/timer/domain/controllers/daily_timer_controller.dart';
import 'package:tenk/features/timer/domain/models/daily_timer_data.dart';
import 'package:tenk/features/timer/domain/repositories/daily_timer_repository.dart';
import 'package:tenk/screens/activities/widgets/activities_session_timer.dart';
import 'package:tenk/screens/activities/widgets/activities_timer_button.dart';
import 'package:tenk/ui/widgets/session_timer_widget.dart';

class _Repository implements DailyTimerRepository {
  DailyTimerData data = const DailyTimerData();
  bool failSave = false;
  Completer<void>? gate;

  @override
  Future<DailyTimerData> load() async => data;

  @override
  Future<void> save(DailyTimerData data) async {
    await gate?.future;
    if (failSave) throw StateError('Storage unavailable');
    this.data = data;
  }
}

const _activity = FirstActivity(
  id: 'guitar',
  name: 'Guitar',
  iconId: 'instrument',
  initialMinutes: 3900,
);

Future<void> _pump(
  WidgetTester tester,
  DailyTimerController timer, {
  FirstActivity activity = _activity,
  double textScale = 1,
  bool reducedMotion = false,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(
          textScaler: TextScaler.linear(textScale),
          disableAnimations: reducedMotion,
        ),
        child: Scaffold(
          body: Center(
            child: SizedBox(
              width: 320,
              child: SingleChildScrollView(
                child: ActivitiesSessionTimer(
                  activity: activity,
                  timerController: timer,
                  diameter: 280,
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  test(
    'elapsed formatting handles minute/hour boundaries and long sessions',
    () {
      expect(SessionTimerWidget.formatElapsed(Duration.zero), '00:00');
      expect(
        SessionTimerWidget.formatElapsed(const Duration(seconds: 3599)),
        '59:59',
      );
      expect(
        SessionTimerWidget.formatElapsed(const Duration(hours: 1)),
        '1:00:00',
      );
      expect(
        SessionTimerWidget.formatElapsed(
          const Duration(hours: 125, minutes: 4, seconds: 8),
        ),
        '125:04:08',
      );
      expect(
        SessionTimerWidget.formatElapsed(const Duration(seconds: -1)),
        '00:00',
      );
    },
  );

  testWidgets(
    'system reduced transparency is read initially and after resume',
    (tester) async {
      const channel = MethodChannel('tenk/accessibility');
      var reduced = true;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
        call,
      ) async {
        expect(call.method, 'reduceTransparency');
        return reduced;
      });
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          channel,
          null,
        ),
      );
      final timer = DailyTimerController(repository: _Repository());
      addTearDown(timer.dispose);
      await _pump(tester, timer);
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<SessionTimerWidget>(find.byType(SessionTimerWidget))
            .reduceTransparency,
        isTrue,
      );
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      reduced = false;
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<SessionTimerWidget>(find.byType(SessionTimerWidget))
            .reduceTransparency,
        isFalse,
      );
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'ring uses weekly practice, excludes imported time, and caps after target',
    (tester) async {
      final semantics = tester.ensureSemantics();
      try {
        final repository = _Repository();
        final timer = DailyTimerController(
          repository: repository,
          clock: () => DateTime(2026, 11, 16, 12),
        );
        addTearDown(timer.dispose);
        await _pump(tester, timer);
        expect(
          tester
              .widget<SessionTimerWidget>(find.byType(SessionTimerWidget))
              .weeklyProgress,
          0,
        );
        expect(find.text('This week · 0m / 3h'), findsOneWidget);
        expect(find.text('Total · 65h'), findsOneWidget);
        expect(find.byKey(ActivitiesSessionTimer.estimateKey), findsNothing);
        repository.data = DailyTimerData(
          totals: {
            '2026-11-15': {'guitar': const Duration(hours: 10).inMilliseconds},
            '2026-11-16': {
              'guitar': const Duration(minutes: 140).inMilliseconds,
              'other': const Duration(hours: 20).inMilliseconds,
            },
          },
        );
        await timer.load();
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<SessionTimerWidget>(find.byType(SessionTimerWidget))
              .weeklyProgress,
          closeTo(140 / 180, 0.00001),
        );
        expect(find.text('This week · 2h 20m / 3h'), findsOneWidget);
        expect(find.text('Total · 77h 20m'), findsOneWidget);
        expect(
          tester.getSemantics(find.byKey(SessionTimerWidget.ringKey)).value,
          '78%',
        );
        repository.data = DailyTimerData(
          totals: {
            '2026-11-16': {'guitar': const Duration(hours: 4).inMilliseconds},
          },
        );
        await timer.load();
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<SessionTimerWidget>(find.byType(SessionTimerWidget))
              .weeklyProgress,
          1,
        );
        expect(find.text('This week · 4h / 3h'), findsOneWidget);
        expect(find.text('Total · 69h'), findsOneWidget);
        await tester.pumpWidget(const SizedBox.shrink());
      } finally {
        semantics.dispose();
      }
    },
  );

  testWidgets(
    'timestamp ticks update today and metrics and resume accumulated practice',
    (tester) async {
      var now = DateTime(2026, 11, 16, 10);
      final timer = DailyTimerController(
        repository: _Repository(),
        clock: () => now,
      );
      addTearDown(timer.dispose);
      await _pump(tester, timer);
      final circle = find.byKey(SessionTimerWidget.circleKey);
      final initialCenter = tester.getCenter(circle);
      expect(tester.getSize(circle), const Size(140, 140));
      expect(tester.getSize(find.byType(SessionTimerWidget)).height, 140);
      await tester.tap(find.byKey(ActivitiesTimerButton.toggleButtonKey));
      await tester.pumpAndSettle();
      expect(tester.getSize(circle), const Size(280, 280));
      expect(tester.getSize(find.byType(SessionTimerWidget)).height, 280);
      expect(tester.getCenter(circle), initialCenter);
      expect(find.text('00:00'), findsOneWidget);
      now = now.add(const Duration(minutes: 2, seconds: 8));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('02:08'), findsOneWidget);
      expect(find.text('This week · 2m / 3h'), findsOneWidget);
      expect(
        tester
                .getRect(find.byKey(ActivitiesSessionTimer.weeklyPracticeKey))
                .top -
            tester.getRect(circle).bottom,
        closeTo(12, 0.01),
      );
      expect(
        tester.getRect(circle).top -
            tester
                .getRect(find.byKey(ActivitiesSessionTimer.estimateKey))
                .bottom,
        closeTo(12, 0.01),
      );
      expect(find.text('Total · 65h 2m'), findsOneWidget);
      expect(
        tester
            .widget<SessionTimerWidget>(find.byType(SessionTimerWidget))
            .weeklyProgress,
        closeTo(128 / 10800, 0.000001),
      );
      await tester.tap(find.byKey(ActivitiesTimerButton.toggleButtonKey));
      await tester.pumpAndSettle();
      expect(tester.getCenter(circle), initialCenter);
      expect(tester.getSize(circle), const Size(140, 140));
      expect(tester.getSize(find.byType(SessionTimerWidget)).height, 140);
      await tester.tap(find.byKey(ActivitiesTimerButton.toggleButtonKey));
      await tester.pumpAndSettle();
      expect(find.text('02:08'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Total · 65h 2m'), findsOneWidget);
      now = now.add(const Duration(hours: 4));
      await tester.pump(const Duration(seconds: 1));
      expect(
        tester
            .widget<SessionTimerWidget>(find.byType(SessionTimerWidget))
            .weeklyProgress,
        1,
      );
      expect(find.text('This week · 4h 2m / 3h'), findsOneWidget);
      now = now.add(const Duration(hours: 1));
      await tester.pump(const Duration(seconds: 1));
      expect(
        tester
            .widget<SessionTimerWidget>(find.byType(SessionTimerWidget))
            .weeklyProgress,
        1,
      );
      expect(find.text('This week · 5h 2m / 3h'), findsOneWidget);
      expect(find.text('Total · 70h 2m'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'lifetime total continues beyond the final milestone with accessible captions',
    (tester) async {
      final timer = DailyTimerController(
        repository: _Repository(),
        clock: () => DateTime(2026, 11, 16, 10),
      );
      addTearDown(timer.dispose);
      await _pump(
        tester,
        timer,
        activity: const FirstActivity(
          id: 'guitar',
          name: 'Guitar',
          iconId: 'instrument',
          initialMinutes: 600001,
        ),
        textScale: 2,
      );
      expect(find.text('Total · 10000h 1m'), findsOneWidget);
      expect(find.text('Goal reached'), findsOneWidget);
      expect(
        tester
            .widget<SessionTimerWidget>(find.byType(SessionTimerWidget))
            .weeklyProgress,
        0,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('resume reads wall clock instead of counting refresh ticks', (
    tester,
  ) async {
    var now = DateTime(2026, 11, 16, 10);
    final timer = DailyTimerController(
      repository: _Repository(),
      clock: () => now,
    );
    addTearDown(timer.dispose);
    await timer.start('guitar');
    await _pump(tester, timer);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    now = now.add(const Duration(hours: 1, seconds: 3));
    await tester.pump(const Duration(seconds: 5));
    expect(find.text('00:00'), findsOneWidget);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(find.text('1:00:03'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'pending operations disable the button and save failure keeps running',
    (tester) async {
      final repository = _Repository()..gate = Completer<void>();
      final timer = DailyTimerController(
        repository: repository,
        clock: () => DateTime(2026, 11, 16, 10),
      );
      addTearDown(timer.dispose);
      await _pump(tester, timer);
      final button = find.byKey(ActivitiesTimerButton.toggleButtonKey);
      await tester.tap(button);
      await tester.pump();
      expect(tester.widget<FilledButton>(button).onPressed, isNull);
      expect(find.byTooltip('Start timer'), findsOneWidget);
      repository.gate!.complete();
      await tester.pumpAndSettle();
      repository.failSave = true;
      await tester.tap(button);
      await tester.pumpAndSettle();
      expect(timer.status, DailyTimerStatus.running);
      expect(find.byTooltip('Stop timer'), findsOneWidget);
      expect(
        find.text(
          'Could not save practice. Timer is still running. Try Stop again.',
        ),
        findsOneWidget,
      );
      repository.failSave = false;
      await tester.tap(button);
      await tester.pumpAndSettle();
      expect(timer.status, DailyTimerStatus.stopped);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('enlarged text and reduced motion fit on a compact viewport', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 568);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final timer = DailyTimerController(
      repository: _Repository(),
      clock: () => DateTime(2026, 11, 16, 10),
    );
    addTearDown(timer.dispose);
    await timer.start('guitar');
    await _pump(tester, timer, textScale: 2, reducedMotion: true);
    await tester.pump();
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('00:00'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
