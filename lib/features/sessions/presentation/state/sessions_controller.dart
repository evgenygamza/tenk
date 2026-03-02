import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:tenk/features/sessions/domain/models/session_entry.dart';
import 'package:tenk/features/sessions/domain/repositories/sessions_repository.dart';

class SessionsController extends ChangeNotifier {
  final SessionsRepository _repo;

  List<SessionEntry> entries = [];

  SessionsController(this._repo) {
    _load();
  }

  int totalMinutesAllTime(String activityId) {
    return entries
        .where((e) => e.activityId == activityId)
        .fold(0, (sum, e) => sum + e.minutes);
  }

  int totalMinutesToday(String activityId) {
    final today = _todayKey();
    return entries
        .where((e) => e.activityId == activityId)
        .where((e) => _dateKey(e.startedAt) == today)
        .fold(0, (sum, e) => sum + e.minutes);
  }

  Future<void> _load() async {
    entries = await _repo.getEntries();
    notifyListeners();
  }

  Future<void> addManual(String activityId, int minutes, {String? note}) async {
    if (minutes <= 0) return;

    final entry = SessionEntry(
      id: _newId(),
      activityId: activityId,
      startedAt: DateTime.now(),
      minutes: minutes,
      note: note,
    );

    entries = [entry, ...entries];
    notifyListeners();

    await _repo.saveEntries(entries);
  }

  /// Creates a session entry from explicit start/end timestamps.
  /// Duration is rounded up to minutes and clamped to at least 1 minute.
  Future<void> addTimedEntry({
    required String activityId,
    required DateTime startedAt,
    required DateTime finishedAt,
    String? note,
  }) async {
    final diffSeconds = finishedAt.difference(startedAt).inSeconds;
    if (diffSeconds <= 0) return;

    final minutes = max(1, (diffSeconds / 60).ceil());

    final entry = SessionEntry(
      id: _newId(),
      activityId: activityId,
      startedAt: startedAt,
      minutes: minutes,
      note: note,
    );

    entries = [entry, ...entries];
    notifyListeners();
    await _repo.saveEntries(entries);
  }

  Future<void> updateEntry(SessionEntry updated) async {
    final idx = entries.indexWhere((e) => e.id == updated.id);
    if (idx == -1) return;

    final copy = [...entries];
    copy[idx] = updated;

    entries = copy;
    notifyListeners();
    await _repo.saveEntries(entries);
  }

  Future<void> deleteEntry(String id) async {
    entries = entries.where((e) => e.id != id).toList();
    notifyListeners();
    await _repo.saveEntries(entries);
  }

  Future<void> resetActivity(String activityId) async {
    entries = entries.where((e) => e.activityId != activityId).toList();
    notifyListeners();
    await _repo.saveEntries(entries);
  }

  Future<void> resetAll() async {
    entries = [];
    notifyListeners();
    await _repo.clear();
  }

  String _todayKey() => _dateKey(DateTime.now());

  String _dateKey(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  String _newId() => DateTime.now().microsecondsSinceEpoch.toString();
}