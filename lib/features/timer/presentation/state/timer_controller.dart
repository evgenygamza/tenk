import 'dart:async';
import 'package:flutter/foundation.dart';

class TimerController extends ChangeNotifier {
  Timer? _ticker;

  DateTime? _runningSince;
  int _accumulatedSeconds = 0;

  String? activeActivityId;

  bool get isRunning => _runningSince != null;

  int get elapsedSeconds {
    final since = _runningSince;
    if (since == null) return _accumulatedSeconds;
    final live = DateTime.now().difference(since).inSeconds;
    return _accumulatedSeconds + (live < 0 ? 0 : live);
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker =
        Timer.periodic(const Duration(seconds: 1), (_) => notifyListeners());
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  void start({required String activityId}) {
    if (isRunning) return;

    activeActivityId = activityId;
    _runningSince = DateTime.now();
    _startTicker();
    notifyListeners();
  }

  void pause() {
    final since = _runningSince;
    if (since == null) return;

    final live = DateTime.now().difference(since).inSeconds;
    if (live > 0) _accumulatedSeconds += live;

    _runningSince = null;
    _stopTicker();
    notifyListeners();
  }

  /// Stops the timer and returns fixed (start, end, seconds).
  /// Returns null if duration <= 0.
  ({DateTime start, DateTime end, int seconds})? stop({
    DateTime? startedAt,
    DateTime? finishedAt,
  }) {
    final end = finishedAt ?? DateTime.now();

    final totalSeconds = (() {
      final since = _runningSince;
      if (since == null) return _accumulatedSeconds;
      final live = end.difference(since).inSeconds;
      return _accumulatedSeconds + (live < 0 ? 0 : live);
    })();

    // reset timing state
    _runningSince = null;
    _accumulatedSeconds = 0;
    _stopTicker();

    final start = startedAt ?? end.subtract(Duration(seconds: totalSeconds));
    final diff = end.difference(start).inSeconds;

    notifyListeners();
    if (diff <= 0) return null;

    return (start: start, end: end, seconds: diff);
  }

  void reset() {
    _runningSince = null;
    _accumulatedSeconds = 0;
    activeActivityId = null;
    _stopTicker();
    notifyListeners();
  }

  @override
  void dispose() {
    _stopTicker();
    super.dispose();
  }
}
