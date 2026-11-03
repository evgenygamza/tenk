# TenK

TenK is a calm practice tracker that helps people spend time on a chosen
activity and see their progress accumulate.

The current MVP is being rebuilt around one focused path:

1. Welcome.
2. Create the first activity.
3. Open Home and begin a practice timer.

## Code layout

```text
lib/
├── app/                    # App setup and theme
├── features/
│   └── activities/         # Activity data and repository
├── screens/
│   ├── create_activity/    # First activity form
│   ├── home/               # Home screen and its widgets
│   ├── practice/           # Practice and timer display
│   └── welcome/            # First-launch welcome
└── main.dart               # App entry point
```

Each screen and shared feature has a short README in its directory. Keep
screen-only widgets beside that screen.

Home gives the first created activity a clear next step: a brief tutorial can
be dismissed, then `Начать занятие` opens Practice. The current timer only
runs while Practice is open; a shared timer is planned separately. Saving a
session, history, settings, statistics, and workshop evolution are deferred.

On startup, TenK loads the first activity from local storage before choosing a
screen. Without an activity (including a blank stored name), it opens Welcome
and the first-activity form. The form accepts one required name, saves it locally,
prevents duplicate submits, and allows retrying a failed save.

A saved activity opens Home immediately, including after an app restart. Home
shows the activity name and the calm low-poly uphill-path illustration. Saving
the first activity clears the onboarding navigation stack. A failed startup
read shows a retry action without treating the failure as an empty activity or
overwriting saved data.

Startup routing, loading and retry states, activity display, compact layouts,
and the create/save flow are covered by widget and repository tests. Verification
scenarios and execution evidence are in [the test suite](docs/testing/backlog-test-suite.md).

## Development

Install Flutter 3.41.0. From the repository root, use these commands to prepare
the project and inspect the local Flutter setup:

```bash
flutter pub get
flutter doctor -v
flutter devices
```

Run the automated checks with:

```bash
# Run all widget and repository tests with readable output
flutter test --reporter expanded

# Run one test file
flutter test test/app_test.dart

# Check Dart and Flutter lints
flutter analyze

# Format Dart sources
dart format lib test
```

Run on the default connected device with:

```bash
flutter run
```

On macOS, the iOS helper boots an available iPhone simulator, opens Simulator,
and runs the current working tree. Pass a simulator UDID to select a device:

```bash
bash scripts/run-ios-simulator.sh
bash scripts/run-ios-simulator.sh <simulator-UDID>
```

List available iOS simulators and their UDIDs with:

```bash
xcrun simctl list devices available
```
