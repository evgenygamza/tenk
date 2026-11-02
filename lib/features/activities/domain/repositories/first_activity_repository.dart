abstract interface class FirstActivityRepository {
  Future<String?> loadName();

  Future<void> saveName(String name);
}
