# Backlog verification

## Home tutorial and minimal timer

Task: `6hvg5P2gJ99g4q82` — Сделать главный экран с туториалом и минимальным таймером.

Tested branch: `task/home-tutorial-timer`.

| Scenario / acceptance criterion | Preconditions and test data | Steps / command | Expected result | Actual result |
| --- | --- | --- | --- | --- |
| First Home tutorial | Create `Гитара` on a fresh app install | Save the activity, read the Home tutorial, then select `Понятно` | Tutorial explains the next step and can be dismissed | Fresh-install walkthrough NOT RUN; widget test passes |
| Home opens practice | Home for `Гитара` | Select `Начать занятие` | Practice screen opens for `Гитара` | PASS — verified in iOS Simulator |
| Minimal timer | Practice screen is open | Select `Начать`, wait, then select `Поставить на паузу` | Elapsed time increases while running and stops while paused | PASS — verified start, elapsed time, and pause in iOS Simulator |
| Automated regressions | Current task branch | `flutter test --reporter expanded` | All automated tests pass | PASS — 19 tests |
| Static analysis | Current task branch | `flutter analyze` | No issues | PASS — no issues found |

At implementation time, the timer was local to the practice screen. Cross-screen continuation is covered by the follow-up task below; persistence after app restart, session saving, and history remain separate work.

## Screen and cross-screen feature structure

Task: `6hvpQv9wwhjW966R` — Реорганизовать структуру экранов и общих функций.

Tested branch: `task/screen-feature-structure`.

| Scenario / acceptance criterion | Preconditions and test data | Steps / command | Expected result | Actual result |
| --- | --- | --- | --- | --- |
| Screens are separated from shared features | Current task branch | `flutter test --reporter expanded` | Existing onboarding, creation, Home, and practice widget tests pass with screens imported from their `lib/screens/<screen>/` folders | PASS — 19 tests |
| Area documentation matches the layout | Current task branch | Review root `README.md` and each screen/feature `README.md` | Tree and short descriptions match the code directories | NOT RUN |
| Static analysis | Current task branch | `flutter analyze` | No issues | NOT RUN |

The timer is owned by the app and is independent of screen lifetimes. Restoring it after app restart remains deferred.

## First user path in the iOS simulator

Task: `6hvfVgjrG3C6vg22` — Проверить первый пользовательский путь в симуляторе и передать на приёмку.

Tested branch: `task/home-tutorial-timer` while the follow-on Home work is in progress.

| Scenario / acceptance criterion | Preconditions and test data | Steps / command | Expected result | Actual result |
| --- | --- | --- | --- | --- |
| First user path | Fresh simulator app data; activity name `Гитара` | Launch the app, select Start, enter `Гитара`, save | Home opens and displays `Гитара` | NOT RUN |
| Native restart keeps the activity | Complete the first-user path | Fully terminate the app in the simulator, then relaunch it | Home opens directly with `Гитара`; Welcome does not appear | NOT RUN |
| Automated regressions | Current task branch | `flutter test --reporter expanded` | All automated tests pass | NOT RUN |
| Static analysis | Current task branch | `flutter analyze` | No issues | NOT RUN |
| iOS build and launch | Available iPhone simulator | `bash scripts/run-ios-simulator.sh` | Build succeeds and the app launches | NOT RUN |

The user runs these commands and reports only `OK` or `NOT OK`. Record further evidence only if the user asks.

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
