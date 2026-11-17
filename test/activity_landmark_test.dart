import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tenk/screens/activities/widgets/activity_landmark.dart';

void main() {
  const assetsByHours = <int, String>{
    10: 'lib/ui/graphics/landmark_10_hours_angled.png',
    50: 'lib/ui/graphics/landmark_50_hours_angled.png',
    100: 'lib/ui/graphics/landmark_100_hours_angled.png',
    250: 'lib/ui/graphics/landmark_250_hours_angled.png',
    500: 'lib/ui/graphics/landmark_500_hours_angled.png',
    1000: 'lib/ui/graphics/landmark_1000_hours_angled.png',
    2000: 'lib/ui/graphics/landmark_2000_hours_angled.png',
    3000: 'lib/ui/graphics/landmark_3000_hours_angled.png',
    4000: 'lib/ui/graphics/landmark_4000_hours_angled.png',
    5000: 'lib/ui/graphics/landmark_5000_hours_angled.png',
    6000: 'lib/ui/graphics/landmark_6000_hours_angled.png',
    7000: 'lib/ui/graphics/landmark_7000_hours_angled.png',
    8000: 'lib/ui/graphics/landmark_8000_hours_angled.png',
    9000: 'lib/ui/graphics/landmark_9000_hours_angled.png',
    10000: 'lib/ui/graphics/landmark_10000_hours_angled.png',
  };

  for (final entry in assetsByHours.entries) {
    testWidgets('${entry.key} hours uses its dedicated landmark', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      try {
        await tester.pumpWidget(
          MaterialApp(
            home: SizedBox(
              width: 200,
              height: 260,
              child: ActivityLandmark(hours: entry.key),
            ),
          ),
        );

        final image = tester.widget<Image>(find.byType(Image));
        expect(image.image, isA<AssetImage>());
        expect((image.image as AssetImage).assetName, entry.value);
        expect(find.byKey(ActivityLandmark.landmarkKey), findsOneWidget);
        expect(find.bySemanticsLabel('${entry.key} hours'), findsOneWidget);
      } finally {
        semantics.dispose();
      }
    });
  }
}
