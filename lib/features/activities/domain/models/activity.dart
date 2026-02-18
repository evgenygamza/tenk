class Activity {
  final String id;
  final String title;

  /// Index into your palette (keeps colors stable without storing raw Color).
  final int colorIndex;

  /// Optional: goal for progress scale, can be used later.
  final int? goalHours;

  const Activity({
    required this.id,
    required this.title,
    required this.colorIndex,
    this.goalHours,
  });

  Activity copyWith({
    String? id,
    String? title,
    int? colorIndex,
    int? goalHours,
  }) {
    return Activity(
      id: id ?? this.id,
      title: title ?? this.title,
      colorIndex: colorIndex ?? this.colorIndex,
      goalHours: goalHours ?? this.goalHours,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'colorIndex': colorIndex,
    'goalHours': goalHours,
  };

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'] as String,
      title: json['title'] as String,
      colorIndex: (json['colorIndex'] as num?)?.toInt() ?? 0,
      goalHours: (json['goalHours'] as num?)?.toInt(),
    );
  }
}
