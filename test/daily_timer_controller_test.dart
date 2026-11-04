import 'package:flutter_test/flutter_test.dart';
import 'package:tenk/features/timer/domain/controllers/daily_timer_controller.dart';
import 'package:tenk/features/timer/domain/models/daily_timer_data.dart';
import 'package:tenk/features/timer/domain/repositories/daily_timer_repository.dart';

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
