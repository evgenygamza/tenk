import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:tenk/features/activities/domain/models/first_activity.dart';
import 'package:tenk/features/activities/domain/repositories/first_activity_repository.dart';

class SharedPreferencesFirstActivityRepository
    implements FirstActivityRepository {
  SharedPreferencesFirstActivityRepository({
    SharedPreferencesAsync? preferences,
  }) : _preferences = preferences ?? SharedPreferencesAsync();

  static const _activitiesKey = 'activities';
  static const _legacyNameKey = 'first_activity_name';
  static const _legacyIconIdKey = 'first_activity_icon';

  final SharedPreferencesAsync _preferences;

  @override
  Future<List<FirstActivity>> loadActivities() async {
    final encoded = await _preferences.getString(_activitiesKey);
    if (encoded != null) {
      final decoded = jsonDecode(encoded);
      final values = decoded is List
          ? decoded
          : (decoded as Map<String, dynamic>)['activities'] as List<dynamic>;
      return values
          .map((value) {
            final activity = value as Map<String, dynamic>;
            final index = values.indexOf(value);
            return FirstActivity(
              name: activity['name'] as String,
              iconId: activity['iconId'] as String,
              id: activity['id'] as String? ?? 'legacy-$index',
            );
          })
          .toList(growable: false);
    }

    final name = await _preferences.getString(_legacyNameKey);
    if (name == null) return const [];
    return [
      FirstActivity(
        name: name,
        iconId: await _preferences.getString(_legacyIconIdKey) ?? 'sparkles',
        id: 'legacy-0',
      ),
    ];
  }

  @override
  Future<void> saveActivities(
    List<FirstActivity> activities, {
    int? selectedIndex,
  }) async {
    await _preferences.setString(
      _activitiesKey,
      _encodeActivities(
        activities,
        selectedIndex ?? (activities.isEmpty ? 0 : activities.length - 1),
      ),
    );
  }

  @override
  Future<int> loadSelectedActivityIndex() async {
    final encoded = await _preferences.getString(_activitiesKey);
    if (encoded == null) return 0;
    final decoded = jsonDecode(encoded);
    if (decoded is List) return 0;
    return (decoded as Map<String, dynamic>)['selectedIndex'] as int? ?? 0;
  }

  @override
  Future<void> saveSelectedActivityIndex(int index) async {
    await _preferences.setString(
      _activitiesKey,
      _encodeActivities(await loadActivities(), index),
    );
  }

  String _encodeActivities(List<FirstActivity> activities, int selectedIndex) {
    return jsonEncode({
      'activities': activities
          .map(
            (activity) => {
              'id': activity.id,
              'name': activity.name,
              'iconId': activity.iconId,
            },
          )
          .toList(growable: false),
      'selectedIndex': selectedIndex,
    });
  }
}
