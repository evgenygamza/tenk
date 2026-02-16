import 'package:tenk/features/sessions/domain/models/session_entry.dart';
import 'package:tenk/features/sessions/domain/repositories/sessions_repository.dart';

class FakeSessionsRepository implements SessionsRepository {
  List<SessionEntry> _store;

  FakeSessionsRepository({List<SessionEntry>? seed})
    : _store = [...(seed ?? [])];

  @override
  Future<List<SessionEntry>> getEntries() async => [..._store];

  @override
  Future<void> saveEntries(List<SessionEntry> entries) async {
    _store = [...entries];
  }

  @override
  Future<void> clear() async {
    _store = [];
  }

  List<SessionEntry> get store => [..._store];
}
