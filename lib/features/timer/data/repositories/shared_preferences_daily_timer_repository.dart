import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:tenk/features/timer/domain/models/daily_timer_data.dart';
import 'package:tenk/features/timer/domain/repositories/daily_timer_repository.dart';

class SharedPreferencesDailyTimerRepository implements DailyTimerRepository {
  SharedPreferencesDailyTimerRepository({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  static const _dataKey = 'daily_timer_data';

  final SharedPreferencesAsync _preferences;

  @override
  Future<DailyTimerData> load() async {
    final encoded = await _preferences.getString(_dataKey);
    if (encoded == null) return const DailyTimerData();
    return DailyTimerData.fromJson(jsonDecode(encoded) as Map<String, dynamic>);
  }

  @override
  Future<void> save(DailyTimerData data) =>
      _preferences.setString(_dataKey, jsonEncode(data.toJson()));
}
