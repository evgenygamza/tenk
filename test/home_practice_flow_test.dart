import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tenk/screens/activities/activities_screen.dart';
import 'package:tenk/screens/activities/widgets/activity_island.dart';
import 'package:tenk/screens/activities/widgets/activity_landmark.dart';
import 'package:tenk/ui/widgets/populated_activities_view.dart';
import 'package:tenk/ui/deprecated/practice_screen_prototype.dart';

void main() {
  Future<void> pumpActivities(
    WidgetTester tester, {
    bool showTutorial = true,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ActivitiesScreen(
          activityName: 'Гитара',
          showTutorial: showTutorial,
        ),
      ),
    );
  }

  testWidgets('Activities shows a dismissible first-practice tutorial', (
    tester,
  ) async {
    await pumpActivities(tester);

    expect(find.byKey(PopulatedActivitiesView.tutorialKey), findsOneWidget);
    expect(
      find.text('Start your first session to begin your journey.'),
      findsOneWidget,
    );

    final dismissButton = find.byKey(
      PopulatedActivitiesView.dismissTutorialKey,
    );
    await tester.ensureVisible(dismissButton);
    await tester.tap(dismissButton);
    await tester.pumpAndSettle();

    expect(find.byKey(PopulatedActivitiesView.tutorialKey), findsNothing);
    expect(find.byKey(PopulatedActivitiesView.startSessionKey), findsOneWidget);
  });

  testWidgets(
    'Practice remains on Activities until the timer widget is added',
    (tester) async {
      await pumpActivities(tester, showTutorial: false);

      await tester.tap(find.byKey(PopulatedActivitiesView.startSessionKey));
      await tester.pumpAndSettle();

      expect(find.byType(ActivitiesScreen), findsOneWidget);
      expect(find.byKey(PracticeScreen.screenKey), findsNothing);
      expect(find.text('Гитара'), findsOneWidget);
      expect(find.text('Start Session'), findsOneWidget);
    },
  );

  testWidgets('Activities shows the visual activity goal and selector', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    try {
      await pumpActivities(tester, showTutorial: false);

      expect(find.text('Гитара'), findsOneWidget);
      expect(find.text('TENK'), findsNothing);
      expect(find.bySemanticsLabel('100 hours'), findsOneWidget);
      expect(find.text('18 days to your goal'), findsOneWidget);
      expect(find.byIcon(Icons.library_music), findsAtLeastNWidgets(1));
      expect(
        find.byKey(const ValueKey('activities_selector_item_0')),
        findsOneWidget,
      );
      expect(find.byKey(ActivityLandmark.landmarkKey), findsOneWidget);
      expect(
        find.byKey(PopulatedActivitiesView.activitySelectorKey),
        findsOneWidget,
      );
      expect(
        find.byKey(PopulatedActivitiesView.addActivityVisualKey),
        findsOneWidget,
      );
      expect(
        find.byKey(PopulatedActivitiesView.startSessionKey),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('10,000-hour goal uses its dedicated landmark design', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    try {
      await tester.pumpWidget(
        const MaterialApp(
          home: Center(
            child: SizedBox(
              width: 180,
              height: 200,
              child: ActivityLandmark(hours: 10000),
            ),
          ),
        ),
      );

      expect(find.byKey(ActivityLandmark.landmarkKey), findsOneWidget);
      expect(find.bySemanticsLabel('10000 hours'), findsOneWidget);
    } finally {
      semantics.dispose();
    }
  });

  testWidgets(
    'Activities keeps the visual layout scrollable on a compact screen',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 568);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      await pumpActivities(tester, showTutorial: false);

      expect(find.byKey(PopulatedActivitiesView.goalKey), findsOneWidget);
      final islandSize = tester.getSize(
        find.byKey(PopulatedActivitiesView.goalKey),
      );
      final fitted = applyBoxFit(
        BoxFit.cover,
        ActivityIsland.artworkSize,
        islandSize,
      );
      final imageOffset = Offset(
        (islandSize.width - fitted.destination.width) / 2,
        (islandSize.height - fitted.destination.height) / 2,
      );
      final roadTip =
          imageOffset +
          Offset(
            fitted.destination.width * ActivityIsland.roadEndpointAnchor.dx,
            fitted.destination.height * ActivityIsland.roadEndpointAnchor.dy,
          );
      final landmarkRect = tester.getRect(
        find.byKey(ActivityLandmark.landmarkKey),
      );
      expect(landmarkRect.center.dx, closeTo(roadTip.dx, 1));
      expect(landmarkRect.bottom, closeTo(roadTip.dy, 1));
      await tester.ensureVisible(
        find.byKey(PopulatedActivitiesView.addActivityVisualKey),
      );
      expect(
        find.byKey(PopulatedActivitiesView.addActivityVisualKey),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

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
