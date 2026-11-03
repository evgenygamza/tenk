import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tenk/features/activities/presentation/screens/home_screen.dart';
import 'package:tenk/features/activities/presentation/screens/practice_screen.dart';

void main() {
  Future<void> pumpHome(
    WidgetTester tester, {
    bool showTutorial = true,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(
          activityName: 'Гитара',
          showTutorial: showTutorial,
        ),
      ),
    );
  }

  testWidgets('Home shows a dismissible first-practice tutorial', (
    tester,
  ) async {
    await pumpHome(tester);

    expect(find.byKey(HomeScreen.tutorialKey), findsOneWidget);
    expect(
      find.text('Запусти первое занятие, чтобы начать свой путь.'),
      findsOneWidget,
    );

    final dismissButton = find.byKey(HomeScreen.dismissTutorialKey);
    await tester.ensureVisible(dismissButton);
    await tester.tap(dismissButton);
    await tester.pumpAndSettle();

    expect(find.byKey(HomeScreen.tutorialKey), findsNothing);
    expect(find.byKey(HomeScreen.startPracticeKey), findsOneWidget);
  });

  testWidgets('Home opens the practice timer', (tester) async {
    await pumpHome(tester, showTutorial: false);

    await tester.tap(find.byKey(HomeScreen.startPracticeKey));
    await tester.pumpAndSettle();

    expect(find.byKey(PracticeScreen.screenKey), findsOneWidget);
    expect(find.text('Гитара'), findsOneWidget);
    expect(find.text('00:00:00'), findsOneWidget);
  });

  testWidgets('Practice timer starts and pauses without losing elapsed time', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: PracticeScreen(activityName: 'Гитара')),
    );

    await tester.tap(find.byKey(PracticeScreen.toggleButtonKey));
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('00:00:02'), findsOneWidget);

    await tester.tap(find.byKey(PracticeScreen.toggleButtonKey));
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('00:00:02'), findsOneWidget);
  });
}
