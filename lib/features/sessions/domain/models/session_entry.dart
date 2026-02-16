class SessionEntry {
  final String id;
  final DateTime startedAt;
  final int minutes;
  final String? note;

  const SessionEntry({
    required this.id,
    required this.startedAt,
    required this.minutes,
    this.note,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'startedAt': startedAt.toIso8601String(),
    'minutes': minutes,
    'note': note,
  };

  factory SessionEntry.fromJson(Map<String, dynamic> json) {
    return SessionEntry(
      id: json['id'] as String,
      startedAt: DateTime.parse(json['startedAt'] as String),
      minutes: json['minutes'] as int,
      note: json['note'] as String?,
    );
  }
}
