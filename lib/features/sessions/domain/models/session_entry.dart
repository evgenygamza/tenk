class SessionEntry {
  final String id;
  final String activityId;
  final DateTime startedAt;
  final int minutes;
  final String? note;

  const SessionEntry({
    required this.id,
    required this.activityId,
    required this.startedAt,
    required this.minutes,
    this.note,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'activityId': activityId,
    'startedAt': startedAt.toIso8601String(),
    'minutes': minutes,
    'note': note,
  };

  factory SessionEntry.fromJson(Map<String, dynamic> json) {
    return SessionEntry(
      id: json['id'] as String,
      activityId: (json['activityId'] as String?) ?? 'unknown',
      startedAt: DateTime.parse(json['startedAt'] as String),
      minutes: json['minutes'] as int,
      note: json['note'] as String?,
    );
  }
}
