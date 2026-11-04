import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:tenk/features/activities/data/repositories/shared_preferences_first_activity_repository.dart';
import 'package:tenk/features/activities/domain/models/first_activity.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  tearDown(() {
    SharedPreferencesAsyncPlatform.instance = null;
  });

  test('stores the full activity list and selected index', () async {
    final repository = SharedPreferencesFirstActivityRepository();
    const guitar = FirstActivity(name: 'Гитара', iconId: 'instrument');
    const piano = FirstActivity(name: 'Пианино', iconId: 'music');

    expect(await repository.loadActivities(), isEmpty);
    await repository.saveActivities([guitar, piano]);
    await repository.saveSelectedActivityIndex(0);

    expect(await repository.loadActivities(), [guitar, piano]);
    expect(await repository.loadSelectedActivityIndex(), 0);
  });

  test(
    'loads a legacy single activity and supplies its default icon',
    () async {
      final preferences = SharedPreferencesAsync();
      await preferences.setString('first_activity_name', 'Гитара');
      final repository = SharedPreferencesFirstActivityRepository(
        preferences: preferences,
      );

      expect(await repository.loadActivities(), [
        const FirstActivity(name: 'Гитара', iconId: 'sparkles'),
      ]);
      expect(await repository.loadSelectedActivityIndex(), 0);
    },
  );
}
