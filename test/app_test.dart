import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tenk/app/app.dart';
import 'package:tenk/features/activities/domain/repositories/first_activity_repository.dart';
import 'package:tenk/screens/create_activity/create_activity_screen.dart';
import 'package:tenk/screens/home/home_screen.dart';
import 'package:tenk/screens/welcome/welcome_screen.dart';

class _Repository implements FirstActivityRepository {
  String? name;
  int loads = 0;
  bool fail = false;
  Completer<String?>? pending;

  @override
  Future<String?> loadName() async {
    loads++;
    if (fail) throw Exception('read failed');
    return pending == null ? name : pending!.future;
  }

  @override
  Future<void> saveName(String name) async => this.name = name;
}

void main() {
  testWidgets('first launch opens Welcome and creation', (tester) async {
    final repository = _Repository();
    await tester.pumpWidget(App(firstActivityRepository: repository));
    await tester.pumpAndSettle();
    expect(find.byType(WelcomeScreen), findsOneWidget);
    await tester.tap(find.byKey(WelcomeScreen.startButtonKey));
    await tester.pumpAndSettle();
    expect(find.byType(CreateActivityScreen), findsOneWidget);
    expect(repository.loads, 1);
  });

  testWidgets('waits for loading without flashing onboarding', (tester) async {
    final repository = _Repository()..pending = Completer<String?>();
    await tester.pumpWidget(App(firstActivityRepository: repository));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(WelcomeScreen), findsNothing);
    repository.pending!.complete('Гитара');
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Гитара'), findsOneWidget);
    await tester.pump();
    expect(repository.loads, 1);
  });

  testWidgets('saved activity survives an app restart', (tester) async {
    final repository = _Repository();
    await tester.pumpWidget(App(firstActivityRepository: repository));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(WelcomeScreen.startButtonKey));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(CreateActivityScreen.nameFieldKey),
      'Гитара',
    );
    await tester.tap(find.byKey(CreateActivityScreen.saveButtonKey));
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(App(firstActivityRepository: repository));
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Гитара'), findsOneWidget);
    expect(find.byType(WelcomeScreen), findsNothing);
    expect(
      tester.state<NavigatorState>(find.byType(Navigator)).canPop(),
      isFalse,
    );
    expect(repository.loads, 2);
  });

  testWidgets('blank stored name keeps creation accessible', (tester) async {
    await tester.pumpWidget(
      App(firstActivityRepository: _Repository()..name = '  '),
    );
    await tester.pumpAndSettle();
    expect(find.byType(WelcomeScreen), findsOneWidget);
  });

  testWidgets('load failure allows retry without losing saved activity', (
    tester,
  ) async {
    final repository = _Repository()
      ..name = 'Рисование'
      ..fail = true;
    await tester.pumpWidget(App(firstActivityRepository: repository));
    await tester.pumpAndSettle();
    expect(find.text('Не удалось загрузить занятие'), findsOneWidget);
    expect(find.byType(WelcomeScreen), findsNothing);
    expect(find.byType(HomeScreen), findsNothing);
    await tester.tap(find.text('Попробовать снова'));
    await tester.pumpAndSettle();
    expect(find.text('Не удалось загрузить занятие'), findsOneWidget);
    repository.fail = false;
    await tester.tap(find.text('Попробовать снова'));
    await tester.pumpAndSettle();
    expect(find.text('Рисование'), findsOneWidget);
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(repository.loads, 3);
    expect(tester.takeException(), isNull);
  });

  testWidgets('load retry can resolve to Welcome', (tester) async {
    final repository = _Repository()..fail = true;
    await tester.pumpWidget(App(firstActivityRepository: repository));
    await tester.pumpAndSettle();
    repository.fail = false;
    await tester.tap(find.text('Попробовать снова'));
    await tester.pumpAndSettle();
    expect(find.byType(WelcomeScreen), findsOneWidget);
  });

  testWidgets(
    'Home displays a long activity on a small screen with large text',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 568);
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      const name = 'Рисование и изучение пейзажей';
      await tester.pumpWidget(
        App(firstActivityRepository: _Repository()..name = name),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text(name));
      expect(find.text(name), findsOneWidget);
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
