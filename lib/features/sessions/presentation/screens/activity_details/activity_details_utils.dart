import 'package:tenk/features/sessions/domain/models/session_entry.dart';

/// Formatting helpers (labels, time strings).
class ActivityDetailsFormat {
  static String formatHoursMinutes(int totalMinutes) {
    final h = totalMinutes ~/ 60;
    final m = totalMinutes % 60;
    if (h <= 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }

  static String pacePerDayLabel(int minutesPerDay) {
    if (minutesPerDay < 60) return '${minutesPerDay}m/d';
    final h = minutesPerDay ~/ 60;
    final m = minutesPerDay % 60;
    if (m == 0) return '${h}h/d';
    return '${h}h ${m}m/d';
  }

  static String monShort(int m) {
    const names = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec',
    ];
    return names[(m - 1).clamp(0, 11)];
  }

  /// For daily chart labels: show "Mar 1" on first day of month, otherwise "2", "3"...
  static String dailyLabel(DateTime d) {
    return d.day == 1 ? '${monShort(d.month)} 1' : '${d.day}';
  }

  /// For monthly chart labels: show year on January, otherwise month short name.
  static String monthLabel(DateTime monthStart) {
    return monthStart.month == 1
        ? '${monthStart.year} Jan'
        : monShort(monthStart.month);
  }
}

/// Aggregation helpers (summing minutes, windows).
class ActivityDetailsAggregate {
  static int minutesThisWeek({
    required List<SessionEntry> entries,
    required String activityId,
    DateTime? now,
  }) {
    final n = now ?? DateTime.now();
    final startOfWeek = DateTime(n.year, n.month, n.day)
        .subtract(Duration(days: n.weekday - DateTime.monday));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));

    var sum = 0;
    for (final e in entries) {
      if (e.activityId != activityId) continue;
      final dt = e.startedAt;
      if (dt.isBefore(startOfWeek) || !dt.isBefore(endOfWeek)) continue;
      sum += e.minutes;
    }
    return sum;
  }

  static int minutesLastNDays({
    required List<SessionEntry> entries,
    required String activityId,
    required int days,
    DateTime? now,
  }) {
    final n = now ?? DateTime.now();
    final from = DateTime(n.year, n.month, n.day)
        .subtract(Duration(days: days - 1));
    final to = DateTime(n.year, n.month, n.day).add(const Duration(days: 1));

    var sum = 0;
    for (final e in entries) {
      if (e.activityId != activityId) continue;
      final dt = e.startedAt;
      if (dt.isBefore(from) || !dt.isBefore(to)) continue;
      sum += e.minutes;
    }
    return sum;
  }

  static String pacePerDayLabel({
    required List<SessionEntry> entries,
    required String activityId,
    int days = 30,
  }) {
    final total = minutesLastNDays(
      entries: entries,
      activityId: activityId,
      days: days,
    );
    final perDay = (total / days).round();
    return ActivityDetailsFormat.pacePerDayLabel(perDay);
  }
}

/// Goal steps + ETA helpers (progressive goals).
class ActivityDetailsGoals {
  static const List<int> goalStepsMinutes = <int>[
    10 * 60,
    50 * 60,
    100 * 60,
    250 * 60,
    500 * 60,
    1000 * 60,
    2000 * 60,
    3000 * 60,
    4000 * 60,
    5000 * 60,
    6000 * 60,
    7000 * 60,
    8000 * 60,
    9000 * 60,
    10000 * 60,
  ];

  static int currentGoalMinutes(int totalMinutes) {
    for (final g in goalStepsMinutes) {
      if (totalMinutes < g) return g;
    }
    return goalStepsMinutes.last;
  }

  static int previousGoalMinutes(int totalMinutes) {
    var prev = 0;
    for (final g in goalStepsMinutes) {
      if (totalMinutes < g) return prev;
      prev = g;
    }
    return prev;
  }

  static int? etaDaysToCurrentGoal({
    required List<SessionEntry> entries,
    required String activityId,
    required int totalMinutesAllTime,
    int paceDaysWindow = 30,
    DateTime? now,
  }) {
    final goal = currentGoalMinutes(totalMinutesAllTime);
    final remaining = goal - totalMinutesAllTime;
    if (remaining <= 0) return 0;

    final totalRecent = ActivityDetailsAggregate.minutesLastNDays(
      entries: entries,
      activityId: activityId,
      days: paceDaysWindow,
      now: now,
    );

    final pacePerDay = totalRecent / paceDaysWindow; // minutes/day
    if (pacePerDay <= 0.0) return null;

    return (remaining / pacePerDay).ceil();
  }
}

/// Backward-compatible facade so you don't have to refactor call sites immediately.
/// Feel free to gradually migrate usages to ActivityDetailsFormat/Aggregate/Goals.
class ActivityDetailsUtils {
  static int minutesThisWeek({
    required List<SessionEntry> entries,
    required String activityId,
    DateTime? now,
  }) =>
      ActivityDetailsAggregate.minutesThisWeek(
        entries: entries,
        activityId: activityId,
        now: now,
      );

  static int minutesLastNDays({
    required List<SessionEntry> entries,
    required String activityId,
    required int days,
    DateTime? now,
  }) =>
      ActivityDetailsAggregate.minutesLastNDays(
        entries: entries,
        activityId: activityId,
        days: days,
        now: now,
      );

  static String pacePerDayLabel({
    required List<SessionEntry> entries,
    required String activityId,
    int days = 30,
  }) =>
      ActivityDetailsAggregate.pacePerDayLabel(
        entries: entries,
        activityId: activityId,
        days: days,
      );

  static String formatHoursMinutes(int totalMinutes) =>
      ActivityDetailsFormat.formatHoursMinutes(totalMinutes);

  static const List<int> goalStepsMinutes = ActivityDetailsGoals.goalStepsMinutes;

  static int currentGoalMinutes(int totalMinutes) =>
      ActivityDetailsGoals.currentGoalMinutes(totalMinutes);

  static int previousGoalMinutes(int totalMinutes) =>
      ActivityDetailsGoals.previousGoalMinutes(totalMinutes);

  static int? etaDaysToCurrentGoal({
    required List<SessionEntry> entries,
    required String activityId,
    required int totalMinutesAllTime,
    int paceDaysWindow = 30,
    DateTime? now,
  }) =>
      ActivityDetailsGoals.etaDaysToCurrentGoal(
        entries: entries,
        activityId: activityId,
        totalMinutesAllTime: totalMinutesAllTime,
        paceDaysWindow: paceDaysWindow,
        now: now,
      );

  static String dailyLabel(DateTime d) => ActivityDetailsFormat.dailyLabel(d);
  static String monthLabel(DateTime m) => ActivityDetailsFormat.monthLabel(m);
}
