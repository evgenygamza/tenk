# Session timer widget specification

## Approved direction

Use the circular timer variant with a daily counter. A circular weekly-practice ring surrounds a translucent Liquid Glass timer button. Stopped: only a Play icon, no visible text inside. Running: accumulated practice for the current local calendar day, `Today`, and a Pause icon. Stopped diameter is half the running diameter. Keep the circle horizontally centered. Let its layout height follow its animated diameter so neighboring text moves smoothly when it grows.

Above the circle, display the estimate on two lines: large `18 days`, smaller `to your goal`. Remove the duplicate goal label above the circle and motivational copy. Preserve the existing panorama, milestone, activity carousel, add control, and active-activity pin behavior. Below the timer, show two centered lines, populated from the selected activity:

- `This week · 2h 20m / 3h`
- `Total · 65h`

The weekly target defaults to three hours and is defined once as `weeklyPracticeTarget` in `lib/features/timer/domain/models/practice_targets.dart`. This is a code setting, not a new settings screen. The PNG/SVG illustrations predate the weekly ring, daily counter, and compact spacing revisions. Their circle proportions and materials remain references; this specification overrides their labels, fixed-center layout, and progress examples.

## Geometry and typography

All measurements are Flutter logical pixels, not screenshot pixels. Use the existing system font and theme tokens; add shared widget tokens to `lib/app/app_theme.dart` during implementation.

| Property | Regular layout | Compact adaptation |
| --- | --- | --- |
| Running outside diameter D | 280 | Fit available width and height, usually 240–280 |
| Stopped outside diameter | D / 2 = 140 | D / 2; do not let the tap target fall below 48 |
| Ring centerline radius | 0.47D | Same ratio |
| Ring stroke | 0.05D = 14 | Same ratio |
| Glass center diameter | 0.88D | Same ratio |
| Goal number line | 36, weight 700, height 1.1 | 30 if needed |
| Goal second line | 20, weight 500, height 1.2 | 18 if needed |
| Goal caption to actual circle bounds | 12 | 8 |
| Running elapsed time | 44, weight 700, tabular figures | 38 if needed |
| Running daily label (`Today`) | 16, weight 500 | 14 if needed |
| Running pause icon | 40 | 36 |
| Stopped play icon | 40 | 36 |
| Supporting metrics | 14, weight 600 | Two lines; allow each line to wrap when needed |
| Actual circle bounds to metrics | 12 | 8 |
| Page content to fixed carousel | 12 plus 10 page padding | 8 plus 8 page padding |

Use the actual animated circle height: D / 2 while stopped, D while running. Do not reserve D × D for the stopped button. Keep a 12px regular / 8px compact gap between the circle and its caption/metrics. As the circle grows, allow the caption and nearby content to move smoothly; prevent overlap. The bottom activity selector stays outside the scrolling pages. In the running circle, center elapsed time at y = 0.35D, label at 0.49D, pause at 0.69D. Optically center the Play triangle. The interactive center is one button; ring and caption are not separate actions.

Respect SafeArea. Fit the timer after reserving header, caption, metrics, and carousel space. When space or text scaling is constrained, allow the page to scroll; keep numbers readable and avoid overlaps. Keep the summit visible where space allows. Do not shrink accessibility text just to reproduce a raster composition.

## Materials and drawing layers

Draw back to front: clipped live backdrop blur, translucent moss tint, restrained top-left highlight, thin circular white rim, white glyphs/text, outer progress ring. Clip blur to the center disc. Avoid a full-screen blur, rotating highlights, or heavy stacked glass layers.

