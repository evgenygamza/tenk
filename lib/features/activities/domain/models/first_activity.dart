class FirstActivity {
  const FirstActivity({required this.name, required this.iconId});

  final String name;
  final String iconId;

  @override
  bool operator ==(Object other) =>
      other is FirstActivity && other.name == name && other.iconId == iconId;

  @override
  int get hashCode => Object.hash(name, iconId);
}
