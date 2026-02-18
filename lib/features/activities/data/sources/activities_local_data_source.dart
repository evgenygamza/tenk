import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:tenk/features/activities/domain/models/activity.dart';

class ActivitiesLocalDataSource {
  static const _fileName = 'activities.json';

  Future<List<Activity>> getActivities() async {
    final file = await _file();
    if (!await file.exists()) return [];

    final raw = await file.readAsString();
    if (raw.trim().isEmpty) return [];

    final decoded = jsonDecode(raw);
    if (decoded is! List) return [];

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(Activity.fromJson)
        .toList();
  }

  Future<void> saveActivities(List<Activity> activities) async {
    final file = await _file();
    final data = activities.map((a) => a.toJson()).toList();
    await file.writeAsString(jsonEncode(data));
  }

  Future<void> clear() async {
    final file = await _file();
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }
}
