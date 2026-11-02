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
