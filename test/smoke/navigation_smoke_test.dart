import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tenk/app/app.dart';
import 'package:tenk/testing/app_keys.dart';

void main() {
  group('Navigation smoke tests', () {
    testWidgets('App opens Dashboard screen', (tester) async {
      FlutterErrorDetails? captured;
      final oldOnError = FlutterError.onError;
      FlutterError.onError = (details) => captured ??= details;

      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();

      FlutterError.onError = oldOnError;

      expect(captured, isNull);
      expect(find.byKey(AppKeys.screenDashboard), findsOneWidget);
    });

    testWidgets('Can switch to History and Settings tabs', (tester) async {
      FlutterErrorDetails? captured;
      final oldOnError = FlutterError.onError;
      FlutterError.onError = (details) => captured ??= details;

      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();

      // History
      await tester.tap(find.byKey(AppKeys.tabHistory));
      await tester.pumpAndSettle();
      expect(find.byKey(AppKeys.screenHistory), findsOneWidget);

      // Settings
      await tester.tap(find.byKey(AppKeys.tabSettings));
      await tester.pumpAndSettle();
      expect(find.byKey(AppKeys.screenSettings), findsOneWidget);

      // Back to Dashboard
      await tester.tap(find.byKey(AppKeys.tabDashboard));
      await tester.pumpAndSettle();
      expect(find.byKey(AppKeys.screenDashboard), findsOneWidget);

      FlutterError.onError = oldOnError;
      expect(captured, isNull);
    });
  });
}
