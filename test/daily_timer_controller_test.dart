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
    'pause stores elapsed time by local day and resume keeps the total',
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
      await timer.pause();
      expect(timer.status, DailyTimerStatus.paused);
      expect(
        timer.totalForDay('activity-1', DateTime(2026, 11, 4)),
        const Duration(minutes: 5),
      );
      expect(
        timer.totalForDay('activity-1', DateTime(2026, 11, 5)),
        const Duration(minutes: 5),
      );

      now = DateTime(2026, 11, 5, 0, 6);
      await timer.resume();
      now = DateTime(2026, 11, 5, 0, 9);
      await timer.pause();
      expect(timer.totalFor('activity-1'), const Duration(minutes: 13));
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

      await restoredTimer.pause();
      expect(restoredTimer.totalFor('activity-1'), const Duration(minutes: 7));
    },
  );
}
