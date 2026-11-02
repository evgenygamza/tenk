# Backlog verification

## Simple Home and repeat launch

Task: `6hvfVgg8jgFH7VHR` — Сделать простой главный экран и повторный вход.

Environment: macOS, Flutter 3.41.0 / Dart 3.11.0; iPhone 17 Pro simulator,
iOS 26.2, UDID `55982DFE-6FB7-420E-96BC-A0B3339456CD`.
Tested state: working tree based on `29c98bd`, containing the Home and startup
routing implementation committed with this report. Verification date:
2026-11-02 (Asia/Tbilisi).

| Scenario / acceptance criterion | Preconditions and test data | Steps / command | Expected result | Actual result |
| --- | --- | --- | --- | --- |
| First launch offers activity creation | Injected repository has no name | `flutter test test/app_test.dart`; first-launch test taps Start | Welcome opens and Start reaches the form | PASS |
| Loading chooses no screen prematurely | Repository read is held by a completer; then returns `Гитара` | Run the loading test in `test/app_test.dart` | Loading indicator, no Welcome flash, then Home; one read | PASS |
| Repeat launch restores the activity | Start empty, create `Гитара`, unmount App and mount a new App using the same repository | Run the restart test in `test/app_test.dart` | Home shows `Гитара` directly, with no onboarding back route | PASS |
| Missing or blank activity keeps onboarding available | Repository returns null or whitespace | Run first-launch and blank-name tests in `test/app_test.dart` | Welcome remains accessible | PASS |
| Load failure can be retried safely | Repository holds `Рисование`, fails initial read and first retry | Run load-failure test in `test/app_test.dart` | Error and retry action; no Welcome or data loss; successful retry shows Home | PASS |
| Retry can resolve to an empty store | First read fails, retry returns null | Run empty-retry test in `test/app_test.dart` | Welcome opens | PASS |
| Home displays long activity names accessibly | 320×568 viewport, 2× text scale, `Рисование и изучение пейзажей` | Run compact Home test in `test/app_test.dart` | Name is present and scrollable without layout exceptions | PASS |
| Creation still saves and reaches Home | Empty, whitespace, valid and failed-save input; delayed save | `flutter test test/create_activity_screen_test.dart` | Validation, trimmed persistence, duplicate-submit protection, retry, Home with no onboarding back route | PASS |
| Existing Welcome and storage behavior | In-memory platform storage and injected repositories | `flutter test --reporter expanded` | All regression tests pass | PASS — 16 tests |
| Static analysis | Current implementation | `flutter analyze` | No issues | PASS — no issues found |
| iOS build and launch | Booted simulator above | `flutter run -d 55982DFE-6FB7-420E-96BC-A0B3339456CD --no-resident` | Build succeeds, app starts and Flutter connects | PASS — exit code 0; Xcode build 5.8s; files synced in 102ms |
| Manual visual and persistence walkthrough on iOS | Running app; Computer Use permission required | Inspect Welcome, create an activity, inspect Home, terminate and relaunch | Home remains readable and activity survives native process restart | BLOCKED — Computer Use permissions are not granted |

The first test run exposed an unhandled asynchronous read failure during a
failed retry. The implementation now captures read failures immediately; the
final complete test run passed. Automated restart coverage recreates App with
an injected repository; repository tests use an in-memory preferences platform.
A native process restart with real iOS preferences and visual review remain
manual verification gaps. No timer, graphs, history, or settings were added.
