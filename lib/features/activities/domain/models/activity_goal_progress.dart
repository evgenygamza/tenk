class ActivityGoalProgress {
  const ActivityGoalProgress({
    required this.previousGoalHours,
    required this.goalHours,
    required this.totalMinutes,
    required this.progress,
    required this.estimatedDays,
  });

  static const defaultPaceWindowDays = 30;
  static const goalStepsHours = <int>[
    10,
    50,
    100,
    250,
    500,
    1000,
    2000,
    3000,
    4000,
    5000,
    6000,
    7000,
    8000,
    9000,
    10000,
  ];

  final int previousGoalHours;
  final int goalHours;
  final int totalMinutes;
  final double progress;
  final int? estimatedDays;

  factory ActivityGoalProgress.calculate({
    required int totalMinutes,
    required int recentMinutes,
    int paceWindowDays = defaultPaceWindowDays,
  }) {
    if (paceWindowDays <= 0) {
      throw ArgumentError.value(
        paceWindowDays,
        'paceWindowDays',
        'Must be positive',
      );
    }

    final total = totalMinutes.clamp(0, 10000 * 60).toInt();
    var goal = goalStepsHours.last;
    var previous = goalStepsHours[goalStepsHours.length - 2];
    for (var index = 0; index < goalStepsHours.length; index++) {
      if (total < goalStepsHours[index] * 60) {
        goal = goalStepsHours[index];
        previous = index == 0 ? 0 : goalStepsHours[index - 1];
        break;
      }
    }

    final previousMinutes = previous * 60;
    final goalMinutes = goal * 60;
    final progress = total >= goalMinutes
        ? 1.0
        : ((total - previousMinutes) / (goalMinutes - previousMinutes))
              .clamp(0.0, 1.0)
              .toDouble();
    final remainingMinutes = goalMinutes - total;
    final estimatedDays = remainingMinutes <= 0
        ? 0
        : recentMinutes <= 0
        ? null
        : (remainingMinutes * paceWindowDays / recentMinutes).ceil();

    return ActivityGoalProgress(
      previousGoalHours: previous,
      goalHours: goal,
      totalMinutes: total,
      progress: progress,
      estimatedDays: estimatedDays,
    );
  }
}
