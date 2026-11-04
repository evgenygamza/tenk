import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:tenk/app/app.dart';
import 'package:tenk/features/activities/domain/models/first_activity.dart';
import 'package:tenk/features/activities/domain/repositories/first_activity_repository.dart';
import 'package:tenk/screens/activities/activities_screen.dart';
import 'package:tenk/screens/activities/widgets/activity_landmark.dart';
import 'package:tenk/screens/activities/widgets/activity_question_mark.dart';
import 'package:tenk/screens/welcome/welcome_screen.dart';
import 'package:tenk/ui/widgets/liquid_glass_button.dart';

class _NoopRepository implements FirstActivityRepository {
  @override
  Future<List<FirstActivity>> loadActivities() async => [];

  @override
  Future<void> saveActivities(
    List<FirstActivity> activities, {
    int? selectedIndex,
  }) async {}

  @override
  Future<int> loadSelectedActivityIndex() async => 0;

  @override
  Future<void> saveSelectedActivityIndex(int index) async {}
}

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  tearDown(() {
    SharedPreferencesAsyncPlatform.instance = null;
  });

  testWidgets('shows the English Welcome message and glass primary action', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    try {
      await tester.pumpWidget(App(firstActivityRepository: _NoopRepository()));
      await tester.pumpAndSettle();

      expect(find.text('TENK'), findsOneWidget);
      expect(find.text('Time Becomes\nMastery'), findsOneWidget);
      expect(
        find.text(
          'Choose an activity, dedicate time to it, and watch your progress grow.',
        ),
        findsOneWidget,
      );
      expect(find.text('Get Started'), findsOneWidget);
      expect(find.byType(LiquidGlassButton), findsOneWidget);
      expect(find.byKey(ActivityLandmark.landmarkKey), findsOneWidget);
      expect(find.bySemanticsLabel('10000 hours'), findsOneWidget);

      final titleRect = tester.getRect(find.text('Time Becomes\nMastery'));
      final descriptionRect = tester.getRect(
        find.text(
          'Choose an activity, dedicate time to it, and watch your progress grow.',
        ),
      );
      final buttonRect = tester.getRect(
        find.byKey(WelcomeScreen.startButtonKey),
      );
      final titleToDescriptionGap = descriptionRect.top - titleRect.bottom;
      final descriptionToButtonGap = buttonRect.top - descriptionRect.bottom;
      expect(titleToDescriptionGap, closeTo(descriptionToButtonGap, 1));

      final background = tester.widget<Image>(find.byType(Image).first);
      expect(
        (background.image as AssetImage).assetName,
        WelcomeScreen.backgroundAsset,
      );
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('Start opens the empty activities screen', (tester) async {
    await tester.pumpWidget(App(firstActivityRepository: _NoopRepository()));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(WelcomeScreen.startButtonKey));
    await tester.pumpAndSettle();

    expect(find.byKey(ActivitiesScreen.screenKey), findsOneWidget);
    expect(find.byKey(ActivitiesScreen.emptyStateKey), findsOneWidget);
    expect(find.text('Add your first\nactivity'), findsOneWidget);
    expect(find.byKey(ActivityQuestionMark.questionMarkKey), findsOneWidget);
    expect(find.byKey(ActivitiesScreen.addButtonKey), findsOneWidget);
  });

  testWidgets('Visible back button returns from empty Activities to Welcome', (
    tester,
  ) async {
    await tester.pumpWidget(App(firstActivityRepository: _NoopRepository()));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(WelcomeScreen.startButtonKey));
    await tester.pumpAndSettle();

    final backButton = find.byKey(ActivitiesScreen.backButtonKey);
    expect(backButton, findsOneWidget);
    await tester.tap(backButton);
    await tester.pumpAndSettle();

    expect(find.byType(WelcomeScreen), findsOneWidget);
    expect(find.byType(ActivitiesScreen), findsNothing);
  });

  testWidgets('Back from the empty activities screen returns to Welcome', (
    tester,
  ) async {
    await tester.pumpWidget(App(firstActivityRepository: _NoopRepository()));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(WelcomeScreen.startButtonKey));
    await tester.pumpAndSettle();

    expect(await tester.binding.handlePopRoute(), isTrue);
    await tester.pumpAndSettle();

    expect(find.byType(WelcomeScreen), findsOneWidget);
    expect(find.byType(ActivitiesScreen), findsNothing);
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
    await tester.tap(find.byKey(WelcomeScreen.startButtonKey));
    await tester.pumpAndSettle();
    expect(find.byKey(ActivitiesScreen.screenKey), findsOneWidget);
    expect(find.byKey(ActivitiesScreen.addButtonKey), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
