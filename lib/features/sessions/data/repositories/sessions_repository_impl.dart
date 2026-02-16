import '../../domain/models/session_entry.dart';
import '../../domain/repositories/sessions_repository.dart';
import '../sources/sessions_local_data_source.dart';

class SessionsRepositoryImpl implements SessionsRepository {
  final SessionsLocalDataSource _local;

  SessionsRepositoryImpl(this._local);

  @override
  Future<List<SessionEntry>> getEntries() {
    return _local.loadEntries();
  }

  @override
  Future<void> saveEntries(List<SessionEntry> entries) {
    return _local.saveEntries(entries);
  }

  @override
  Future<void> clear() {
    return _local.clear();
  }
}
