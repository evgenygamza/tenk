class FirstActivity {
  const FirstActivity({
    required this.name,
    required this.iconId,
    this.id = '',
    this.initialMinutes = 0,
  }) : assert(initialMinutes >= 0);

  final String id;
  final String name;
  final String iconId;

  /// Experience accumulated before tracking sessions in the app.
  final int initialMinutes;

  @override
  bool operator ==(Object other) =>
      other is FirstActivity &&
      other.id == id &&
      other.name == name &&
      other.iconId == iconId &&
      other.initialMinutes == initialMinutes;

  @override
  int get hashCode => Object.hash(id, name, iconId, initialMinutes);
}
