import 'package:flutter/foundation.dart';
import 'package:tenk/features/activities/domain/models/activity.dart';
import 'package:tenk/features/activities/domain/repositories/activities_repository.dart';

class ActivitiesController extends ChangeNotifier {
  final ActivitiesRepository _repo;

  List<Activity> activities = [];
  bool isLoaded = false;

  ActivitiesController(this._repo) {
    _load();
  }

  Future<void> _load() async {
    activities = await _repo.getActivities();
    isLoaded = true;
    notifyListeners();
  }

  Future<void> add(Activity activity) async {
    activities = [activity, ...activities];
    notifyListeners();
    await _repo.saveActivities(activities);
  }

  Future<void> update(Activity updated) async {
    final idx = activities.indexWhere((a) => a.id == updated.id);
    if (idx == -1) return;

    final copy = [...activities];
    copy[idx] = updated;

    activities = copy;
    notifyListeners();
    await _repo.saveActivities(activities);
  }

  Future<void> delete(String id) async {
    activities = activities.where((a) => a.id != id).toList();
    notifyListeners();
    await _repo.saveActivities(activities);
  }

  Future<void> resetAll() async {
    activities = [];
    notifyListeners();
    await _repo.clear();
  }
}
