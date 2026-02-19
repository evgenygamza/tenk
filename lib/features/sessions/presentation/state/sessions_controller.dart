import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import 'package:tenk/features/sessions/domain/models/session_entry.dart';
import 'package:tenk/features/sessions/domain/repositories/sessions_repository.dart';

class SessionsController extends ChangeNotifier {
  final SessionsRepository _repo;

  List<SessionEntry> entries = [];

  Timer? _timer;
  bool isRunning = false;
  int elapsedSeconds = 0;

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

  void startTimer() {
    if (isRunning) return;

    isRunning = true;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      elapsedSeconds += 1;
      notifyListeners();
    });

    notifyListeners();
  }

  void pauseTimer() {
    if (!isRunning) return;

    isRunning = false;
    _timer?.cancel();
    _timer = null;

    notifyListeners();
  }

  Future<void> stopAndSave({
    required String activityId,
    String? note,
    DateTime? startedAt,
    DateTime? finishedAt,
  }) async {
    // Stop ticking immediately (if it was running)
    pauseTimer();

    final end = finishedAt ?? DateTime.now();
    final start = startedAt ?? end.subtract(Duration(seconds: elapsedSeconds));

    final diffSeconds = end.difference(start).inSeconds;
    if (diffSeconds <= 0) return;

    final minutes = max(1, diffSeconds ~/ 60);

    final entry = SessionEntry(
      id: _newId(),
      activityId: activityId,
      startedAt: start,
      minutes: minutes,
      note: note,
    );

    entries = [entry, ...entries];
    elapsedSeconds = 0;

    notifyListeners();
    await _repo.saveEntries(entries);
  }

  void resetTimer() {
    pauseTimer();
    elapsedSeconds = 0;
    notifyListeners();
  }

  Future<void> resetActivity(String activityId) async {
    pauseTimer();
    elapsedSeconds = 0;

    entries = entries.where((e) => e.activityId != activityId).toList();
    notifyListeners();

    await _repo.saveEntries(entries);
  }

  Future<void> resetAll() async {
    pauseTimer();
    elapsedSeconds = 0;

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
