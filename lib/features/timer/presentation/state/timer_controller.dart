import 'dart:async';
import 'package:flutter/foundation.dart';

import 'package:tenk/features/timer/presentation/state/timer_storage.dart';

class TimerController extends ChangeNotifier {
  final TimerStorage _storage;

  Timer? _ticker;

  // One timer state per activityId.
  final Map<String, _TimerState> _timers = {};

  TimerController(this._storage);

  /// Restores persisted timer state. Call once on app start.
  Future<void> init() async {
    final saved = await _storage.load();
    _timers
      ..clear()
      ..addEntries(
        saved.entries.map((e) {
          final snap = e.value;
          return MapEntry(
            e.key,
            _TimerState(
              runningSince: snap.runningSinceMs == null
                  ? null
                  : DateTime.fromMillisecondsSinceEpoch(snap.runningSinceMs!),
              accumulatedSeconds: snap.accumulatedSeconds,
            ),
          );
        }),
      );

    _ensureTickerIfNeeded();
    notifyListeners();
  }

  void start({required String activityId}) {
    final s = _timers.putIfAbsent(activityId, () => _TimerState());
    if (s.runningSince != null) return;

    s.runningSince = DateTime.now();
    _ensureTickerIfNeeded();
    _persist();
    notifyListeners();
  }

  void pause({required String activityId}) {
    final s = _timers[activityId];
    if (s == null) return;

    final since = s.runningSince;
    if (since == null) return;

    final live = DateTime.now().difference(since).inSeconds;
    if (live > 0) s.accumulatedSeconds += live;

    s.runningSince = null;
    _stopTickerIfIdle();
    _persist();
    notifyListeners();
  }

  int elapsedSeconds({required String activityId}) {
    final s = _timers[activityId];
    if (s == null) return 0;

    final base = s.accumulatedSeconds;
    final since = s.runningSince;
    if (since == null) return base;

    final diff = DateTime.now().difference(since).inSeconds;
    return base + (diff < 0 ? 0 : diff);
  }

  bool isRunning({required String activityId}) {
    return _timers[activityId]?.runningSince != null;
  }

  ({DateTime start, DateTime end, int seconds})? stop({
    required String activityId,
    DateTime? startedAt,
    DateTime? finishedAt,
  }) {
    final s = _timers[activityId];
    if (s == null) return null;

    final end = finishedAt ?? DateTime.now();

    final totalSeconds = _elapsedSecondsAt(activityId: activityId, at: end);
    final start = startedAt ?? end.subtract(Duration(seconds: totalSeconds));
    final diff = end.difference(start).inSeconds;

    _timers.remove(activityId);
    _stopTickerIfIdle();
    _persist();
    notifyListeners();

    if (diff <= 0) return null;
    return (start: start, end: end, seconds: diff);
  }

  void reset({required String activityId}) {
    _timers.remove(activityId);
    _stopTickerIfIdle();
    _persist();
    notifyListeners();
  }

  void _ensureTickerIfNeeded() {
    final anyRunning = _timers.values.any((s) => s.runningSince != null);
    if (!anyRunning) return;

    _ticker ??=
        Timer.periodic(const Duration(seconds: 1), (_) => notifyListeners());
  }

  void _stopTickerIfIdle() {
    final anyRunning = _timers.values.any((s) => s.runningSince != null);
    if (!anyRunning) {
      _ticker?.cancel();
      _ticker = null;
    }
  }

  int _elapsedSecondsAt({required String activityId, required DateTime at}) {
    final s = _timers[activityId];
    if (s == null) return 0;

    final base = s.accumulatedSeconds;
    final since = s.runningSince;
    if (since == null) return base;

    final diff = at.difference(since).inSeconds;
    return base + (diff < 0 ? 0 : diff);
  }

  void _persist() {
    // Persist only on state transitions (start/pause/stop/reset), not every tick.
    final snapshot = _timers.map((activityId, s) {
      return MapEntry(
        activityId,
        TimerSnapshot(
          runningSinceMs: s.runningSince?.millisecondsSinceEpoch,
          accumulatedSeconds: s.accumulatedSeconds,
        ),
      );
    });

    // Fire-and-forget is fine here; persistence is best-effort.
    // If you prefer, make these methods async and await _storage.save(...).
    unawaited(_storage.save(snapshot));
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}

class _TimerState {
  DateTime? runningSince;
  int accumulatedSeconds;

  _TimerState({
    this.runningSince,
    this.accumulatedSeconds = 0,
  });
}