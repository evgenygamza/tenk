import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tenk/app/app.dart';
import 'package:tenk/features/activities/domain/repositories/first_activity_repository.dart';
import 'package:tenk/features/activities/presentation/screens/create_activity_screen.dart';
import 'package:tenk/features/activities/presentation/screens/home_screen.dart';
import 'package:tenk/features/onboarding/presentation/screens/welcome_screen.dart';

class _FakeRepository implements FirstActivityRepository {
  final saveCalls = <String>[];
  Completer<void>? pendingSave;
  bool failNextSave = false;
  String? storedName;

  @override
  Future<String?> loadName() async => storedName;

  @override
  Future<void> saveName(String name) async {
    saveCalls.add(name);
    final pending = pendingSave;
    if (pending != null) await pending.future;
    if (failNextSave) {
      failNextSave = false;
      throw Exception('save failed');
    }
    storedName = name;
  }
}

Future<void> _openCreateActivity(
  WidgetTester tester,
  FirstActivityRepository repository,
) async {
  await tester.pumpWidget(App(firstActivityRepository: repository));
  await tester.pumpAndSettle();
  await tester.ensureVisible(find.byKey(WelcomeScreen.startButtonKey));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(WelcomeScreen.startButtonKey));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('rejects an empty activity name', (tester) async {
    final repository = _FakeRepository();
    await _openCreateActivity(tester, repository);

    await tester.tap(find.byKey(CreateActivityScreen.saveButtonKey));
    await tester.pump();

    expect(find.text('Введи название занятия'), findsOneWidget);
    expect(repository.saveCalls, isEmpty);
  });

  testWidgets('trims and saves a valid activity name', (tester) async {
    final repository = _FakeRepository();
    await _openCreateActivity(tester, repository);

    await tester.enterText(
      find.byKey(CreateActivityScreen.nameFieldKey),
      '  Гитара  ',
    );
    await tester.tap(find.byKey(CreateActivityScreen.saveButtonKey));
    await tester.pumpAndSettle();

    expect(repository.saveCalls, ['Гитара']);
    expect(repository.storedName, 'Гитара');
    expect(find.byKey(HomeScreen.screenKey), findsOneWidget);
    expect(find.byKey(HomeScreen.tutorialKey), findsOneWidget);
    expect(find.text('Гитара'), findsOneWidget);
    expect(
      tester.state<NavigatorState>(find.byType(Navigator)).canPop(),
      isFalse,
    );
  });

  testWidgets('ignores a repeated submit while saving', (tester) async {
    final repository = _FakeRepository()..pendingSave = Completer<void>();
    await _openCreateActivity(tester, repository);

    await tester.enterText(
      find.byKey(CreateActivityScreen.nameFieldKey),
      'Пианино',
    );
    await tester.tap(find.byKey(CreateActivityScreen.saveButtonKey));
    await tester.pump();
    await tester.tap(find.byKey(CreateActivityScreen.saveButtonKey));
    await tester.pump();

    expect(repository.saveCalls, ['Пианино']);

    repository.pendingSave!.complete();
    await tester.pumpAndSettle();
    expect(find.byKey(HomeScreen.screenKey), findsOneWidget);
  });

  testWidgets('shows a save error and allows retry', (tester) async {
    final repository = _FakeRepository()..failNextSave = true;
    await _openCreateActivity(tester, repository);

    await tester.enterText(
      find.byKey(CreateActivityScreen.nameFieldKey),
      'Рисование',
    );
    await tester.tap(find.byKey(CreateActivityScreen.saveButtonKey));
    await tester.pumpAndSettle();

    expect(find.byKey(CreateActivityScreen.saveErrorKey), findsOneWidget);
    expect(find.byKey(CreateActivityScreen.screenKey), findsOneWidget);

    await tester.tap(find.byKey(CreateActivityScreen.saveButtonKey));
    await tester.pumpAndSettle();

    expect(repository.saveCalls, ['Рисование', 'Рисование']);
    expect(repository.storedName, 'Рисование');
    expect(find.byKey(HomeScreen.screenKey), findsOneWidget);
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
