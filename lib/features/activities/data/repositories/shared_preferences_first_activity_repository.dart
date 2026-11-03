import 'package:shared_preferences/shared_preferences.dart';
import 'package:tenk/features/activities/domain/repositories/first_activity_repository.dart';

class SharedPreferencesFirstActivityRepository
    implements FirstActivityRepository {
  SharedPreferencesFirstActivityRepository({
    SharedPreferencesAsync? preferences,
  }) : _preferences = preferences ?? SharedPreferencesAsync();

  static const _nameKey = 'first_activity_name';

  final SharedPreferencesAsync _preferences;

  @override
  Future<String?> loadName() => _preferences.getString(_nameKey);

  @override
  Future<void> saveName(String name) => _preferences.setString(_nameKey, name);
}
