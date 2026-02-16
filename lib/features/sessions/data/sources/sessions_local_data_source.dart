import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/session_entry.dart';

class SessionsLocalDataSource {
  static const _kEntries = 'sessions_entries_json';

  Future<List<SessionEntry>> loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kEntries);
    if (raw == null || raw.isEmpty) return [];

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((e) => SessionEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveEntries(List<SessionEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(entries.map((e) => e.toJson()).toList());
    await prefs.setString(_kEntries, encoded);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kEntries);
  }
}
