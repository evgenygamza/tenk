import 'package:tenk/features/activities/domain/models/activity.dart';

abstract class ActivitiesRepository {
  Future<List<Activity>> getActivities();
  Future<void> saveActivities(List<Activity> activities);
  Future<void> clear();
}
