# TenK

A simple app to track and grow skills with a “10,000 hours” style practice log.

## Goals (MVP)
- Manual time tracking (start/stop timers + add sessions manually)
- Simple stats (daily/weekly totals, streaks)
- Reminders/notifications
- Sign in (Google / Apple) — after MVP

## Tech
- Flutter (Dart)
- Target: iOS + Android

## Getting Started
### Prerequisites
- Flutter SDK installed
- (Recommended) FVM to pin Flutter version

### Run
```bash
flutter pub get
flutter run
```

### iOS Simulator (macOS)

Install Xcode with an iOS Simulator runtime, CocoaPods, Python 3, and the Flutter
version specified in `.fvmrc` (3.41.0). Check the setup with `flutter doctor`.
From the repository root, run:

```bash
bash scripts/run-ios-simulator.sh
```

This uses an already booted iPhone simulator, or boots the first available iPhone
simulator, opens Simulator, and builds and runs the current working tree. Flutter
resolves dependencies automatically. The first build can take several minutes.
Press `r` in the terminal to reload changes, `R` to restart the app, or `q` to stop.
To choose a specific simulator, list devices with `xcrun simctl list devices available`
and pass its UDID as the script's only argument.

The script prints the branch and commit and never switches branches. Before
checking a Todoist task, use the branch and commit specified in its handoff;
`git status --short` shows any additional local changes included in the run.

### Physical iPhone

1. Connect and unlock the iPhone, trust the Mac, and enable **Developer Mode** in
   Settings > Privacy & Security (restart the phone when prompted).
2. Open `ios/Runner.xcworkspace` in Xcode. Add your Apple account in Xcode settings.
   Under Runner > Signing & Capabilities, select your development team, enable
   automatic signing, and use a unique bundle identifier for your app.
3. Run `flutter devices` to find the physical iPhone's device ID, then run
   `flutter run -d <device-id>` for development with hot reload.
4. To test launching from the home-screen icon without the Mac attached, install
   a release build with `flutter run --release -d <device-id>`. After installation,
   detach with `d`, disconnect the cable, and reopen TenK from its icon.

A free personal Apple developer account supports local device testing; its
provisioning expires and requires periodic rebuilding and reinstalling. Device
setup and signing must be completed before these commands can succeed. See
[Flutter's iOS setup guide](https://docs.flutter.dev/platform-integration/ios/setup).

For acceptance, create a test activity and session, close and reopen the app,
and verify that they remain. Record the branch, commit, device/OS, checks run,
and any remaining limitations in the Todoist task before requesting acceptance.

### Test
```bash
flutter test
```

## Existing experience

Open an activity and choose **Existing experience** in the Entries section or
the app bar menu. Estimate prior practice from years, months, and average hours
per week, or enter a known total in hours and minutes. Estimates use 4.345 weeks
per month and round once to the nearest minute; decimal points and commas are
accepted for weekly hours. Duration is limited to 100 years (months: 0–11),
and weekly hours must be above 0 and no more than 168.

Saving **replaces** the activity's prior experience; it does not add another
copy. Reopen the dialog to correct the total, or enter zero hours and minutes
to clear it. Prior experience contributes to all-time totals, progress, and
the remaining time to a goal on Dashboard and Activity Details. Today, weekly
totals, recent pace, charts, and History use tracked sessions only. ETA combines
the remaining goal with the pace of recent sessions, so prior experience alone
does not produce a practice pace.

The value is persisted as `initialMinutes` in `activities.json`; older activities
without the field start at zero. Existing session records are preserved. Older
imports stored as ordinary sessions are not automatically reclassified: free-text
notes cannot reliably identify them. This task does not add an experience prompt
to the activity creation flow.

Verification commands and recorded results are in
[`docs/testing/backlog-test-suite.md`](docs/testing/backlog-test-suite.md).

## Project Structure (draft)
- `lib/` — app code
- `test/` — unit & widget tests
- `integration_test/` — integration tests
- `docs/` — notes & decisions

## Roadmap
See `docs/roadmap.md` (to be added).

## Contributing
Issues and PRs are welcome. If you plan a larger change, please open an issue first to align on direction.

## License
GPL-3.0
