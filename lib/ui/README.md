# Shared UI

Place visual widgets in `lib/ui/widgets/`. Keep screen composition and
behavior with the screen that owns it.

Store runtime bitmap artwork in `lib/ui/graphics/`. That directory is bundled
through `pubspec.yaml`; reference its asset paths from the widgets that own
the artwork. See its README for background replacement guidance.

`LiquidGlassButton` is a tappable, labeled action control used where the
translucent glass treatment is part of the design. It accepts a label and
nullable callback so it can also represent a disabled action.

`PopulatedActivitiesView` renders the filled state inside Activities. `UphillPathIllustration` is a reusable path artwork widget; screen layout and navigation remain in Activities and Welcome.
