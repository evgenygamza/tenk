import 'package:tenk/features/activities/domain/models/first_activity.dart';

abstract interface class FirstActivityRepository {
  Future<List<FirstActivity>> loadActivities();

  Future<void> saveActivities(
    List<FirstActivity> activities, {
    int? selectedIndex,
  });

  Future<int> loadSelectedActivityIndex();

  Future<void> saveSelectedActivityIndex(int index);
}
