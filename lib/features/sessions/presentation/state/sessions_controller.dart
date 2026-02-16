import 'dart:async';

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

  int get totalMinutesAllTime => entries.fold(0, (sum, e) => sum + e.minutes);

  int get totalMinutesToday {
    final today = _todayKey();
    return entries
        .where((e) => _dateKey(e.startedAt) == today)
        .fold(0, (sum, e) => sum + e.minutes);
  }

  Future<void> _load() async {
    entries = await _repo.getEntries();
    notifyListeners();
  }

  Future<void> addManual(int minutes, {String? note}) async {
    if (minutes <= 0) return;

    final entry = SessionEntry(
      id: _newId(),
      startedAt: DateTime.now(),
      minutes: minutes,
      note: note,
    );

    entries = [entry, ...entries];
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

  Future<void> stopAndSave({String? note}) async {
    pauseTimer();

    if (elapsedSeconds <= 0) return;

    var minutes = elapsedSeconds ~/ 60;
    if (minutes == 0) minutes = 1; // keep very short sessions

    final entry = SessionEntry(
      id: _newId(),
      startedAt: DateTime.now(),
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
