import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Minimal persistence for per-activity timers using SharedPreferences.
/// Stored as a single JSON map under one key.
class TimerStorage {
  static const _key = 'tenk_timer_state_v1';

  Future<Map<String, TimerSnapshot>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return {};

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return {};

      return decoded.map((activityId, v) {
        if (v is! Map<String, dynamic>) {
          return MapEntry(activityId, const TimerSnapshot());
        }
        return MapEntry(activityId, TimerSnapshot.fromJson(v));
      });
    } catch (_) {
      return {};
    }
  }

  Future<void> save(Map<String, TimerSnapshot> state) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(state.map((k, v) => MapEntry(k, v.toJson())));
    await prefs.setString(_key, encoded);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

class TimerSnapshot {
  final int? runningSinceMs;
  final int accumulatedSeconds;

  const TimerSnapshot({
    this.runningSinceMs,
    this.accumulatedSeconds = 0,
  });

  Map<String, dynamic> toJson() => {
    'runningSinceMs': runningSinceMs,
    'accumulatedSeconds': accumulatedSeconds,
  };

  factory TimerSnapshot.fromJson(Map<String, dynamic> json) {
    final rs = json['runningSinceMs'];
    final acc = json['accumulatedSeconds'];
    return TimerSnapshot(
      runningSinceMs: rs is int ? rs : null,
      accumulatedSeconds: acc is int ? acc : 0,
    );
  }
}