# Activities screen

One page with empty and populated states. Welcome opens the empty state, which
has a visible back button to return to Welcome; saved activities open the
populated state. The shared add button opens the activity form over either
state. Each saved activity joins the list, becomes selected, and can be chosen
from the animated icon selector. Up to five activities are supported; adding
is hidden at the limit. The selected activity and full list persist between
launches. Long-press an activity icon to edit or delete that activity. Editing
opens the form prefilled with its current name and icon. Deletion requires
confirmation; removing the last activity returns to the empty Activities state.

The populated state shows the current activity name and monochrome icon over a
continuous low-poly panorama. A transparent horizontal PageView controls the
selection while a single backdrop moves between five camera positions. Each
stopped frame centers one peninsula and its trail; the additional sea between
those frames becomes visible during a transition. Swiping and using the
activity selector keep the visible frame, selected activity, and saved index
in sync. Only saved activities can be reached, and new activities reveal the
next frame up to the five-activity limit.

`ActivityPanoramaLayout` in `lib/ui/widgets/activity_panorama_layout.dart`
owns the camera positions and trail endpoints in source-image pixels. The
image and milestone overlays use the same cover scale and camera offset, so
the bottom center of each milestone stays attached to its endpoint while
swiping or resizing. An optional `activityFinishBuilder` supplies
activity-specific content separately from the background. The current finish
is a `100 hours` milestone mock on every trail; the builder can replace it
with generated milestone artwork when the flow from epic #39 is ready.

The large round control manages the app-wide timer,
which has only two states: `running` and `stopped`. Start begins tracking the
selected activity; Stop ends tracking and adds elapsed time to daily totals.
The timer uses stored timestamps, restores after restart, and splits elapsed
time at local midnight. While it is running, the timer stays bound to its
original activity and its button is disabled on other activities. Once stopped,
the selected activity can be changed and tracking can start again. No session
records or digital running counter are shown.
The user-provided panorama is stored unchanged at
`lib/ui/graphics/activities_panorama.png`. It is 8400 × 2600 pixels, with a
1200 × 2600 pixel reference frame. Camera center x coordinates are `900`,
`2570`, `4200`, `5910`, and `7665`. The corresponding trail endpoint (x, y)
coordinates are `(900, 900)`, `(2570, 920)`, `(4200, 800)`, `(5910, 920)`, and
`(7665, 920)`, measured from the source image's top-left corner. Camera centers
interpolate horizontally during a swipe; all frames share a scale and vertical
position to keep the horizon stable.

`docs/design/mockups/issue-81-panorama-anchors.png` shows the endpoint anchors
for review and is not a runtime asset. When replacing the panorama, update
the artwork size, reference frame, camera centers, and endpoint coordinates
together if its composition changes. Keep trails and endpoint clearings
inside their stopped frames, allow sea between them, and preserve the soft
foreground/background tilt-shift effect. Welcome and the empty Activities
state continue to use the shared island background and their existing landmarks.
The deprecated Practice timer prototype was removed when the shared timer was
implemented for #52.

Issue #71 adds a floating active-timer geo pin above Activities when the
selected activity differs from the activity being tracked. Tapping it selects
the tracked activity and leaves its timer running. The widget hides when the
tracked activity is selected or the timer stops.
