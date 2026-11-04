# TenK

TenK is a calm practice tracker that helps people spend time on a chosen
activity and see their progress accumulate.

The current first-use path is being delivered in steps:

1. Welcome.
2. Open the empty Activities screen.
3. Create the first activity from its add button (issue #59).
4. Use one persistent timer in Activities to add elapsed time to daily activity
   totals (issue #52).

## Code layout

```text
lib/
├── app/                    # App setup and theme
├── features/
│   ├── activities/         # Activity data and repository
│   └── timer/              # Persistent daily timer and totals
├── screens/
│   ├── activities/         # Empty and populated Activities states
│   └── welcome/            # First-launch welcome
├── ui/
│   └── widgets/            # Reusable and embedded UI
└── main.dart               # App entry point
```

Activities and Welcome are the only top-level screens. The populated Activities
view is a reusable widget under `lib/ui/widgets/`; the first-activity form lives
with its feature until it is embedded in Activities by #59.

Welcome uses a full-screen local island illustration, English overlay copy, and
the shared Liquid Glass action button. The illustration stays separate from
the accessible text and interactive controls.

Activities is the main activity page, with empty and populated states. The
populated state uses one shared timer with two states: `running` and `stopped`.
Start begins tracking the selected activity; Stop ends tracking and adds elapsed
time to daily totals, including when it crosses local midnight. The running
state and totals restore after an app restart. The app does not create session
records or show a running digital counter.

On startup, TenK loads the first activity from local storage before choosing a
screen. Without an activity (including a blank stored name), it opens Welcome.
The Welcome action opens the empty Activities screen. Its add button currently
previews a non-persistent sample activity; issue #59 will connect it to the
first-activity form. The form accepts one required name, saves it locally,
prevents duplicate submits, and allows retrying a failed save.

A saved activity opens the populated Activities state, including after an app
restart. It shows the activity name over the low-poly island background.
Welcome and Activities share one clean island background. Welcome pins the
10,000-hour Greek temple to the summit; the empty Activities state pins a
floating question mark there; the populated state uses a dedicated illustrated
`ActivityLandmark` for each milestone. The 100-hour marker and 10,000-hour
temple include their lettering in the artwork. ETA and activity selector are
visual placeholders for later tasks.
Saving the first activity clears the onboarding navigation stack. A failed
startup read shows a retry action without treating the failure as an empty
activity or overwriting saved data.

Startup routing, empty and populated activity states, loading and retry states,
compact layouts, and the create/save flow are covered by widget and repository
tests. Verification scenarios and execution evidence are in
[the test suite](docs/testing/backlog-test-suite.md).

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
