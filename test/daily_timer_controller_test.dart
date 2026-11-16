import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:tenk/features/timer/domain/controllers/daily_timer_controller.dart';
import 'package:tenk/features/timer/domain/models/daily_timer_data.dart';
import 'package:tenk/features/timer/domain/repositories/daily_timer_repository.dart';

class _MemoryDailyTimerRepository implements DailyTimerRepository {
  DailyTimerData data = const DailyTimerData();
  bool failSave = false;
  Completer<void>? saveGate;

  @override
  Future<DailyTimerData> load() async => data;

  @override
  Future<void> save(DailyTimerData data) async {
    await saveGate?.future;
    if (failSave) throw StateError('Storage unavailable');
    this.data = data;
  }
}

void main() {
  test(
    'today accumulates saved seconds across pause, restart, and restoration',
    () async {
      final repository = _MemoryDailyTimerRepository()
        ..data = DailyTimerData(
          totals: {
            '2026-11-15': {'guitar': const Duration(hours: 2).inMilliseconds},
            '2026-11-16': {
              'guitar': const Duration(seconds: 27).inMilliseconds,
              'piano': const Duration(hours: 1).inMilliseconds,
            },
          },
        );
      var now = DateTime(2026, 11, 16, 10);
      final timer = DailyTimerController(
        repository: repository,
        clock: () => now,
      );
      addTearDown(timer.dispose);
      await timer.load();
      await timer.start('guitar');
      now = now.add(const Duration(minutes: 1, seconds: 3));
      expect(timer.totalForToday('guitar'), const Duration(seconds: 90));
      await timer.stop();
      now = now.add(const Duration(minutes: 5));
      expect(timer.totalForToday('guitar'), const Duration(seconds: 90));
      await timer.start('guitar');
      expect(timer.totalForToday('guitar'), const Duration(seconds: 90));
      now = now.add(const Duration(seconds: 1));
      final restored = DailyTimerController(
        repository: repository,
        clock: () => now,
      );
      addTearDown(restored.dispose);
      await restored.load();
      expect(restored.totalForToday('guitar'), const Duration(seconds: 91));
      expect(restored.totalForToday('piano'), const Duration(hours: 1));
    },
  );

  test(
    'today resets at local midnight while lifetime and running practice continue',
    () async {
      final repository = _MemoryDailyTimerRepository()
        ..data = DailyTimerData(
          totals: {
            '2026-11-16': {
              'guitar': const Duration(seconds: 90).inMilliseconds,
            },
          },
        );
      var now = DateTime(2026, 11, 16, 23, 59, 45);
      final timer = DailyTimerController(
        repository: repository,
        clock: () => now,
      );
      addTearDown(timer.dispose);
      await timer.load();
      await timer.start('guitar');
      now = DateTime(2026, 11, 16, 23, 59, 59);
      expect(timer.totalForToday('guitar'), const Duration(seconds: 104));
      now = DateTime(2026, 11, 17, 0, 0, 5);
      expect(timer.totalForToday('guitar'), const Duration(seconds: 5));
      expect(timer.totalFor('guitar'), const Duration(seconds: 110));
      await timer.stop();
      expect(timer.totalForToday('guitar'), const Duration(seconds: 5));
      await timer.start('guitar');
      expect(timer.totalForToday('guitar'), const Duration(seconds: 5));
    },
  );

  test(
    'current session uses timestamps, resets on restart, and clamps clock rollback',
    () async {
      final repository = _MemoryDailyTimerRepository();
      var now = DateTime(2026, 11, 16, 10);
      final timer = DailyTimerController(
        repository: repository,
        clock: () => now,
      );
      addTearDown(timer.dispose);
      await timer.start('guitar');
      now = now.add(const Duration(hours: 1, seconds: 7));
      expect(
        timer.currentSessionElapsed('guitar'),
        const Duration(hours: 1, seconds: 7),
      );
      expect(timer.currentSessionElapsed('other'), Duration.zero);
      final restored = DailyTimerController(
        repository: repository,
        clock: () => now,
      );
      addTearDown(restored.dispose);
      await restored.load();
      expect(
        restored.currentSessionElapsed('guitar'),
        const Duration(hours: 1, seconds: 7),
      );
      await restored.stop();
      expect(restored.currentSessionElapsed('guitar'), Duration.zero);
      await restored.start('guitar');
      expect(restored.currentSessionElapsed('guitar'), Duration.zero);
      expect(restored.totalFor('guitar'), const Duration(hours: 1, seconds: 7));
      now = now.subtract(const Duration(minutes: 2));
      expect(restored.currentSessionElapsed('guitar'), Duration.zero);
    },
  );

  test(
    'failed saves preserve state and a stop retry does not double count',
    () async {
      final repository = _MemoryDailyTimerRepository()..failSave = true;
      var now = DateTime(2026, 11, 16, 10);
      final timer = DailyTimerController(
        repository: repository,
        clock: () => now,
      );
      addTearDown(timer.dispose);
      await expectLater(timer.start('guitar'), throwsStateError);
      expect(timer.status, DailyTimerStatus.stopped);
      expect(timer.isSaving, isFalse);
      repository.failSave = false;
      await timer.start('guitar');
      now = now.add(const Duration(minutes: 5));
      repository.failSave = true;
      await expectLater(timer.stop(), throwsStateError);
      expect(timer.status, DailyTimerStatus.running);
      expect(timer.currentSessionElapsed('guitar'), const Duration(minutes: 5));
      expect(timer.totalFor('guitar'), const Duration(minutes: 5));
      repository.failSave = false;
      now = now.add(const Duration(minutes: 1));
      await timer.stop();
      expect(timer.totalFor('guitar'), const Duration(minutes: 6));
      expect(
        repository.data.totals['2026-11-16']?['guitar'],
        const Duration(minutes: 6).inMilliseconds,
      );
    },
  );

  test(
    'pending writes block duplicate starts and stops until committed',
    () async {
      final repository = _MemoryDailyTimerRepository()
        ..saveGate = Completer<void>();
      var now = DateTime(2026, 11, 16, 10);
      final timer = DailyTimerController(
        repository: repository,
        clock: () => now,
      );
      addTearDown(timer.dispose);
      final starting = timer.start('guitar');
      expect(timer.isSaving, isTrue);
      expect(timer.status, DailyTimerStatus.stopped);
      await timer.start('other');
      repository.saveGate!.complete();
      await starting;
      expect(timer.activeActivityId, 'guitar');
      repository.saveGate = Completer<void>();
      now = now.add(const Duration(minutes: 5));
      final stopping = timer.stop();
      expect(timer.isSaving, isTrue);
      expect(timer.status, DailyTimerStatus.running);
      await timer.stop();
      repository.saveGate!.complete();
      await stopping;
      expect(timer.totalFor('guitar'), const Duration(minutes: 5));
      expect(timer.isSaving, isFalse);
    },
  );

  test(
    'running session crosses the week boundary without importing Sunday into Monday',
    () async {
      final repository = _MemoryDailyTimerRepository();
      var now = DateTime(2026, 11, 15, 23, 50);
      final timer = DailyTimerController(
        repository: repository,
        clock: () => now,
      );
      addTearDown(timer.dispose);
      await timer.start('guitar');
      now = DateTime(2026, 11, 16, 0, 10);
      expect(
        timer.currentSessionElapsed('guitar'),
        const Duration(minutes: 20),
      );
      expect(timer.totalForCurrentWeek('guitar'), const Duration(minutes: 10));
      await timer.stop();
      expect(timer.totalForCurrentWeek('guitar'), const Duration(minutes: 10));
      expect(timer.totalFor('guitar'), const Duration(minutes: 20));
    },
  );

  test(
    'stop stores elapsed time by local day and clears active timer',
    () async {
      final repository = _MemoryDailyTimerRepository();
      var now = DateTime(2026, 11, 4, 23, 55);
      final timer = DailyTimerController(
        repository: repository,
        clock: () => now,
      );

      await timer.start('activity-1');
      await timer.start('activity-2');
      expect(timer.activeActivityId, 'activity-1');
      expect(timer.status, DailyTimerStatus.running);

      now = DateTime(2026, 11, 5, 0, 5);
      await timer.stop();
      expect(timer.status, DailyTimerStatus.stopped);
      expect(timer.activeActivityId, isNull);
      expect(
        timer.totalForDay('activity-1', DateTime(2026, 11, 4)),
        const Duration(minutes: 5),
      );
      expect(
        timer.totalForDay('activity-1', DateTime(2026, 11, 5)),
        const Duration(minutes: 5),
      );
      expect(timer.totalFor('activity-1'), const Duration(minutes: 10));
      expect(repository.data.activeActivityId, isNull);
      expect(repository.data.runningSinceMilliseconds, isNull);
    },
  );

  test(
    'running state restores from its saved timestamp after reload',
    () async {
      final repository = _MemoryDailyTimerRepository();
      var now = DateTime(2026, 11, 4, 10);
      final firstTimer = DailyTimerController(
        repository: repository,
        clock: () => now,
      );
      await firstTimer.start('activity-1');

      now = DateTime(2026, 11, 4, 10, 7);
      final restoredTimer = DailyTimerController(
        repository: repository,
        clock: () => now,
      );
      await restoredTimer.load();
      expect(restoredTimer.status, DailyTimerStatus.running);
      expect(restoredTimer.totalFor('activity-1'), const Duration(minutes: 7));

      await restoredTimer.stop();
      expect(restoredTimer.totalFor('activity-1'), const Duration(minutes: 7));
      expect(restoredTimer.status, DailyTimerStatus.stopped);
    },
  );

  test('stopped state restores after reload', () async {
    final repository = _MemoryDailyTimerRepository();
    var now = DateTime(2026, 11, 4, 10);
    final timer = DailyTimerController(
      repository: repository,
      clock: () => now,
    );
    await timer.start('activity-1');
    now = DateTime(2026, 11, 4, 10, 5);
    await timer.stop();

    final restoredTimer = DailyTimerController(
      repository: repository,
      clock: () => now,
    );
    await restoredTimer.load();

    expect(restoredTimer.status, DailyTimerStatus.stopped);
    expect(restoredTimer.activeActivityId, isNull);
    expect(restoredTimer.totalFor('activity-1'), const Duration(minutes: 5));
  });

  test(
    'recent totals include the last 30 local days and a running interval',
    () async {
      final repository = _MemoryDailyTimerRepository()
        ..data = DailyTimerData(
          totals: {
            '2026-10-05': {
              'activity-1': const Duration(hours: 20).inMilliseconds,
            },
            '2026-10-06': {
              'activity-1': const Duration(minutes: 30).inMilliseconds,
            },
            '2026-11-04': {
              'activity-1': const Duration(minutes: 15).inMilliseconds,
              'activity-2': const Duration(hours: 3).inMilliseconds,
            },
          },
          activeActivityId: 'activity-1',
          runningSinceMilliseconds: DateTime(
            2026,
            11,
            4,
            10,
          ).millisecondsSinceEpoch,
        );
      final timer = DailyTimerController(
        repository: repository,
        clock: () => DateTime(2026, 11, 4, 10, 30),
      );
      await timer.load();

      expect(
        timer.totalForLastDays('activity-1', days: 30),
        const Duration(minutes: 75),
      );
      expect(timer.practiceHistoryDays('activity-1', maxDays: 30), 30);
    },
  );

  test(
    'practice history uses its actual age until it reaches 30 days',
    () async {
      final repository = _MemoryDailyTimerRepository()
        ..data = DailyTimerData(
          totals: {
            '2026-11-01': {
              'activity-1': const Duration(hours: 1).inMilliseconds,
            },
            '2026-11-04': {
              'activity-1': const Duration(hours: 1).inMilliseconds,
            },
          },
        );
      final timer = DailyTimerController(
        repository: repository,
        clock: () => DateTime(2026, 11, 4, 12),
      );
      await timer.load();

      expect(timer.practiceHistoryDays('activity-1', maxDays: 30), 4);
      expect(
        timer.totalForLastDays(
          'activity-1',
          days: timer.practiceHistoryDays('activity-1', maxDays: 30),
        ),
        const Duration(hours: 2),
      );
      expect(timer.practiceHistoryDays('activity-2', maxDays: 30), 0);
    },
  );

  test(
    'current-week total starts Monday and includes the running interval',
    () async {
      final repository = _MemoryDailyTimerRepository()
        ..data = DailyTimerData(
          totals: {
            '2026-11-01': {
              'activity-1': const Duration(hours: 1).inMilliseconds,
            },
            '2026-11-02': {
              'activity-1': const Duration(minutes: 30).inMilliseconds,
            },
            '2026-11-04': {
              'activity-1': const Duration(minutes: 15).inMilliseconds,
              'activity-2': const Duration(hours: 2).inMilliseconds,
            },
          },
          activeActivityId: 'activity-1',
          runningSinceMilliseconds: DateTime(
            2026,
            11,
            4,
            10,
          ).millisecondsSinceEpoch,
        );
      final timer = DailyTimerController(
        repository: repository,
        clock: () => DateTime(2026, 11, 4, 10, 20),
      );
      await timer.load();

      expect(
        timer.totalForCurrentWeek('activity-1'),
        const Duration(minutes: 65),
      );
    },
  );

  test(
    'legacy paused state restores as stopped without losing totals',
    () async {
      final repository = _MemoryDailyTimerRepository()
        ..data = DailyTimerData(
          activeActivityId: 'activity-1',
          totals: {
            '2026-11-04': {
              'activity-1': const Duration(minutes: 4).inMilliseconds,
            },
          },
        );
      final timer = DailyTimerController(repository: repository);

      await timer.load();

      expect(timer.status, DailyTimerStatus.stopped);
      expect(timer.activeActivityId, isNull);
      expect(timer.totalFor('activity-1'), const Duration(minutes: 4));
      expect(repository.data.activeActivityId, isNull);
      expect(repository.data.totals, {
        '2026-11-04': {'activity-1': const Duration(minutes: 4).inMilliseconds},
      });
    },
  );
}