Proposed initial material values: moss `appMossColor` (#243F2A) at 28% opacity; backdrop blur sigma 14; white highlight gradient from 18% at top-left to 4% at bottom-right; white rim at 70%, width 1; outer shadow black at 14%, blur 16, offset (0, 6). Ring track white at 38%; progress arc proposed leaf green #227D36 at full opacity, with a subtle white edge for separation. White foreground text with black 35% shadow, blur 6, offset (0, 1).

These values require visual tuning over the actual island, not sampling the generated image. In Flutter, BackdropFilter produces a glass approximation; native optical refraction is not supplied by that filter. Reuse existing shared material patterns where applicable. No extra raster texture, paid font, or generated icon asset is required.

If the backdrop reduces readability, strengthen the moss tint locally. With reduced transparency, use an opaque moss center and clear ring; with increased contrast, strengthen foreground and track separation. Target 4.5:1 for small text and 3:1 for large text and meaningful icons/graphics. These targets have not yet been measured on the live widget.

## Progress semantics

Use the existing `DailyTimerController.totalForCurrentWeek(selectedActivityId)` calculation. The week starts on Monday in local calendar time and ends at the current instant. Include both saved practice and the running interval for the selected activity. Exclude other activities and imported `initialMinutes`.

`progress = clamp(weeklyDuration.inMilliseconds / weeklyPracticeTarget.inMilliseconds, 0, 1)`

Use full duration precision for the ring rather than truncating to displayed minutes. Start at 12 o'clock and advance clockwise with rounded ends. Zero shows only the track; one draws a closed filled ring. After reaching three hours, keep the ring full while practice continues to accumulate. A new calendar week begins a new weekly total, including only the part of a running interval that falls in that week.

At 2h 20m this week against a 3h target, the ring is approximately 77.8% full, regardless of lifetime milestones. At 4h it stays at 100%, with `This week · 4h / 3h`. The SVG fixture still illustrates geometry with a 30% arc; its arc length is not the weekly example.

`Total` is `activity.initialMinutes + timer.totalFor(activity.id).inMinutes`, formatted as hours and remaining minutes. Do not cap displayed lifetime time at 10,000 hours. Both metric lines use whole elapsed minutes; seconds remain visible in the daily counter.
Estimate comes from `estimatedDays`. When unavailable, hide the estimate without showing a fabricated number; reserve the caption slot so availability changes do not cause an unnecessary layout jump. Use `1 day` for the singular. At the terminal completed goal, show `Goal reached` instead of a day estimate. Keep activity names as entered; application labels remain English.

## States and interactions

| State | Visible center | Action / behavior |
| --- | --- | --- |
| Stopped | Play only; compact circle | Start tracking the selected activity; retain today’s saved practice |
| Running for selected activity | Today’s accumulated time, `Today`, Pause; large circle | Stop and save elapsed practice, then shrink |
| Another activity is running | Compact Play; disabled | Keep current active-timer pin; tapping pin selects tracked activity |
| Start/stop saving | Keep current visual state; block repeat taps | Resolve the pending operation before another action |
| Save failure | Reconcile with controller's actual state | Show an English error message with recovery; never silently imply successful persistence |

There are only running and stopped domain states. The Pause icon invokes the existing Stop action and saves the elapsed interval into daily totals. On the next Start, the displayed daily counter continues from today’s saved hours, minutes, and seconds. Time spent stopped is excluded. At local midnight, display only the new day’s portion of any running interval. No resumable session record or third paused state is introduced.

The entire glass center is the button. Apply a subtle press response; keep the ring decorative. Provide semantics `Start timer`, `Stop timer`, or `Timer is active for another activity`. Expose elapsed time and weekly progress as separate accessible values; avoid announcing every second. Do not depend on color alone for state. Saving should not be announced as stopped until controller state actually matches.

## Motion

Proposed transition: 320 ms, easeInOutCubic, circle height changes with its diameter while remaining horizontally centered. Crossfade Play versus running content over 160 ms; reveal running text only when it fits. Progress interpolation 250 ms for changed values; no indefinite spinner or looping pulse. The caption and metric layout follow the changing circle height; the carousel remains fixed below the activity pages. Each activity owns its caption, timer, and metrics inside the same PageView that drives the panorama. Swipe the entire block with its activity instead of keeping a shared floating overlay; returning to a running activity shows its own daily time and weekly ring. Only one activity may run at a time. Reduced motion: switch size and content without spatial animation. A pressed state may reduce scale to 0.97 for 90 ms.

## Data and integration work required

The controller exposes `totalForToday(activityId, {at})`, delegating to `totalForDay` with one instant from the injected clock. It sums saved milliseconds for today and the current local day’s part of the running interval. Imported experience and other activities are excluded. The internal interval start timestamp still resets at Start; the displayed daily total does not. While the selected page is visible and its activity is running in the foreground, refresh only `ActivitiesSessionTimer` once per second, including its caption, circle, and metrics. On resume/reopen, recalculate from timestamps; do not accumulate elapsed time using tick counts. Stop the visual ticker in the background, when another activity is selected, when stopped, or when disposed. Recalculate immediately when the app resumes. Clamp negative elapsed time to zero after backward clock adjustments.

Use `mm:ss` below an hour and `h:mm:ss` after an hour, with tabular numerals and enough width for long sessions. Totals and weekly minutes continue to use existing methods. Starting another activity remains blocked while one is active. Preserve persistence and restoration behavior across app restarts.

Visual component inputs: running flag, daily elapsed Duration, weekly progress 0–1, action label, enabled callback, preserved button key, diameter, and reduced-transparency preference. Motion and high-contrast preferences come from `MediaQuery`; activity selection and pending state are resolved by the adapter. Keep the visual component independent of persistence; the adapter/controller supplies values. `DailyTimerController.isSaving` blocks repeat operations; save candidate data before committing controller state. On failure, retain the previous state and totals, release the pending flag, and allow retry without double counting. Extend or replace the visual implementation of `ActivitiesTimerButton`; preserve its existing key and semantic labels. Compose caption and metrics in `ActivitiesSessionTimer`, embedded by `PopulatedActivitiesView`. `SessionTimerWidget` in `lib/ui/widgets/` owns the drawing; `ActivitiesTimerButton` connects the action and save-error message. Share colors/material dimensions in the theme. Existing `LiquidGlassButton` is a rectangular visual reference, not a ready-made native round glass component.

## Manual acceptance checklist for implementation

- Compare stopped and running states over the actual panorama at regular and compact sizes; verify the 1:2 diameter and 8–12px gaps without a large stopped-state reserve.
- Start, wait, stop, wait, start again: today’s hours/minutes/seconds continue from the saved value, excluding the stopped interval. Verify reset at local midnight and restoration after reopening.
- Background and reopen: today’s counter reflects timestamp-based elapsed practice in the current local day.
- Swipe to another activity while running: the outgoing timer and captions move with their page, the next page shows its own time and ring, its Start is disabled, and the existing pin returns to the tracked activity.
- Check 00:00, 59:59, 1:00:00 and long durations; no text overflow.
- Check an empty week, 2h 20m / 3h, target crossing, time beyond the weekly target, and Sunday-to-Monday rollover. Imported experience must not fill the ring. Check the separate milestone estimate, final completed lifetime goal, and unavailable estimate.
- Check enlarged text, screen reader labels, reduced motion/transparency, and foreground contrast over bright and dark scenery.
- Check rapid repeat taps and persistence failure without lost or double-counted practice.

## Implementation and verification status

The Flutter implementation uses the design package as a reference; no image from this directory is a runtime control asset. Tests cover timestamp-based daily accumulation across pause/restart/restoration, midnight and weekly boundaries, persistence failure/retry, pending operations, weekly ring values, lifecycle refresh, compact spacing, and activity-bound swipe behavior. At the owner’s explicit request on 2026-11-16, automated verification passed:

- `flutter test --no-pub --reporter expanded`: **79 passed**.
- `flutter analyze --no-pub`: **no issues found**.
- `flutter build ios --simulator --debug --no-codesign`: **passed**, including the native accessibility channel.
- The motion regression measures the actual timer button during a swipe beginning on the button and halfway through a selector-driven transition; both outgoing and incoming buttons move with their pages.

The running simulator was hot reloaded with the latest code; selecting another activity and the tighter stopped-button spacing were inspected. The full manual accessibility/contrast checklist remains **NOT RUN**.

For enlarged accessibility text, the `Today` label moves below the circle and the page can scroll. Long elapsed values fit within the available circle width. Reduced motion uses immediate state changes. High contrast uses an opaque center and stronger track. The iOS `tenk/accessibility` method channel reads `UIAccessibility.isReduceTransparencyEnabled` on opening and resume and passes it to the visual component as `reduceTransparency`. Platforms without that channel keep the standard material; high-contrast fallback still applies. The platform preference adapter is covered with a mock channel; its native behavior awaits an iOS manual check. Native refraction and measured contrast over the live panorama remain outside the verified claims.

Run:

```sh
flutter test test/daily_timer_controller_test.dart test/session_timer_widget_test.dart test/home_practice_flow_test.dart
flutter analyze
```

Expected: all targeted tests pass and analysis reports no issues. Compare both states over the live panorama using the checklist above; PNGs remain concepts, not screenshots of the implementation.
