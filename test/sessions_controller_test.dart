import 'package:flutter_test/flutter_test.dart';
import 'package:tenk/features/sessions/domain/models/session_entry.dart';
import 'package:tenk/features/sessions/presentation/state/sessions_controller.dart';

import 'fakes/fake_sessions_repository.dart';

void main() {
  test('loads entries from repository on init', () async {
    final seed = [
      SessionEntry(
        id: '1',
        activityId: 'guitar',
        startedAt: DateTime(2026, 2, 16, 10, 0),
        minutes: 30,
      ),
    ];
    final repo = FakeSessionsRepository(seed: seed);

    final c = SessionsController(repo);

    // wait for async _load()
    await Future<void>.delayed(const Duration(milliseconds: 1));

    expect(c.entries.length, 1);
    expect(c.totalMinutesAllTime('guitar'), 30);
  });

  test('addManual adds entry and persists', () async {
    final repo = FakeSessionsRepository();
    final c = SessionsController(repo);

    await Future<void>.delayed(const Duration(milliseconds: 1));
    await c.addManual('guitar', 15, note: 'warmup');

    expect(c.entries.length, 1);
    expect(c.entries.first.activityId, 'guitar');
    expect(c.entries.first.minutes, 15);
    expect(c.entries.first.note, 'warmup');

    final stored = repo.store;
    expect(stored.length, 1);
    expect(stored.first.activityId, 'guitar');
    expect(stored.first.minutes, 15);
  });

  test('deleteEntry removes entry and persists', () async {
    final seed = [
      SessionEntry(
        id: 'a',
        activityId: 'guitar',
        startedAt: DateTime(2026, 2, 16, 10, 0),
        minutes: 10,
      ),
      SessionEntry(
        id: 'b',
        activityId: 'running',
        startedAt: DateTime(2026, 2, 16, 11, 0),
        minutes: 20,
      ),
    ];
    final repo = FakeSessionsRepository(seed: seed);
    final c = SessionsController(repo);

    await Future<void>.delayed(const Duration(milliseconds: 1));
    await c.deleteEntry('a');

    expect(c.entries.map((e) => e.id), ['b']);
    expect(repo.store.map((e) => e.id), ['b']);
  });

  test('updateEntry updates entry and persists', () async {
    final seed = [
      SessionEntry(
        id: 'a',
        activityId: 'guitar',
        startedAt: DateTime(2026, 2, 16, 10, 0),
        minutes: 10,
      ),
    ];
    final repo = FakeSessionsRepository(seed: seed);
    final c = SessionsController(repo);

    await Future<void>.delayed(const Duration(milliseconds: 1));

    final updated = SessionEntry(
      id: 'a',
      activityId: 'guitar',
      startedAt: DateTime(2026, 2, 16, 12, 0),
      minutes: 42,
      note: 'edited',
    );

    await c.updateEntry(updated);

    expect(c.entries.length, 1);
    expect(c.entries.first.minutes, 42);
    expect(c.entries.first.note, 'edited');
    expect(repo.store.first.minutes, 42);
  });

  test('stopAndSave creates entry with provided start/end', () async {
    final repo = FakeSessionsRepository();
    final c = SessionsController(repo);

    await Future<void>.delayed(const Duration(milliseconds: 1));

    final start = DateTime(2026, 2, 16, 10, 0);
    final end = DateTime(2026, 2, 16, 10, 45);

    await c.stopAndSave(
      activityId: 'guitar',
      startedAt: start,
      finishedAt: end,
      note: 'timer',
    );

    expect(c.entries.length, 1);
    expect(c.entries.first.activityId, 'guitar');
    expect(c.entries.first.startedAt, start);
    expect(c.entries.first.minutes, 45);
    expect(c.entries.first.note, 'timer');
  });

  test('resetActivity clears only that activity and persists', () async {
    final seed = [
      SessionEntry(
        id: 'a',
        activityId: 'climbing',
        startedAt: DateTime(2026, 2, 16, 10, 0),
        minutes: 10,
      ),
      SessionEntry(
        id: 'b',
        activityId: 'guitar',
        startedAt: DateTime(2026, 2, 16, 11, 0),
        minutes: 20,
      ),
    ];
    final repo = FakeSessionsRepository(seed: seed);
    final c = SessionsController(repo);

    await Future<void>.delayed(const Duration(milliseconds: 1));
    await c.resetActivity('climbing');

    expect(c.entries.map((e) => e.id), ['b']);
    expect(repo.store.map((e) => e.id), ['b']);
  });
}
