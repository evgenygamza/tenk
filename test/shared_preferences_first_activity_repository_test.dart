import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:tenk/features/activities/data/repositories/shared_preferences_first_activity_repository.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  tearDown(() {
    SharedPreferencesAsyncPlatform.instance = null;
  });

  test('stores one activity name and replaces it on a later save', () async {
    final repository = SharedPreferencesFirstActivityRepository();

    expect(await repository.loadName(), isNull);

    await repository.saveName('Гитара');
    expect(await repository.loadName(), 'Гитара');

    await repository.saveName('Пианино');
    expect(await repository.loadName(), 'Пианино');
  });
}
