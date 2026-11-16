import 'package:flutter_test/flutter_test.dart';
import 'package:tenk/features/activities/domain/models/activity_goal_progress.dart';

void main() {
  test('selects the next goal at every milestone boundary', () {
    final beforeTenHours = ActivityGoalProgress.calculate(
      totalMinutes: 9 * 60 + 59,
      recentMinutes: 0,
    );
    final atTenHours = ActivityGoalProgress.calculate(
      totalMinutes: 10 * 60,
      recentMinutes: 0,
    );

    expect(beforeTenHours.goalHours, 10);
    expect(beforeTenHours.previousGoalHours, 0);
    expect(atTenHours.goalHours, 50);
    expect(atTenHours.previousGoalHours, 10);
    expect(atTenHours.progress, 0);

    for (
      var index = 0;
      index < ActivityGoalProgress.goalStepsHours.length;
      index++
    ) {
      final step = ActivityGoalProgress.goalStepsHours[index];
      final result = ActivityGoalProgress.calculate(
        totalMinutes: step * 60,
        recentMinutes: 0,
      );
      expect(
        result.goalHours,
        index == ActivityGoalProgress.goalStepsHours.length - 1
            ? step
            : ActivityGoalProgress.goalStepsHours[index + 1],
      );
    }
  });

  test('measures progress between the previous and next goals', () {
    final result = ActivityGoalProgress.calculate(
      totalMinutes: 30 * 60,
      recentMinutes: 600,
    );

    expect(result.previousGoalHours, 10);
    expect(result.goalHours, 50);
    expect(result.progress, 0.5);
    expect(result.estimatedDays, 60);
  });

  test('uses a shorter observed history for a new activity', () {
    final result = ActivityGoalProgress.calculate(
      totalMinutes: 2 * 60,
      recentMinutes: 2 * 60,
      paceWindowDays: 4,
    );

    expect(result.goalHours, 10);
    expect(result.progress, 0.2);
    expect(result.estimatedDays, 16);
  });

  test(
    'hides the estimate without recent practice and caps at 10000 hours',
    () {
      final noRecentPractice = ActivityGoalProgress.calculate(
        totalMinutes: 2 * 60,
        recentMinutes: 0,
      );
      final completed = ActivityGoalProgress.calculate(
        totalMinutes: 12000 * 60,
        recentMinutes: 0,
      );

      expect(noRecentPractice.estimatedDays, isNull);
      expect(completed.totalMinutes, 10000 * 60);
      expect(completed.goalHours, 10000);
      expect(completed.progress, 1);
      expect(completed.estimatedDays, 0);
    },
  );
}
