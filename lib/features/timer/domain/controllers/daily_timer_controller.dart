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

  DailyTimerStatus get status => _activeActivityId == null
      ? DailyTimerStatus.stopped
      : DailyTimerStatus.running;

  String? get activeActivityId => _activeActivityId;

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
    if (status != DailyTimerStatus.stopped) return;
    _activeActivityId = activityId;
    _runningSince = _clock();
    await _persist();
    notifyListeners();
  }

  Future<void> stop() async {
    final start = _runningSince;
    final activityId = _activeActivityId;
    if (start == null || activityId == null) return;
    _addInterval(activityId, start, _clock());
    _activeActivityId = null;
    _runningSince = null;
    await _persist();
    notifyListeners();
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

  void _addInterval(String activityId, DateTime start, DateTime end) {
    if (!end.isAfter(start)) return;
    var cursor = start;
    while (cursor.isBefore(end)) {
      final nextDay = DateTime(cursor.year, cursor.month, cursor.day + 1);
      final segmentEnd = end.isBefore(nextDay) ? end : nextDay;
      final milliseconds = segmentEnd.difference(cursor).inMilliseconds;
      final day = _totals.putIfAbsent(_dayKey(cursor), () => {});
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
