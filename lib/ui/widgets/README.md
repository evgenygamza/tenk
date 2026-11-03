# Activities UI widgets

The populated activity view is rendered as the selected state of the Activities page; it is not a separate navigation destination. It shows the activity over the
low-poly island background, with a goal monument, ETA, visual selector, and
add affordance. `ActivityIsland` uses the same clean island asset as Welcome
and positions the activity name in the header. It pins a separate
`ActivityLandmark` at the summit in artwork coordinates. The 100-hour marker
and 10,000-hour Greek temple are separate
illustrated assets with their lettering included. The empty state uses a small
floating question mark at the same summit anchor. Add a new designed asset for
each additional milestone. ETA and selector remain visual placeholders.
The Start Session control is reserved for a future timer widget. The
dismissible first-practice tutorial remains available after activity creation.


`PopulatedActivitiesView` contains the live filled state previously called Home. Keep page navigation and the empty state in `screens/activities`; add future embedded Activities controls here or under `screens/activities/widgets` as their ownership becomes clear.
