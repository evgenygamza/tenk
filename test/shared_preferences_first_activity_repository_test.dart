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

  test(
    'stores an activity name and icon and replaces both on a later save',
    () async {
      final repository = SharedPreferencesFirstActivityRepository();

      expect(await repository.loadActivity(), isNull);

      const guitar = FirstActivity(name: 'Гитара', iconId: 'instrument');
      await repository.saveActivity(guitar);
      expect(await repository.loadActivity(), guitar);

      const piano = FirstActivity(name: 'Пианино', iconId: 'music');
      await repository.saveActivity(piano);
      expect(await repository.loadActivity(), piano);
    },
  );

  test('loads an existing name with the default icon', () async {
    final preferences = SharedPreferencesAsync();
    await preferences.setString('first_activity_name', 'Гитара');
    final repository = SharedPreferencesFirstActivityRepository(
      preferences: preferences,
    );

    expect(
      await repository.loadActivity(),
      const FirstActivity(name: 'Гитара', iconId: 'sparkles'),
    );
  });
}
