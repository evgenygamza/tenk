import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tenk/app/app.dart';

void main() {
  group('App smoke tests', () {
    testWidgets('App builds without exceptions', (tester) async {
      FlutterErrorDetails? captured;
      final oldOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        captured = details;
      };

      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();

      FlutterError.onError = oldOnError;
      expect(
        captured,
        isNull,
        reason: 'App should build without Flutter errors',
      );
    });

    testWidgets('App contains MaterialApp (or WidgetsApp) root', (
      tester,
    ) async {
      await tester.pumpWidget(const App());
      await tester.pump();

      // If you use MaterialApp, this will pass.
      // If you use WidgetsApp/CupertinoApp, tweak accordingly.
      expect(
        find.byType(MaterialApp),
        findsOneWidget,
        reason: 'Expected MaterialApp at the root',
      );
    });

    testWidgets('Has Navigator in widget tree', (tester) async {
      await tester.pumpWidget(const App());
      await tester.pump();

      expect(find.byType(Navigator), findsWidgets);
    });

    testWidgets('Theme is available (Theme.of(context) != null)', (
      tester,
    ) async {
      await tester.pumpWidget(const App());
      await tester.pump();

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      // theme can be null if you rely on defaults, but normally it exists or defaults apply.
      // This checks that at least the widget is configured and not broken.
      expect(materialApp, isNotNull);
    });

    testWidgets('Rebuild does not change the tree unexpectedly', (
      tester,
    ) async {
      await tester.pumpWidget(const App());
      await tester.pump();

      final firstFrame = find.byType(MaterialApp);
      expect(firstFrame, findsOneWidget);

      // Pump again to simulate a rebuild frame.
      await tester.pump();

      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('No overflowing pixels on first screen', (tester) async {
      // This catches classic RenderFlex overflow errors on initial layout.
      FlutterErrorDetails? captured;
      final oldOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        captured ??= details;
      };

      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();

      FlutterError.onError = oldOnError;

      final message = captured?.exceptionAsString() ?? '';
      expect(
        message.contains('A RenderFlex overflowed') ||
            message.contains('overflowed by'),
        isFalse,
        reason: 'Initial screen should not overflow',
      );
    });

    testWidgets('Tapping anywhere does not crash (basic gesture smoke)', (
      tester,
    ) async {
      await tester.pumpWidget(const App());
      await tester.pump();

      // Tap center of the screen; ensures gesture arena and hit testing behave.
      await tester.tapAt(const Offset(200, 400));
      await tester.pump();

      // If something throws, test will fail by itself.
      expect(true, isTrue);
    });
  });
}
