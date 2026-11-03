import 'package:tenk/features/activities/domain/models/first_activity.dart';

abstract interface class FirstActivityRepository {
  Future<FirstActivity?> loadActivity();

  Future<void> saveActivity(FirstActivity activity);
}
