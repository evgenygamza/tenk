# Runtime graphics

This directory owns the app's runtime bitmap artwork and panorama source
variants. `pubspec.yaml` lists runtime assets explicitly; reference copies are
kept here for review without bundling them into the app. Annotated diagrams in
`docs/design/` are documentation artifacts and are not runtime assets.

`activities_panorama.png` is the user-provided 8400 × 2600 pixel PNG used by
the populated Activities carousel. Preserve the source artwork when adjusting
its viewport positions or milestone anchors; those coordinates belong in the
UI code. When replacing the panorama, update its dimensions, camera positions,
and trail endpoint coordinates together.

`activities_panorama_v1.png` is the previous 8400 × 2600 pixel version,
retained for comparison and rollback. It is not included in the runtime asset
bundle; the app continues to display `activities_panorama.png`.

`island_background.png` supplies the Welcome and empty Activities landscape.
The `landmark_*_hours_angled.png` files are separate transparent milestone
overlays, one for each goal from 10 through 10,000 hours. The `ActivityLandmark`
widget selects an overlay for the nearest goal; these images are not part of the
landscape artwork. `activity_question_mark_angled.png` is also a separate
overlay.
