import 'package:flutter_test/flutter_test.dart';
import 'package:tenk/features/activities/domain/models/activity.dart';
import 'package:tenk/features/activities/domain/models/experience_calculator.dart';
import 'package:tenk/features/activities/presentation/state/activities_controller.dart';

import 'fakes/fake_activities_repository.dart';

void main() {
  test('estimates years and months and rounds once to the nearest minute', () {
    expect(
      ExperienceCalculator.estimateMinutes(
        years: 1,
        months: 2,
        hoursPerWeek: 10,
      ),
      36498,
    );
    expect(
      ExperienceCalculator.estimateMinutes(
        years: 0,
        months: 1,
        hoursPerWeek: 2.5,
      ),
      652,
    );
    expect(
      ExperienceCalculator.estimateMinutes(
        years: 100,
        months: 0,
        hoursPerWeek: 168,
      ),
      ExperienceCalculator.maxMinutes,
    );
  });

  test('rejects negative, empty, excessive and non-finite estimates', () {
    for (final (years, months, hours) in <(int, int, double)>[
      (-1, 2, 10),
      (0, -1, 10),
      (0, 0, 10),
      (0, 12, 10),
      (101, 0, 10),
      (100, 1, 10),
      (1, 0, 0),
      (1, 0, -2),
      (1, 0, 169),
      (1, 0, double.nan),
      (1, 0, double.infinity),
    ]) {
      expect(
        ExperienceCalculator.estimateMinutes(
          years: years,
          months: months,
          hoursPerWeek: hours,
        ),
        isNull,
      );
    }
  });

  test(
    'old activity JSON defaults to zero; new JSON and copy preserve experience',
    () {
      final old = <String, dynamic>{
        'id': 'guitar',
        'title': 'Guitar',
        'colorIndex': 0,
      };
      expect(Activity.fromJson(old).initialMinutes, 0);
      final activity = Activity.fromJson(old).copyWith(initialMinutes: 36498);
      final restored = Activity.fromJson(
        activity.toJson(),
      ).copyWith(title: 'Piano', colorIndex: 1);
      expect(restored.initialMinutes, 36498);
      expect(restored.copyWith(initialMinutes: 0).initialMinutes, 0);
      expect(
        Activity.fromJson({...old, 'initialMinutes': -1}).initialMinutes,
        0,
      );
    },
  );

  test(
    'replaces, persists, reloads and clears experience for only the chosen activity',
    () async {
      final repo = FakeActivitiesRepository(
        seed: const [
          Activity(id: 'guitar', title: 'Guitar', colorIndex: 0),
          Activity(
            id: 'piano',
            title: 'Piano',
            colorIndex: 1,
            initialMinutes: 20,
          ),
        ],
      );
      final controller = ActivitiesController(repo);
      addTearDown(controller.dispose);
      await Future<void>.delayed(Duration.zero);
      await controller.setInitialMinutes('guitar', 36498);
      await controller.setInitialMinutes('guitar', 120);
      expect(controller.activities.first.initialMinutes, 120);
      expect(controller.activities.last.initialMinutes, 20);

      final reloaded = ActivitiesController(repo);
      addTearDown(reloaded.dispose);
      await Future<void>.delayed(Duration.zero);
      expect(reloaded.activities.first.initialMinutes, 120);
      await reloaded.setInitialMinutes('guitar', 0);
      expect((await repo.getActivities()).first.initialMinutes, 0);
      await expectLater(
        reloaded.setInitialMinutes('guitar', -1),
        throwsArgumentError,
      );
      await reloaded.setInitialMinutes('missing', 10);
      expect(reloaded.activities.length, 2);
    },
  );

  test(
    'a failed save preserves the previous in-memory and stored total',
    () async {
      final repo = FakeActivitiesRepository(
        seed: const [
          Activity(
            id: 'guitar',
            title: 'Guitar',
            colorIndex: 0,
            initialMinutes: 60,
          ),
        ],
      );
      final controller = ActivitiesController(repo);
      addTearDown(controller.dispose);
      await Future<void>.delayed(Duration.zero);
      repo.failSave = true;
      await expectLater(
        controller.setInitialMinutes('guitar', 120),
        throwsStateError,
      );
      expect(controller.activities.single.initialMinutes, 60);
      expect((await repo.getActivities()).single.initialMinutes, 60);
    },
  );
}
