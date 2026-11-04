import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:tenk/features/timer/data/repositories/shared_preferences_daily_timer_repository.dart';
import 'package:tenk/features/timer/domain/models/daily_timer_data.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  tearDown(() {
    SharedPreferencesAsyncPlatform.instance = null;
  });

  test('persists active timer timestamps and daily totals', () async {
    final preferences = SharedPreferencesAsync();
    final repository = SharedPreferencesDailyTimerRepository(
      preferences: preferences,
    );
    final data = DailyTimerData(
      activeActivityId: 'guitar',
      runningSinceMilliseconds: DateTime(
        2026,
        11,
        4,
        10,
      ).millisecondsSinceEpoch,
      totals: {
        '2026-11-04': {'guitar': 300000},
      },
    );

    await repository.save(data);

    final restored = await repository.load();
    expect(restored.activeActivityId, data.activeActivityId);
    expect(restored.runningSinceMilliseconds, data.runningSinceMilliseconds);
    expect(restored.totals, equals(data.totals));
  });
}
