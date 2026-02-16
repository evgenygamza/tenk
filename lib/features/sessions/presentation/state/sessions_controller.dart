import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionsController extends ChangeNotifier {
  static const _kToday = 'sessions_total_minutes_today';
  static const _kAllTime = 'sessions_total_minutes_all_time';
  static const _kTodayDate = 'sessions_today_date_yyyy_mm_dd';

  int totalMinutesToday = 0;
  int totalMinutesAllTime = 0;

  SessionsController() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();

    totalMinutesAllTime = prefs.getInt(_kAllTime) ?? 0;

    final savedDate = prefs.getString(_kTodayDate);
    final today = _todayKey();

    if (savedDate == today) {
      totalMinutesToday = prefs.getInt(_kToday) ?? 0;
    } else {
      totalMinutesToday = 0;
      await prefs.setInt(_kToday, 0);
      await prefs.setString(_kTodayDate, today);
    }

    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kToday, totalMinutesToday);
    await prefs.setInt(_kAllTime, totalMinutesAllTime);
    await prefs.setString(_kTodayDate, _todayKey());
  }

  void addManual(int minutes) {
    if (minutes <= 0) return;

    totalMinutesToday += minutes;
    totalMinutesAllTime += minutes;

    notifyListeners();
    _save();
  }

  Future<void> resetAll() async {
    totalMinutesToday = 0;
    totalMinutesAllTime = 0;

    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kToday, 0);
    await prefs.setInt(_kAllTime, 0);
    await prefs.setString(_kTodayDate, _todayKey());
  }

  String _todayKey() {
    final now = DateTime.now();
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
