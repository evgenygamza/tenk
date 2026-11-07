# Activities UI widgets

`TranslucentPanel` is the shared standard material surface for overlays and floating
panels. Use it with the tokens in `lib/app/app_theme.dart` rather than creating
one-off glass treatments.

The populated activity view is rendered as the selected state of the Activities
page; it is not a separate navigation destination. It shows a continuous
low-poly panorama, ETA, animated activity selector, and shared working add
button. A transparent horizontal PageView controls selection while one
backdrop interpolates between the camera centers defined by
`ActivityPanoramaLayout` in `activity_panorama_layout.dart`. The selector and
swipe callback keep selection and persistence synchronized. Sea between the
stopped frames appears during transitions.

The unchanged user-provided artwork is
`lib/ui/graphics/activities_panorama.png` (8400 × 2600 pixels). The layout uses
a 1200 × 2600 pixel reference frame and source-image camera center x values
`[900, 2570, 4200, 5910, 7665]`. Source-image trail endpoints are `(900, 900)`,
`(2570, 920)`, `(4200, 800)`, `(5910, 920)`, and `(7665, 920)`. The image and
overlays share one cover scale and camera offset. Each milestone's bottom
center is placed at its endpoint, preserving alignment across viewport sizes
and during swipes. Generated activity-specific finish content can be supplied
through `activityFinishBuilder`; the current `100 hours` milestone mock is a
separate overlay. The annotated anchor diagram at
`docs/design/mockups/issue-81-panorama-anchors.png` is for review only and is
not bundled as runtime artwork.
Welcome and the empty Activities state continue to use `ActivityIsland` and its
separate landmark assets. ETA remains a visual placeholder.
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
