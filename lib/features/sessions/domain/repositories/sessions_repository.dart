import 'package:tenk/features/sessions/domain/models/session_entry.dart';

abstract class SessionsRepository {
  Future<List<SessionEntry>> getEntries();
  Future<void> saveEntries(List<SessionEntry> entries);
  Future<void> clear();
}
