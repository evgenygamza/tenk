# Backlog verification

## MVP Activities timer button

Task: `#69` — Добавить MVP-кнопку запуска и остановки таймера в Activities.

Branch: `task/69-activities-mvp-timer-button`.

Historical #69 mock behavior; replaced by the #52 daily timer below.

| Scenario / acceptance criterion | Preconditions and test data | Steps / command | Expected result | Actual result |
| --- | --- | --- | --- | --- |
| #69 — Button sends Start and Stop to the mock | Populated Activities; mock timer starts idle | Run `flutter test test/home_practice_flow_test.dart`; tap the timer control twice | The mock receives Start then Stop, and the button changes Play → Stop → Play | NOT RUN |
| #69 — Timer control stays inside Activities | Populated Activities for `Гитара` | Run `flutter test test/home_practice_flow_test.dart` and activate the timer | Activities remains the active page; deprecated Practice is not opened | NOT RUN |
| #69 — Regression coverage | Current task branch | `flutter test --reporter expanded` | All automated tests pass | NOT RUN |
| #69 — Static analysis | Current task branch | `flutter analyze` | No issues found | NOT RUN |

Issue #52 replaces the mock receiver with a persistent daily timer. The earlier
MVP button scenarios are historical and no longer describe the current control.

## Daily timer and activity totals

Task: `#52` — Перейти на дневной учёт времени и единое управление таймером.

| Scenario / acceptance criterion | Preconditions and test data | Steps / command | Expected result | Actual result |
| --- | --- | --- | --- | --- |
| #52 — Start creates one active timer | Idle timer; activity ID `activity-1` | Run `flutter test test/daily_timer_controller_test.dart`; start twice for different IDs | Only the first activity is active and one running timestamp is stored | PASS — covered by focused run (10 tests) |
| #52 — Pause and Resume preserve totals | Timer started at 23:55, paused at 00:05, resumed at 00:06, paused at 00:09 | Run `flutter test test/daily_timer_controller_test.dart` | Five minutes are stored on each day before midnight; the resumed three minutes add to day two; total is 13 minutes | PASS — covered by focused run (10 tests) |
| #52 — Running state restores after restart | Timer starts at 10:00; app data persists | Relaunch app or restore controller from the repository at 10:07, then pause | Timer is still running and seven minutes are added from timestamps | PASS — covered by focused run (10 tests) |
| #52 — Persistent storage restores timer state | A running timer and one saved daily total | Run `flutter test test/shared_preferences_daily_timer_repository_test.dart` | The active activity, timestamp, and day total are restored from local storage | PASS — covered by focused run (10 tests) |
| #52 — Switch activities while timer runs | Two saved activities; first is selected | Start the timer, then select the second activity | Selection changes; the timer remains bound to the first activity and the second activity's timer button is disabled | PASS — covered by focused run (10 tests) |
| #52 — Switch activities while timer is paused | First timer has accumulated two minutes | Pause, select the second activity, then return to the first | The second activity's timer button is disabled; the first activity still offers Resume and retains its two minutes | PASS — covered by focused run (10 tests) |
| #52 — No session editor or running counter | Populated Activities | Inspect timer control before start, while running, and after pause | Start, Pause, and Resume are clearly announced; no digital elapsed counter or session save UI appears | PASS — widget test covered button states and no counter (focused run, 10 tests) |
| #52 — Regression coverage | Current task branch | `flutter test --reporter expanded` | All widget and repository tests pass | PASS — 40 tests |
| #52 — Static analysis | Current task branch | `flutter analyze` | No issues found | NOT RUN |

Daily totals are persisted by activity ID and local calendar day. The previous
screen-local Practice prototype has been removed. The user runs checks and
reports `OK` or `NOT OK`.

## First activity creation from Activities

Task: `#59` — Подключить создание первого занятия из экрана активностей.

Branch: `issue-59-embedded-activity-creation`.

| Scenario / acceptance criterion | Preconditions and test data | Steps / command | Expected result | Actual result |
| --- | --- | --- | --- | --- |
| #59 — Add opens an embedded form | Fresh app data; Welcome is visible | Select Get Started, then `+` | The form overlays empty Activities without opening a separate route | PASS |
| #59 — Form matches the white glass panel style | Activities background is visible; form overlay is open | Inspect the form over the island artwork | White translucent panel keeps the artwork subtly visible; compact search, filters, and icon tiles use the documented foreground and accents | PASS |
| #59 — Cancel preserves the empty state | Form is open; no saved activity | Select Cancel | The form closes and empty Activities remains; nothing is saved | PASS |
| #59 — Icon and name are saved | Form is open; icon `Instrument`, name `Гитара` | Search or filter the icon catalog, select Instrument, enter name, select Save | Populated Activities shows the monochrome icon and `Гитара`; repository stores the icon ID and name | PASS |
| #59 — Icon catalog scrolls | Form is open on a compact viewport with no search filter | Scroll inside the icon grid from first to last row | Every catalog icon can be reached and selected; the scrollbar shows the current position | PASS |
| #59 — Name is limited to 40 visible characters | Form is open | Enter 41 ASCII characters, then 41 composed `é` graphemes | Input is limited to 40 user-perceived characters and no layout error occurs | PASS |
| #59 — Saved activity restores after relaunch | Save icon `Instrument` and name `Гитара` | Fully restart the app | Activities opens directly with the same icon and name; Welcome does not appear | PASS |
| #59 — Automated regressions | Current task branch | `flutter test --reporter expanded` | All automated tests pass | PASS — 31 tests |
| #59 — Static analysis | Current task branch | `flutter analyze` | No issues found | PASS |
| #59 — iOS build and launch | Available iPhone simulator | `bash scripts/run-ios-simulator.sh` | Build succeeds and the app launches; overlay remains usable on compact portrait | PASS |

The approved checks passed for issue `#59` in `Testing`.

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

## Welcome screen visual refresh

Task: `#54` — Match the approved 10K Hours Welcome design.

Tested branch: `task/welcome-screen-54`.

| Scenario / acceptance criterion | Preconditions and test data | Steps / command | Expected result | Actual result |
| --- | --- | --- | --- | --- |
| English Welcome copy, background, and balanced spacing | Fresh app state; Welcome is the initial route | `flutter test test/welcome_screen_test.dart` | The full-screen local island image is shown with `TENK`, “Time Becomes Mastery”, the English description, and “Get Started” as real Flutter text and control; both vertical gaps match and the copy sits lower above the anchored button | NOT RUN |
| Start continues onboarding | First-activity repository is empty | Run the Start navigation test in `test/welcome_screen_test.dart` | “Get Started” opens the existing first-activity screen | NOT RUN |
| Compact viewport remains usable | 320×568 logical-pixel test viewport | Run the compact Welcome test in `test/welcome_screen_test.dart` | No layout exception; the primary action remains available | NOT RUN |
| Regression coverage | Current task branch | `flutter test --reporter expanded` | All onboarding, persistence, Home, and Practice tests pass | NOT RUN |
| Static analysis | Current task branch | `flutter analyze` | No issues found | NOT RUN |
| iOS visual review | Available iPhone simulator | `bash scripts/run-ios-simulator.sh` | Full-bleed background, readable English copy, and glass button match the approved portrait composition | NOT RUN |
