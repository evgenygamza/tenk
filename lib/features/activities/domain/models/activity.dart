class Activity {
  final String id;
  final String title;

  /// Index into your palette (keeps colors stable without storing raw Color).
  final int colorIndex;

  /// Optional: goal for progress scale, can be used later.
  final int? goalHours;

  /// Experience accumulated before tracking sessions in the app.
  final int initialMinutes;

  const Activity({
    required this.id,
    required this.title,
    required this.colorIndex,
    this.goalHours,
    this.initialMinutes = 0,
  }) : assert(initialMinutes >= 0);

  Activity copyWith({
    String? id,
    String? title,
    int? colorIndex,
    int? goalHours,
    int? initialMinutes,
  }) {
    return Activity(
      id: id ?? this.id,
      title: title ?? this.title,
      colorIndex: colorIndex ?? this.colorIndex,
      goalHours: goalHours ?? this.goalHours,
      initialMinutes: initialMinutes ?? this.initialMinutes,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'colorIndex': colorIndex,
    'goalHours': goalHours,
    'initialMinutes': initialMinutes,
  };

  factory Activity.fromJson(Map<String, dynamic> json) {
    final initialMinutes = (json['initialMinutes'] as num?)?.toInt() ?? 0;
    return Activity(
      id: json['id'] as String,
      title: json['title'] as String,
      colorIndex: (json['colorIndex'] as num?)?.toInt() ?? 0,
      goalHours: (json['goalHours'] as num?)?.toInt(),
      initialMinutes: initialMinutes < 0 ? 0 : initialMinutes,
    );
  }
}
