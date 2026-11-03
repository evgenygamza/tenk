import 'package:shared_preferences/shared_preferences.dart';
import 'package:tenk/features/activities/domain/models/first_activity.dart';
import 'package:tenk/features/activities/domain/repositories/first_activity_repository.dart';

class SharedPreferencesFirstActivityRepository
    implements FirstActivityRepository {
  SharedPreferencesFirstActivityRepository({
    SharedPreferencesAsync? preferences,
  }) : _preferences = preferences ?? SharedPreferencesAsync();

  static const _nameKey = 'first_activity_name';
  static const _iconIdKey = 'first_activity_icon';

  final SharedPreferencesAsync _preferences;

  @override
  Future<FirstActivity?> loadActivity() async {
    final name = await _preferences.getString(_nameKey);
    if (name == null) return null;
    final iconId = await _preferences.getString(_iconIdKey) ?? 'sparkles';
    return FirstActivity(name: name, iconId: iconId);
  }

  @override
  Future<void> saveActivity(FirstActivity activity) async {
    await _preferences.setString(_nameKey, activity.name);
    await _preferences.setString(_iconIdKey, activity.iconId);
  }
}
