import 'package:tenk/features/timer/domain/models/daily_timer_data.dart';

abstract interface class DailyTimerRepository {
  Future<DailyTimerData> load();

  Future<void> save(DailyTimerData data);
}
