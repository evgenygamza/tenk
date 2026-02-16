import 'package:flutter/foundation.dart';

import 'package:tenk/features/sessions/domain/models/session_entry.dart';
import 'package:tenk/features/sessions/domain/repositories/sessions_repository.dart';

class SessionsController extends ChangeNotifier {
  final SessionsRepository _repo;

  List<SessionEntry> entries = [];

  SessionsController(this._repo) {
    _load();
  }

  int get totalMinutesAllTime =>
      entries.fold(0, (sum, e) => sum + e.minutes);

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

    entries = [entry, ...entries]; // newest first
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

  String _newId() {
    final now = DateTime.now().microsecondsSinceEpoch;
    return now.toString();
  }
}
