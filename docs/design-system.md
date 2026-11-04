# TenK design system

This document describes the shared visual rules for TenK screens and overlays.
The Welcome and Activities screens are the visual references. The island
artwork supplies the core palette: leafy greens, lagoon blues, and the warm
gold of the path.

## Foundations

- Use the palette, typography, button style, and glass values from
  `lib/app/app_theme.dart`. Add a theme token when a value should be shared;
  avoid repeating local colors, corner radii, and effects.
- Use the theme text styles for headings and body copy. Reserve custom sizes for
  artwork compositions that need to adapt to the available screen size.
- Keep `TENK`, activity names, and field labels on the foreground color chosen
  with the panel palette; do not leave their current green fixed when changing
  the panel tint.
- Use a translucent standard material for content panels and forms. Use
  `TranslucentPanel` for the shared blurred panel treatment. Its tint should
  harmonize with the artwork and keep enough contrast for text and controls.
- Reserve Liquid Glass styling for a small number of prominent controls and
  navigation elements. Do not apply it as a decorative effect to every content
  surface; keep enough of the island artwork visible to preserve context.
- Use the moss primary color and a circular shape for the prominent Activities
  timer control. The timer has only two states, `running` and `stopped`; keep
  the state and its Start or Stop action clear through its icon and accessible
  label. Show Play when stopped or disabled for another activity, and Pause
  while controlling a running timer; its action and accessible label remain
  Start or Stop.
- Use one-color vector icons for activity identity. Keep catalog identifiers
  stable in saved data; do not persist platform-rendered emoji glyphs. Make a
  broad icon catalog searchable and filterable by category.
- Give milestone artwork a soft, centered ground shadow at its base when it is
  layered over the island landscape.
- Style contextual popup menus with the shared translucent surface, rounded
  border, subtle shadow, and theme foreground colors.

## Apple materials guidance

- Treat forms and other content-heavy overlays as content surfaces. Use a
  translucent standard material so the background remains visible while the
  form stays readable.
- Reserve Liquid Glass for the functional control and navigation layer, and
  apply it sparingly. Do not stack multiple glass treatments on one element.
- On a visually rich background, a clearer material can retain more context;
  maintain legibility and account for accessibility settings that reduce
  transparency or increase contrast.

References: [Human Interface Guidelines — Materials](https://developer.apple.com/design/human-interface-guidelines/materials) and [Adopting Liquid Glass](https://developer.apple.com/documentation/technologyoverviews/adopting-liquid-glass).

## Palette exploration

The activity creation panel uses a translucent white surface so the island
artwork remains visible through it. Keep the deep green foreground and leaf
green selection accent. Use the app's existing theme text styles and system
typeface for the overlay; do not introduce a new font or heavier display style.

| Direction | Panel tint | Tile treatment | Title, text, and icon color | Artwork cue |
| --- | --- | --- | --- | --- |
| White glass (selected) | White at 45% opacity | White at 20%; soft leaf green for selection; white at 48% for input surfaces | `#243F2A` | Island foliage |
| Lagoon (not selected) | `#ABD8DB` at 72% opacity | White at 20%; soft aqua for selection | `#16434A` | Water and sky |
| Path (not selected) | `#EED18A` at 72% opacity | White at 20%; pale leaf green for selection | `#3B4629` | Golden trail |

Keep the border light and quiet. The panel should let the island remain
visible; apply a single selected-state accent to the active icon tile without
adding a different color to every icon. Use the selected foreground for the
TENK wordmark, activity name, form headings, and icon catalog.
Keep the activity picker compact: search controls, category filters, icon
symbols, and their tiles use roughly two-thirds of their former visual size;
preserve enough scroll area to browse the full catalog.

## Components and ownership

- `lib/app/app_theme.dart` owns app colors, type, button styles, and glass
  tokens.
- `lib/ui/widgets/` owns visual components reused by multiple screens, such as
  `TranslucentPanel`.
- `lib/features/<feature>/presentation/` owns interaction widgets used by one
  feature, such as the activity form and its icon catalog.
- `lib/screens/` owns navigation pages and their page-level composition.

## Forms and overlays

- Show creation flows as an overlay within the owning page when the user should
  return to the same page on cancel.
- Reuse the glass surface, theme fields, and primary button styles. Keep the
  underlying screen recognizable, provide an explicit cancel action, and let
  system Back cancel the overlay before leaving the page.
- Keep the form scrollable inside `SafeArea` so the keyboard and compact screens
  do not hide the name field or primary action.
- Provide visible loading, validation, and save-error states. Disable duplicate
  submissions while a save is in progress.

## Responsive layout and accessibility

- Respect safe areas and adapt padding or arrangement with available width and
  height. Allow content to scroll when the keyboard or a compact viewport
  reduces the available space.
- Give icon-only controls semantic labels and tooltips. Selection must be
  visible in addition to being announced to assistive technology.
- Check overlays and their underlying page in portrait and compact viewports.

When adding a visual pattern, update this document and implement shared values
or reusable pieces in the code locations above.
