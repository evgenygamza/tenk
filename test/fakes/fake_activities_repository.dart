import 'dart:convert';

import 'package:tenk/features/activities/domain/models/activity.dart';
import 'package:tenk/features/activities/domain/repositories/activities_repository.dart';

/// Round-trips JSON so reload tests exercise the persisted model format.
class FakeActivitiesRepository implements ActivitiesRepository {
  FakeActivitiesRepository({List<Activity> seed = const []})
    : _json = jsonEncode(seed.map((a) => a.toJson()).toList());

  String _json;
  bool failSave = false;

  @override
  Future<List<Activity>> getActivities() async {
    return (jsonDecode(_json) as List<dynamic>)
        .map((item) => Activity.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> saveActivities(List<Activity> activities) async {
    if (failSave) throw StateError('Storage unavailable');
    _json = jsonEncode(activities.map((a) => a.toJson()).toList());
  }

  @override
  Future<void> clear() async => _json = '[]';
}
