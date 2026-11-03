import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tenk/app/app.dart';
import 'package:tenk/screens/create_activity/create_activity_screen.dart';
import 'package:tenk/features/activities/domain/repositories/first_activity_repository.dart';
import 'package:tenk/screens/welcome/welcome_screen.dart';
import 'package:tenk/ui/widgets/liquid_glass_button.dart';

class _NoopRepository implements FirstActivityRepository {
  @override
  Future<String?> loadName() async => null;

  @override
  Future<void> saveName(String name) async {}
}

void main() {
  testWidgets('shows the English Welcome message and glass primary action', (
    tester,
  ) async {
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

    final titleRect = tester.getRect(find.text('Time Becomes\nMastery'));
    final descriptionRect = tester.getRect(
      find.text(
        'Choose an activity, dedicate time to it, and watch your progress grow.',
      ),
    );
    final buttonRect = tester.getRect(find.byKey(WelcomeScreen.startButtonKey));
    final titleToDescriptionGap = descriptionRect.top - titleRect.bottom;
    final descriptionToButtonGap = buttonRect.top - descriptionRect.bottom;
    expect(titleToDescriptionGap, closeTo(descriptionToButtonGap, 1));

    final background = tester.widget<Image>(find.byType(Image).first);
    expect(
      (background.image as AssetImage).assetName,
      WelcomeScreen.backgroundAsset,
    );
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
