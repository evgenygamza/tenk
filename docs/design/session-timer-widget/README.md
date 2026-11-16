# Session timer widget handoff

Design status: implemented in Flutter for owner verification; live visual checks are pending. `SPEC.md` overrides the original milestone ring with selected-activity weekly progress against a three-hour default target, replaces the session counter with today’s accumulated practice, and removes the large stopped-state layout reserve. Each timer belongs to its activity page and slides with it.

## Files

- `screen-reference.png`: selected full-screen concept, stopped and running.
- `widget-reference.png`: generated isolated material reference, two states. A visual reference, not a runtime asset.
- `stopped.svg`, `running.svg`: editable, dimensionally consistent component drawings with transparent surroundings.
- `geometry.svg`: comparison at a common center, with dimensions.
- `SPEC.md`: behavior, layout, materials, motion, data requirements, and acceptance checklist.

The SVGs specify geometry and content; their glass is a static approximation. Actual glass needs the live scene behind the widget. Raster references are illustrative: prioritize SPEC.md for progress calculation, dimensions, accessibility, and state behavior. Example values and estimated days are fixtures, not user data or a verified forecast.
