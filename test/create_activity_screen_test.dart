import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tenk/app/app.dart';
import 'package:tenk/features/activities/domain/models/first_activity.dart';
import 'package:tenk/features/activities/domain/repositories/first_activity_repository.dart';
import 'package:tenk/features/activities/presentation/create_activity_screen.dart';
import 'package:tenk/screens/activities/activities_screen.dart';
import 'package:tenk/screens/welcome/welcome_screen.dart';
import 'package:tenk/ui/widgets/populated_activities_view.dart';

class _FakeRepository implements FirstActivityRepository {
  final saveCalls = <FirstActivity>[];
  Completer<void>? pendingSave;
  bool failNextSave = false;
  FirstActivity? storedActivity;

  @override
  Future<FirstActivity?> loadActivity() async => storedActivity;

  @override
  Future<void> saveActivity(FirstActivity activity) async {
    saveCalls.add(activity);
    final pending = pendingSave;
    if (pending != null) await pending.future;
    if (failNextSave) {
      failNextSave = false;
      throw Exception('save failed');
    }
    storedActivity = activity;
  }
}

Future<void> _openCreateActivity(
  WidgetTester tester,
  _FakeRepository repository,
) async {
  await tester.pumpWidget(App(firstActivityRepository: repository));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(WelcomeScreen.startButtonKey));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(ActivitiesScreen.addButtonKey));
  await tester.pumpAndSettle();
}

Future<void> _tapSave(WidgetTester tester) async {
  final saveButton = find.byKey(CreateActivityScreen.saveButtonKey);
  await tester.ensureVisible(saveButton);
  await tester.pumpAndSettle();
  await tester.tap(saveButton);
}

void main() {
  testWidgets('rejects an empty activity name', (tester) async {
    final repository = _FakeRepository();
    await _openCreateActivity(tester, repository);

    await _tapSave(tester);
    await tester.pump();

    expect(find.text('Enter an activity name'), findsOneWidget);
    expect(repository.saveCalls, isEmpty);
  });

  testWidgets('selects an icon and saves the trimmed activity name', (
    tester,
  ) async {
    final repository = _FakeRepository();
    await _openCreateActivity(tester, repository);

    await tester.tap(
      find.byKey(const ValueKey('create_activity_icon_instrument')),
    );
    await tester.enterText(
      find.byKey(CreateActivityScreen.nameFieldKey),
      '  Гитара  ',
    );
    await _tapSave(tester);
    await tester.pumpAndSettle();

    const activity = FirstActivity(name: 'Гитара', iconId: 'instrument');
    expect(repository.saveCalls, [activity]);
    expect(repository.storedActivity, activity);
    expect(find.byKey(PopulatedActivitiesView.viewKey), findsOneWidget);
    expect(find.byKey(PopulatedActivitiesView.tutorialKey), findsOneWidget);
    expect(find.text('Гитара'), findsOneWidget);
    expect(find.byKey(ActivitiesScreen.createOverlayKey), findsNothing);
  });

  testWidgets('limits names to 40 visible characters', (tester) async {
    final repository = _FakeRepository();
    await _openCreateActivity(tester, repository);

    await tester.enterText(
      find.byKey(CreateActivityScreen.nameFieldKey),
      'a' * 41,
    );
    await tester.pump();

    final asciiField = tester.widget<TextField>(
      find.byKey(CreateActivityScreen.nameFieldKey),
    );
    expect(
      asciiField.controller!.text,
      'a' * CreateActivityScreen.maxNameLength,
    );
    expect(asciiField.maxLength, CreateActivityScreen.maxNameLength);
    expect(repository.saveCalls, isEmpty);

    await tester.pumpWidget(const SizedBox.shrink());
    await _openCreateActivity(tester, repository);
    await tester.enterText(
      find.byKey(CreateActivityScreen.nameFieldKey),
      'e\u0301' * 41,
    );
    await tester.pump();
    final graphemeField = tester.widget<TextField>(
      find.byKey(CreateActivityScreen.nameFieldKey),
    );
    expect(
      graphemeField.controller!.text,
      'e\u0301' * CreateActivityScreen.maxNameLength,
    );
  });

  testWidgets('search filters the monochrome icon catalog', (tester) async {
    await _openCreateActivity(tester, _FakeRepository());

    await tester.enterText(
      find.byKey(CreateActivityScreen.searchFieldKey),
      'reading',
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('create_activity_icon_reading')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('create_activity_icon_instrument')),
      findsNothing,
    );
  });

  testWidgets('category filters the monochrome icon catalog', (tester) async {
    await _openCreateActivity(tester, _FakeRepository());

    await tester.tap(find.widgetWithText(ChoiceChip, 'Movement'));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('create_activity_icon_running')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('create_activity_icon_art')),
      findsNothing,
    );
  });

  testWidgets('icon catalog scrolls on a compact viewport', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 568);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await _openCreateActivity(tester, _FakeRepository());
    await tester.drag(find.byType(GridView), const Offset(0, -240));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('create_activity_icon_volunteering')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('ignores a repeated submit while saving', (tester) async {
    final repository = _FakeRepository()..pendingSave = Completer<void>();
    await _openCreateActivity(tester, repository);

    await tester.enterText(
      find.byKey(CreateActivityScreen.nameFieldKey),
      'Пианино',
    );
    await _tapSave(tester);
    await tester.pump();
    await tester.tap(find.byKey(CreateActivityScreen.saveButtonKey));
    await tester.pump();

    expect(repository.saveCalls, hasLength(1));

    repository.pendingSave!.complete();
    await tester.pumpAndSettle();
    expect(find.byKey(PopulatedActivitiesView.viewKey), findsOneWidget);
  });

  testWidgets('shows a save error and allows retry', (tester) async {
    final repository = _FakeRepository()..failNextSave = true;
    await _openCreateActivity(tester, repository);

    await tester.enterText(
      find.byKey(CreateActivityScreen.nameFieldKey),
      'Рисование',
    );
    await _tapSave(tester);
    await tester.pumpAndSettle();

    expect(find.byKey(CreateActivityScreen.saveErrorKey), findsOneWidget);
    expect(find.byKey(CreateActivityScreen.screenKey), findsOneWidget);

    await _tapSave(tester);
    await tester.pumpAndSettle();

    expect(repository.saveCalls, hasLength(2));
    expect(repository.storedActivity?.name, 'Рисование');
    expect(find.byKey(PopulatedActivitiesView.viewKey), findsOneWidget);
  });

  testWidgets('form remains usable on a small iPhone viewport', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 568);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await _openCreateActivity(tester, _FakeRepository());

    expect(find.byKey(CreateActivityScreen.nameFieldKey), findsOneWidget);
    expect(find.byKey(CreateActivityScreen.saveButtonKey), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
