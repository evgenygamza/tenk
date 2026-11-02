import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tenk/features/sessions/presentation/widgets/activity_details/import_experience_dialog.dart';

Future<void> openDialog(
  WidgetTester tester, {
  int initialMinutes = 0,
  ValueChanged<ImportExperienceResult?>? onResult,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              final result = await ImportExperienceDialog.open(
                context,
                initialMinutes: initialMinutes,
              );
              onResult?.call(result);
            },
            child: const Text('Open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}

Future<void> enter(WidgetTester tester, String label, String value) async {
  final field = find.byKey(ValueKey(label));
  await tester.ensureVisible(field);
  await tester.enterText(field, value);
  await tester.pumpAndSettle();
}

Future<void> save(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Save'));
  await tester.tap(find.text('Save'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'estimates and returns precise minutes, including decimal comma input',
    (tester) async {
      ImportExperienceResult? result;
      await openDialog(tester, onResult: (value) => result = value);
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
      await enter(tester, 'Years', '1');
      await enter(tester, 'Months', '2');
      await enter(tester, 'Hours per week', '10,5');
      expect(find.text('New total: 638h 43m'), findsOneWidget);
      await save(tester);
      expect(result?.minutes, 38323);
      expect(find.byType(AlertDialog), findsNothing);
    },
  );

  testWidgets('rejects invalid inputs without throwing or enabling save', (
    tester,
  ) async {
    await openDialog(tester);
    await enter(tester, 'Years', '1');
    for (final value in ['NaN', 'Infinity', '-1', '169', 'abc', '']) {
      await enter(tester, 'Hours per week', value);
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
      expect(tester.takeException(), isNull);
    }
    await enter(tester, 'Hours per week', '10');
    for (final (field, value) in [
      ('Years', '-1'),
      ('Years', '101'),
      ('Years', 'abc'),
    ]) {
      await enter(tester, field, value);
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
    }
    await enter(tester, 'Years', '1');
    await enter(tester, 'Months', '12');
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
  });

  testWidgets(
    'prefills exact minutes and allows replacing or clearing the total',
    (tester) async {
      ImportExperienceResult? result;
      await openDialog(
        tester,
        initialMinutes: 125,
        onResult: (value) => result = value,
      );
      expect(find.text('Current: 2h 5m'), findsOneWidget);
      await save(tester);
      expect(result?.minutes, 125);

      await openDialog(
        tester,
        initialMinutes: 125,
        onResult: (value) => result = value,
      );
      await enter(tester, 'Hours', '3');
      await enter(tester, 'Minutes', '60');
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
      await enter(tester, 'Minutes', '20');
      await save(tester);
      expect(result?.minutes, 200);

      await openDialog(
        tester,
        initialMinutes: 125,
        onResult: (value) => result = value,
      );
      await enter(tester, 'Hours', '0');
      await enter(tester, 'Minutes', '0');
      await save(tester);
      expect(result?.minutes, 0);
    },
  );

  testWidgets(
    'cancel returns no change and switching modes uses the selected input',
    (tester) async {
      ImportExperienceResult? result;
      await openDialog(
        tester,
        initialMinutes: 120,
        onResult: (value) => result = value,
      );
      await tester.tap(find.text('Estimate'));
      await tester.pumpAndSettle();
      await enter(tester, 'Years', '1');
      await enter(tester, 'Hours per week', '10');
      await tester.tap(find.text('Total time'));
      await tester.pumpAndSettle();
      expect(find.text('New total: 2h'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(result, isNull);
      expect(tester.takeException(), isNull);
    },
  );

  for (final size in [const Size(320, 568), const Size(568, 320)]) {
    testWidgets('dialog remains usable at $size with keyboard insets', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      tester.view.viewInsets = const FakeViewPadding(bottom: 120);
      addTearDown(tester.view.reset);
      ImportExperienceResult? result;
      await openDialog(tester, onResult: (value) => result = value);
      await enter(tester, 'Years', '1');
      await enter(tester, 'Months', '0');
      await enter(tester, 'Hours per week', '10');
      await save(tester);
      expect(result?.minutes, 31284);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'exact totals reject negative and excessive hours before arithmetic',
    (tester) async {
      await openDialog(tester, initialMinutes: 60);
      for (final value in ['-1', '876000', '9223372036854775807', 'abc']) {
        await enter(tester, 'Hours', value);
        expect(
          tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
          isNull,
        );
        expect(tester.takeException(), isNull);
      }
    },
  );
}
