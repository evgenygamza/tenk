# Activities UI widgets

`TranslucentPanel` is the shared standard material surface for overlays and floating
panels. Use it with the tokens in `lib/app/app_theme.dart` rather than creating
one-off glass treatments.

The populated activity view is rendered as the selected state of the Activities page; it is not a separate navigation destination. It shows the activity over the
low-poly island background, with a goal monument, ETA, animated activity
selector, and shared working add button. The selector shows the saved activity
icons and changes the active activity. `ActivityIsland` uses the same clean island asset as Welcome
and positions the selected activity icon and name in the header. It pins a separate
`ActivityLandmark` at the summit in artwork coordinates. The 100-hour marker
and 10,000-hour Greek temple are separate
illustrated assets with their lettering included. The empty state uses a small
floating question mark at the same summit anchor. Add a new designed asset for
each additional milestone. ETA remains a visual placeholder.
The populated view includes a large round Start/Stop control bound to the
shared daily timer from issue #52. The timer has only `running` and `stopped`
states and persists its activity, running timestamp, and per-day totals. The
dismissible first-practice tutorial remains available after activity creation.

`ActiveTimerGeoWidget` floats above Activities while a different activity is
selected from the one tracked by the shared timer. It uses the running
activity's catalog icon, points toward that activity's side relative to the
current carousel selection, and selects it when tapped without stopping the
timer. It is hidden when the timer is stopped or the tracked activity is
already selected. Welcome cannot have an active timer. PNGs in
`docs/design/mockups/` record the approved left and right compositions; the app
does not load those images.


`PopulatedActivitiesView` contains the live filled state previously called Home. Keep page navigation and the empty state in `screens/activities`; add future embedded Activities controls here or under `screens/activities/widgets` as their ownership becomes clear.
