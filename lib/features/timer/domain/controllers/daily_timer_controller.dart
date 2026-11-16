import 'package:flutter/foundation.dart';
import 'package:tenk/features/timer/domain/models/daily_timer_data.dart';
import 'package:tenk/features/timer/domain/repositories/daily_timer_repository.dart';

enum DailyTimerStatus { running, stopped }

class DailyTimerController extends ChangeNotifier {
  DailyTimerController({
    required DailyTimerRepository repository,
    DateTime Function()? clock,
  }) : _repository = repository,
       _clock = clock ?? DateTime.now;

  final DailyTimerRepository _repository;
  final DateTime Function() _clock;
  final Map<String, Map<String, int>> _totals = {};
  String? _activeActivityId;
  DateTime? _runningSince;
  bool _isSaving = false;

  DailyTimerStatus get status => _activeActivityId == null
      ? DailyTimerStatus.stopped
      : DailyTimerStatus.running;

  String? get activeActivityId => _activeActivityId;
  bool get isSaving => _isSaving;

  Duration currentSessionElapsed(String activityId, {DateTime? at}) {
    final start = _runningSince;
    if (start == null || _activeActivityId != activityId) return Duration.zero;
    return Duration(milliseconds: _intervalTotal(start, at ?? _clock()));
  }

  Future<void> load() async {
    final data = await _repository.load();
    final wasPaused =
        data.activeActivityId != null && data.runningSinceMilliseconds == null;
    _activeActivityId = wasPaused ? null : data.activeActivityId;
    _runningSince =
        _activeActivityId == null || data.runningSinceMilliseconds == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(data.runningSinceMilliseconds!);
    _totals
      ..clear()
      ..addAll({
        for (final entry in data.totals.entries)
          entry.key: Map<String, int>.of(entry.value),
      });
    if (wasPaused) await _persist();
    notifyListeners();
  }

