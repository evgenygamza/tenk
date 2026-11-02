import 'package:flutter_test/flutter_test.dart';
import 'package:tenk/features/sessions/domain/models/session_entry.dart';
import 'package:tenk/features/sessions/presentation/screens/activity_details/activity_details_utils.dart';

SessionEntry entry(
  String id,
  DateTime date,
  int minutes, {
  String activity = 'guitar',
}) {
  return SessionEntry(
    id: id,
    activityId: activity,
    startedAt: date,
    minutes: minutes,
  );
}

void main() {
  test('November window includes last December, not next December', () {
    final bars = ActivityDetailsUtils.monthlyBars(
      activityId: 'guitar',
      now: DateTime(2026, 11, 2),
      entries: [
        entry('previous-december', DateTime(2025, 12, 15), 30),
        entry('current-month', DateTime(2026, 11, 1), 45),
        entry('future-december', DateTime(2026, 12, 15), 999),
        entry('outside-window', DateTime(2025, 11, 30), 100),
        entry('other-activity', DateTime(2025, 12, 15), 100, activity: 'piano'),
      ],
    );

    expect(bars.length, 12);
    expect(bars.first.label, 'Dec');
    expect(bars.first.minutes, 30);
    expect(bars[1].label, '2026 Jan');
    expect(bars[1].minutes, 0);
    expect(bars.last.label, 'Nov');
    expect(bars.last.minutes, 45);
    expect(bars.fold<int>(0, (total, bar) => total + bar.minutes), 75);
  });

  test('January window keeps previous-year months in chronological order', () {
    final bars = ActivityDetailsAggregate.monthlyBars(
      activityId: 'guitar',
      now: DateTime(2026, 1, 15),
      months: 3,
      entries: [
        entry('november', DateTime(2025, 11, 1), 20),
        entry('december', DateTime(2025, 12, 31), 40),
        entry('january', DateTime(2026, 1, 1), 10),
      ],
    );

    expect(bars.map((bar) => bar.label), ['Nov', 'Dec', '2026 Jan']);
    expect(bars.map((bar) => bar.minutes), [20, 40, 10]);
  });
}
