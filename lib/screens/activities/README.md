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

The populated state shows the current activity name and monochrome icon with
its visual goal summary. The large round control manages the app-wide timer,
which has only two states: `running` and `stopped`. Start begins tracking the
selected activity; Stop ends tracking and adds elapsed time to daily totals.
The timer uses stored timestamps, restores after restart, and splits elapsed
time at local midnight. While it is running, the timer stays bound to its
original activity and its button is disabled on other activities. Once stopped,
the selected activity can be changed and tracking can start again. No session
records or digital running counter are shown.
`ActivityIsland` uses the same clean island background as Welcome and anchors a
separate `ActivityLandmark` at the summit using artwork coordinates. The 100-
hour marker and 10,000-hour Greek temple are distinct illustrated assets with
their lettering included. Welcome uses the 10,000-hour temple as its summit
landmark, while the empty state uses a larger floating question mark centered
over `ActivityIsland.roadEndpointAnchor`, the normalized path-tip coordinate.
The anchor is transformed through the same `BoxFit.cover` calculation as the
background, so it tracks the visible path tip after screen cropping. Add a
dedicated asset when introducing a milestone.
The deprecated Practice timer prototype was removed when the shared timer was
implemented for #52.

Issue #71 adds a floating active-timer geo pin above Activities when the
selected activity differs from the activity being tracked. Tapping it selects
the tracked activity and leaves its timer running. The widget hides when the
tracked activity is selected or the timer stops.
