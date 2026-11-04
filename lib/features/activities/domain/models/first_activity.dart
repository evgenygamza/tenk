class FirstActivity {
  const FirstActivity({required this.name, required this.iconId, this.id = ''});

  final String id;
  final String name;
  final String iconId;

  @override
  bool operator ==(Object other) =>
      other is FirstActivity &&
      other.id == id &&
      other.name == name &&
      other.iconId == iconId;

  @override
  int get hashCode => Object.hash(id, name, iconId);
}
