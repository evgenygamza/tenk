# Backlog verification

## Existing experience — Todoist 6hvXFWxG8G85JC92

Acceptance criteria:

- AC1: Estimate prior experience, preview precise hours/minutes, and reject
  invalid, negative, excessive, non-finite, or empty estimates without crashing.
- AC2: Both Activity Details entry points save the same prior-experience total;
  saving replaces it, cancelling preserves it, and zero clears it.
- AC3: Dashboard and Activity Details include prior experience in all-time
  progress. Session totals, History, charts, and recent pace exclude it. ETA uses
  the remaining goal and tracked practice pace. A completed final goal stays full.
- AC4: Persist and reload the value, default old records to zero, preserve other
  activities, and leave the old value intact with visible feedback on write failure.
- AC5: The dialog stays usable on a small portrait/landscape viewport with
  keyboard insets, and existing navigation and session behavior still passes.

### Automated scenarios

All commands run from the repository root. Preconditions: Flutter SDK and resolved
dependencies (`flutter pub get` if needed); no running emulator is required. The
widget tests use fake repositories and an idle timer; they do not change user data.

| Scenario | Criteria | Test data and steps | Expected result |
| --- | --- | --- | --- |
| EXP-01 | AC1 | `flutter test --no-pub test/experience_calculator_test.dart`; estimate 1 year, 2 months, 10 h/week and 1 month, 2.5 h/week; test negative/zero/NaN/infinite/out-of-range values and the upper bound. | 36,498 and 652 minutes; invalid estimates return no result; valid maximum succeeds. |
| EXP-02 | AC1, AC2 | `flutter test --no-pub test/import_experience_dialog_test.dart`; enter 1 year, 2 months, 10,5 h/week; switch input modes; edit 125 minutes to 200, clear to zero, and cancel. | Preview 638h 43m; result 38,323 minutes; exact values and cancellation are preserved; invalid inputs disable Save. |
| EXP-03 | AC2, AC3 | `flutter test --no-pub test/existing_experience_flow_test.dart`; seed Guitar with today's 30-minute session and Piano without sessions; import 1 year at 10 h/week via the menu; return to Dashboard and open History. | Guitar prior experience 31,284 minutes; all-time 31,314; Today/week/charts remain 30; pace 1m/d and ETA 28,686 days; Piano unchanged; History still has one session. |
| EXP-04 | AC2, AC4 | Same flow command; open the Entries button with a 120-minute baseline; save twice, cancel an edit, replace with 180, then clear. Run the model/controller suite to reload serialized values and simulate a failed write. | Repeated saves never add copies; cancel changes nothing; clearing removes only prior experience; JSON reload preserves data and old records default to zero; failed save preserves memory/storage. |
| EXP-05 | AC4 | Same flow command; seed 60 minutes, make the repository fail writes, and save 120 minutes. | Error snackbar is visible; 60 minutes remains stored and in memory; no uncaught error. |
| EXP-06 | AC5 | Dialog suite at logical sizes 320×568 and 568×320 with a 120-pixel bottom keyboard inset; scroll, fill fields, and save. | Save succeeds with 31,284 minutes, without rendering exceptions. |
| EXP-07 | AC3, AC5 | Flow suite renders progress at 600,000 and 700,000 minutes; run `flutter test --no-pub` and `flutter analyze --no-pub`. | Final-goal bar is full at/above 10,000 hours; session and navigation regressions pass; analyzer has no issues. |

### Execution record

- Date: 2026-11-02 (client timezone: Asia/Tbilisi).
- Environment: macOS 26.3.1 (a), Flutter 3.41.0 stable, Dart 3.11.0;
  SDK from `/opt/homebrew/share/flutter`.
- Baseline: `3bb9262` plus the four pre-existing Dart file edits; all 15 existing
  tests passed before implementation. The first sandboxed attempt could not write
  the Flutter SDK engine stamp; the authorized cache-access retry succeeded.
- Tested implementation: `feature/activity-details-screen`, working tree based
  on `3bb9262`, including the existing-experience source and tests in this commit.
  Source and tests were unchanged after the final execution; this record was
  appended afterward. The pre-existing untracked `AGENTS.md` is excluded.
- First full implementation run: 29 passed, 1 failed. EXP-04's test tapped the
  Entries action before its scroll settled. Added the missing settle step; the
  affected flow suite then passed all 4 tests. Two additional boundary/no-session
  checks were added before final execution.
- **PASS — EXP-01 through EXP-07:** `flutter test --no-pub --reporter expanded`:
  **32 tests passed** (15 existing regression tests and 17 new tests).
  Evidence: final runner output `00:02 +32: All tests passed!`; includes both
  viewport cases, zero-session pace/ETA, excessive exact totals, and final-goal bars.
- **PASS:** `flutter analyze --no-pub`: `No issues found!`.
- **PASS:** `git diff --check`: no whitespace errors.
- **BLOCKED / not executed:** physical-device validation and native filesystem
  plugin integration; a device test environment is not configured for this task.

### Remaining automation gaps

Device keyboard behavior and actual iOS/Android filesystem plugin integration are
not exercised by widget tests. Persistence is covered by JSON round-trip repository
tests; rendering and keyboard constraints use simulated viewports. No claim is made
that the full branch's unrelated Activity Details redesign has been accepted on a
physical device.

## Monthly chart year boundary — Todoist 6hvXQwVjQQHVJwRR

Acceptance criterion: the monthly chart shows the requested calendar-month window
in chronological order, including months in previous years. Months without entries
have zero minutes; future months, older entries, and other activities are excluded.
The calculation accepts an optional `now` for deterministic tests and uses the
current local date in the app.

Preconditions: Flutter 3.41.0 / Dart 3.11.0 and resolved project dependencies.
Command: `flutter test --no-pub test/activity_details_aggregate_test.dart --reporter expanded`.

- MONTH-01: at November 2, 2026, use a 12-month window with December 2025 = 30
  minutes, November 2026 = 45, December 2026 = 999, November 2025 = 100, and
  another activity's December 2025 = 100. Expect December 2025 through November
  2026, with 30 minutes in the first bar, 45 in the last, and 75 in total.
- MONTH-02: at January 15, 2026, use a 3-month window with November 2025 = 20,
  December 2025 = 40, January 2026 = 10. Expect labels `Nov`, `Dec`, `2026 Jan`
  and minutes `[20, 40, 10]`.

Execution on 2026-11-02, macOS, working tree based on `7920b64`:

- Before the fix: **FAIL**, both regressions reproduced. MONTH-01 returned 999
  instead of 30; MONTH-02 returned `[0, 0, 10]` instead of `[20, 40, 10]`.
- After the fix: **PASS**, both scenarios passed as part of
  `flutter test --no-pub --reporter expanded`: `00:02 +34: All tests passed!`.
  The full suite contains 32 existing tests plus these two regressions.
- **PASS:** `flutter analyze --no-pub`: `No issues found!`.
- **PASS:** `bash -n scripts/run-ios-simulator.sh` and `git diff --check`.

The ordinary `flutter test` suite is the verification target. The earlier
`flutter run` attempt on the iOS simulator had two failures in the existing
dialog tests (semantics-handle cleanup and a missed tap). Those live-mode issues
are not fixed by this calendar correction; full device-level testing is tracked
in Todoist task `6hvfJrHF5GgQQh72`.
