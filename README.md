# TenK

TenK is a calm practice tracker that helps people spend time on a chosen
activity and see their progress accumulate.

The current MVP is being rebuilt around one focused path:

1. Welcome.
2. Create the first activity.
3. Open a simple home screen on subsequent launches.

Timer sessions, history, settings, statistics, and workshop evolution are
deferred to later stages.

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

Install Flutter 3.41.0, then run:

```bash
flutter pub get
flutter test
flutter run
```

On macOS, the existing helper starts an available iPhone simulator and runs
the current working tree:

```bash
bash scripts/run-ios-simulator.sh
```
