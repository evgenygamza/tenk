import 'package:tenk/features/activities/data/sources/activities_local_data_source.dart';
import 'package:tenk/features/activities/domain/models/activity.dart';
import 'package:tenk/features/activities/domain/repositories/activities_repository.dart';

class ActivitiesRepositoryImpl implements ActivitiesRepository {
  final ActivitiesLocalDataSource _local;

  ActivitiesRepositoryImpl(this._local);

  @override
  Future<List<Activity>> getActivities() => _local.getActivities();

  @override
  Future<void> saveActivities(List<Activity> activities) =>
      _local.saveActivities(activities);

  @override
  Future<void> clear() => _local.clear();
}
