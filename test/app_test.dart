import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tenk/app/app.dart';
import 'package:tenk/features/activities/domain/models/first_activity.dart';
import 'package:tenk/features/activities/domain/repositories/first_activity_repository.dart';
import 'package:tenk/screens/activities/activities_screen.dart';
import 'package:tenk/features/activities/presentation/create_activity_screen.dart';
import 'package:tenk/ui/widgets/populated_activities_view.dart';
import 'package:tenk/screens/welcome/welcome_screen.dart';

class _Repository implements FirstActivityRepository {
  FirstActivity? activity;
  int loads = 0;
  bool fail = false;
  Completer<FirstActivity?>? pending;

  @override
  Future<FirstActivity?> loadActivity() async {
    loads++;
    if (fail) throw Exception('read failed');
    return pending == null ? activity : pending!.future;
  }

  @override
  Future<void> saveActivity(FirstActivity activity) async =>
      this.activity = activity;
}

void main() {
  testWidgets('first launch opens Welcome and empty activities', (
    tester,
  ) async {
    final repository = _Repository();
    await tester.pumpWidget(App(firstActivityRepository: repository));
    await tester.pumpAndSettle();
    expect(find.byType(WelcomeScreen), findsOneWidget);
    await tester.tap(find.byKey(WelcomeScreen.startButtonKey));
    await tester.pumpAndSettle();
    expect(find.byType(ActivitiesScreen), findsOneWidget);
    expect(find.byKey(ActivitiesScreen.emptyStateKey), findsOneWidget);
    expect(find.byType(CreateActivityScreen), findsNothing);
    expect(repository.loads, 1);
  });

  testWidgets('empty Activities opens and cancels the embedded form', (
    tester,
  ) async {
    final repository = _Repository();
    await tester.pumpWidget(App(firstActivityRepository: repository));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(WelcomeScreen.startButtonKey));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(ActivitiesScreen.addButtonKey));
    await tester.pumpAndSettle();

    expect(find.byType(ActivitiesScreen), findsOneWidget);
    expect(find.byType(CreateActivityScreen), findsOneWidget);
    expect(find.byKey(ActivitiesScreen.createOverlayKey), findsOneWidget);
    expect(repository.activity, isNull);

    await tester.tap(find.byKey(CreateActivityScreen.cancelButtonKey));
    await tester.pumpAndSettle();
    expect(find.byKey(ActivitiesScreen.emptyStateKey), findsOneWidget);
    expect(find.byType(CreateActivityScreen), findsNothing);
  });

  testWidgets(
    'system back cancels the embedded form before leaving Activities',
    (tester) async {
      await tester.pumpWidget(App(firstActivityRepository: _Repository()));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(WelcomeScreen.startButtonKey));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(ActivitiesScreen.addButtonKey));
      await tester.pumpAndSettle();

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.byType(CreateActivityScreen), findsNothing);
      expect(find.byKey(ActivitiesScreen.emptyStateKey), findsOneWidget);
    },
  );

  testWidgets('waits for loading without flashing onboarding', (tester) async {
    final repository = _Repository()..pending = Completer<FirstActivity?>();
    await tester.pumpWidget(App(firstActivityRepository: repository));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(WelcomeScreen), findsNothing);
    repository.pending!.complete(
      const FirstActivity(name: 'Гитара', iconId: 'instrument'),
    );
    await tester.pumpAndSettle();
    expect(find.byType(PopulatedActivitiesView), findsOneWidget);
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
    await tester.tap(find.byKey(ActivitiesScreen.addButtonKey));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(CreateActivityScreen.nameFieldKey),
      'Гитара',
    );
    await tester.tap(
      find.byKey(const ValueKey('create_activity_icon_instrument')),
    );
    final saveButton = find.byKey(CreateActivityScreen.saveButtonKey);
    await tester.ensureVisible(saveButton);
    await tester.pumpAndSettle();
    await tester.tap(saveButton);
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(App(firstActivityRepository: repository));
    await tester.pumpAndSettle();
    expect(find.byType(PopulatedActivitiesView), findsOneWidget);
    expect(find.text('Гитара'), findsOneWidget);
    expect(find.byIcon(Icons.library_music), findsAtLeastNWidgets(1));
    expect(find.byType(WelcomeScreen), findsNothing);
    expect(
      tester.state<NavigatorState>(find.byType(Navigator)).canPop(),
      isFalse,
    );
    expect(repository.loads, 2);
  });

  testWidgets('blank stored name keeps creation accessible', (tester) async {
    await tester.pumpWidget(
      App(
        firstActivityRepository: _Repository()
          ..activity = const FirstActivity(name: '  ', iconId: 'sparkles'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(WelcomeScreen), findsOneWidget);
  });

  testWidgets('load failure allows retry without losing saved activity', (
    tester,
  ) async {
    final repository = _Repository()
      ..activity = const FirstActivity(name: 'Рисование', iconId: 'art')
      ..fail = true;
    await tester.pumpWidget(App(firstActivityRepository: repository));
    await tester.pumpAndSettle();
    expect(find.text('Could not load your activity'), findsOneWidget);
    expect(find.byType(WelcomeScreen), findsNothing);
    expect(find.byType(PopulatedActivitiesView), findsNothing);
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.text('Could not load your activity'), findsOneWidget);
    repository.fail = false;
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.text('Рисование'), findsOneWidget);
    expect(find.byType(PopulatedActivitiesView), findsOneWidget);
    expect(repository.loads, 3);
    expect(tester.takeException(), isNull);
  });

  testWidgets('load retry can resolve to Welcome', (tester) async {
    final repository = _Repository()..fail = true;
    await tester.pumpWidget(App(firstActivityRepository: repository));
    await tester.pumpAndSettle();
    repository.fail = false;
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.byType(WelcomeScreen), findsOneWidget);
  });

  testWidgets(
    'Activities displays a long activity on a small screen with large text',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 568);
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      const name = 'Рисование и изучение пейзажей';
      await tester.pumpWidget(
        App(
          firstActivityRepository: _Repository()
            ..activity = FirstActivity(name: name, iconId: 'art'),
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text(name));
      expect(find.text(name), findsOneWidget);
      expect(find.byType(PopulatedActivitiesView), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
