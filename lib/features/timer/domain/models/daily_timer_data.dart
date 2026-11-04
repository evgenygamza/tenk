class DailyTimerData {
  const DailyTimerData({
    this.activeActivityId,
    this.runningSinceMilliseconds,
    this.totals = const {},
  });

  final String? activeActivityId;
  final int? runningSinceMilliseconds;
  final Map<String, Map<String, int>> totals;

  Map<String, dynamic> toJson() => {
    'activeActivityId': activeActivityId,
    'runningSinceMilliseconds': runningSinceMilliseconds,
    'totals': totals,
  };

  factory DailyTimerData.fromJson(Map<String, dynamic> json) {
    final rawTotals = json['totals'] as Map<String, dynamic>? ?? {};
    return DailyTimerData(
      activeActivityId: json['activeActivityId'] as String?,
      runningSinceMilliseconds: json['runningSinceMilliseconds'] as int?,
      totals: {
        for (final entry in rawTotals.entries)
          entry.key: {
            for (final total in (entry.value as Map<String, dynamic>).entries)
              total.key: total.value as int,
          },
      },
    );
  }
}
