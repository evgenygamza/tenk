import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tenk/app/app.dart';
import 'package:tenk/screens/create_activity/create_activity_screen.dart';
import 'package:tenk/features/activities/domain/repositories/first_activity_repository.dart';
import 'package:tenk/screens/welcome/welcome_screen.dart';

class _NoopRepository implements FirstActivityRepository {
  @override
  Future<String?> loadName() async => null;

  @override
  Future<void> saveName(String name) async {}
}

void main() {
  testWidgets('shows the Welcome message and one primary action', (
    tester,
  ) async {
    await tester.pumpWidget(App(firstActivityRepository: _NoopRepository()));
    await tester.pumpAndSettle();

    expect(find.text('TENK'), findsOneWidget);
    expect(find.text('Время становится\nмастерством'), findsOneWidget);
    expect(find.text('Начать'), findsOneWidget);
    expect(find.byType(FilledButton), findsOneWidget);
  });

  testWidgets('Start opens the first-activity step', (tester) async {
    await tester.pumpWidget(App(firstActivityRepository: _NoopRepository()));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(WelcomeScreen.startButtonKey));
    await tester.pumpAndSettle();

    expect(find.byKey(CreateActivityScreen.screenKey), findsOneWidget);
    expect(find.text('Первое занятие'), findsOneWidget);
  });

  testWidgets('Welcome remains usable on a small iPhone viewport', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 568);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(App(firstActivityRepository: _NoopRepository()));
    await tester.pumpAndSettle();

    expect(find.byKey(WelcomeScreen.startButtonKey), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
