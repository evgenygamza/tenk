# TenK

TenK is a calm practice tracker that helps people spend time on a chosen
activity and see their progress accumulate.

The current MVP is being rebuilt around one focused path:

1. Welcome.
2. Create the first activity.
3. Open a simple home screen on subsequent launches.

Timer sessions, history, settings, statistics, and workshop evolution are
deferred to later stages.

The first-launch Welcome screen and first-activity form are implemented. The
form accepts one required name, saves it locally, prevents duplicate submits,
and allows retrying a failed save. A successful save currently opens a minimal
home placeholder; the real home and repeat-launch routing are the next MVP step.

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