  Future<void> start(String activityId) async {
    if (_isSaving || status != DailyTimerStatus.stopped) return;
    final start = _clock();
    _isSaving = true;
    notifyListeners();
    try {
      await _repository.save(
        DailyTimerData(
          activeActivityId: activityId,
          runningSinceMilliseconds: start.millisecondsSinceEpoch,
          totals: _copyTotals(),
        ),
      );
      _activeActivityId = activityId;
      _runningSince = start;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> stop() async {
    final start = _runningSince;
    final activityId = _activeActivityId;
    if (_isSaving || start == null || activityId == null) return;
    final totals = _copyTotals();
    _addInterval(totals, activityId, start, _clock());
    _isSaving = true;
    notifyListeners();
    try {
      await _repository.save(DailyTimerData(totals: totals));
      _totals
        ..clear()
        ..addAll(totals);
      _activeActivityId = null;
      _runningSince = null;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Duration totalFor(String activityId, {DateTime? at}) {
    var milliseconds = 0;
    for (final day in _totals.values) {
      milliseconds += day[activityId] ?? 0;
    }
    final start = _runningSince;
    if (start != null && _activeActivityId == activityId) {
      final end = at ?? _clock();
      milliseconds += _intervalTotal(start, end);
    }
    return Duration(milliseconds: milliseconds);
  }

  Duration totalForDay(String activityId, DateTime day, {DateTime? at}) {
    final key = _dayKey(day);
    var milliseconds = _totals[key]?[activityId] ?? 0;
    final start = _runningSince;
    if (start != null && _activeActivityId == activityId) {
      milliseconds += _intervalForDay(start, at ?? _clock(), key);
    }
    return Duration(milliseconds: milliseconds);
  }

  /// Saved practice and any running interval in the current local calendar day.
  Duration totalForToday(String activityId, {DateTime? at}) {
    final end = at ?? _clock();
    return totalForDay(activityId, end, at: end);
  }

  Duration totalForLastDays(
    String activityId, {
    required int days,
    DateTime? at,
  }) {
    if (days <= 0) throw ArgumentError.value(days, 'days', 'Must be positive');
    final end = at ?? _clock();
    final today = DateTime(end.year, end.month, end.day);
    var total = Duration.zero;
    for (var offset = 0; offset < days; offset++) {
      total += totalForDay(
        activityId,
        today.subtract(Duration(days: offset)),
        at: end,
      );
    }
    return total;
  }

  Duration totalForCurrentWeek(String activityId, {DateTime? at}) {
    final end = at ?? _clock();
    final today = DateTime(end.year, end.month, end.day);
    var total = Duration.zero;
    for (var offset = today.weekday - 1; offset >= 0; offset--) {
      final day = DateTime(today.year, today.month, today.day - offset);
      total += totalForDay(activityId, day, at: end);
    }
    return total;
  }

  int practiceHistoryDays(
    String activityId, {
    required int maxDays,
    DateTime? at,
  }) {
    if (maxDays <= 0) {
      throw ArgumentError.value(maxDays, 'maxDays', 'Must be positive');
    }
    final end = at ?? _clock();
    final today = DateTime(end.year, end.month, end.day);
    final todayKey = _dayKey(today);
    final windowStartKey = _dayKey(
      DateTime(today.year, today.month, today.day - maxDays + 1),
    );
    String? firstPracticeDay;

    for (final entry in _totals.entries) {
      if ((entry.value[activityId] ?? 0) <= 0 ||
          entry.key.compareTo(todayKey) > 0) {
        continue;
      }
      if (entry.key.compareTo(windowStartKey) < 0) return maxDays;
      if (firstPracticeDay == null ||
          entry.key.compareTo(firstPracticeDay) < 0) {
        firstPracticeDay = entry.key;
      }
    }

    final runningSince = _runningSince;
    if (_activeActivityId == activityId && runningSince != null) {
      final runningDay = _dayKey(runningSince);
      if (runningDay.compareTo(todayKey) <= 0) {
        if (runningDay.compareTo(windowStartKey) < 0) return maxDays;
        if (firstPracticeDay == null ||
            runningDay.compareTo(firstPracticeDay) < 0) {
          firstPracticeDay = runningDay;
        }
      }
    }

    if (firstPracticeDay == null) return 0;
    final firstDate = DateTime.parse(firstPracticeDay);
    return DateTime.utc(today.year, today.month, today.day)
            .difference(
              DateTime.utc(firstDate.year, firstDate.month, firstDate.day),
            )
            .inDays +
        1;
  }

  Future<void> _persist() => _repository.save(
    DailyTimerData(
      activeActivityId: _activeActivityId,
      runningSinceMilliseconds: _runningSince?.millisecondsSinceEpoch,
      totals: {
        for (final entry in _totals.entries)
          entry.key: Map<String, int>.of(entry.value),
      },
    ),
  );

  Map<String, Map<String, int>> _copyTotals() => {
    for (final entry in _totals.entries)
      entry.key: Map<String, int>.of(entry.value),
  };

  void _addInterval(
    Map<String, Map<String, int>> totals,
    String activityId,
    DateTime start,
    DateTime end,
  ) {
    if (!end.isAfter(start)) return;
    var cursor = start;
    while (cursor.isBefore(end)) {
      final nextDay = DateTime(cursor.year, cursor.month, cursor.day + 1);
      final segmentEnd = end.isBefore(nextDay) ? end : nextDay;
      final milliseconds = segmentEnd.difference(cursor).inMilliseconds;
      final day = totals.putIfAbsent(_dayKey(cursor), () => {});
      day[activityId] = (day[activityId] ?? 0) + milliseconds;
      cursor = segmentEnd;
    }
  }

  int _intervalTotal(DateTime start, DateTime end) =>
      end.isAfter(start) ? end.difference(start).inMilliseconds : 0;

  int _intervalForDay(DateTime start, DateTime end, String dayKey) {
    if (!end.isAfter(start)) return 0;
    var cursor = start;
    var milliseconds = 0;
    while (cursor.isBefore(end)) {
      final nextDay = DateTime(cursor.year, cursor.month, cursor.day + 1);
      final segmentEnd = end.isBefore(nextDay) ? end : nextDay;
      if (_dayKey(cursor) == dayKey) {
        milliseconds += segmentEnd.difference(cursor).inMilliseconds;
      }
      cursor = segmentEnd;
    }
    return milliseconds;
  }

  String _dayKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
