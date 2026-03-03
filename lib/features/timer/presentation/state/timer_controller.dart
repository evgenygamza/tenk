import 'dart:async';
import 'package:flutter/foundation.dart';

class TimerController extends ChangeNotifier {
  Timer? _ticker;

  // One timer state per activityId.
  final Map<String, _TimerState> _timers = {};

  // Starts (or resumes) a timer for a specific activity.
  void start({required String activityId}) {
    final s = _timers.putIfAbsent(activityId, () => _TimerState());
    if (s.runningSince != null) return;

    s.runningSince = DateTime.now();
    _ensureTicker();
    notifyListeners();
  }

  // Pauses a timer for a specific activity.
  void pause({required String activityId}) {
    final s = _timers[activityId];
    if (s == null) return;

    final since = s.runningSince;
    if (since == null) return;

    final live = DateTime.now().difference(since).inSeconds;
    if (live > 0) s.accumulatedSeconds += live;

    s.runningSince = null;
    _stopTickerIfIdle();
    notifyListeners();
  }

  // Returns elapsed seconds for a specific activity.
  int elapsedSeconds({required String activityId}) {
    final s = _timers[activityId];
    if (s == null) return 0;

    final base = s.accumulatedSeconds;
    final since = s.runningSince;
    if (since == null) return base;

    final diff = DateTime.now().difference(since).inSeconds;
    return base + (diff < 0 ? 0 : diff);
  }

  // True if this activity timer is currently running (not paused).
  bool isRunning({required String activityId}) {
    return _timers[activityId]?.runningSince != null;
  }

  // Stops the timer for the given activity and returns fixed timestamps for saving.
  // Returns null if duration <= 0 or if there is no timer state for this activity.
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

    // Remove timer state for this activity.
    _timers.remove(activityId);
    _stopTickerIfIdle();
    notifyListeners();

    if (diff <= 0) return null;
    return (start: start, end: end, seconds: diff);
  }

  // Clears the timer state for a specific activity without saving.
  void reset({required String activityId}) {
    _timers.remove(activityId);
    _stopTickerIfIdle();
    notifyListeners();
  }

  void _ensureTicker() {
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

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}

class _TimerState {
  DateTime? runningSince;
  int accumulatedSeconds = 0;
}
