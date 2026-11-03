# TenK

## App language

- Write all user-facing app UI text in English. This includes labels, buttons,
  hints, validation messages, accessibility labels, and placeholder copy.
- Preserve user-provided content as entered, including activity names. Do not
  translate or rewrite user data to enforce the UI language.
- Keep agent-maintained documentation in English.

## Design system

- Follow `docs/design-system.md` when adding or changing screens, overlays, or
  reusable UI components. Keep shared visual values in `lib/app/app_theme.dart`
  and shared components in `lib/ui/widgets/`.

## Backlog and project tracking

- GitHub Issues and the TenK GitHub Project are the source of truth for the project backlog, priorities, and task status.
- Use repository `evgenygamza/tenk` and the user-owned project [TenK](https://github.com/users/evgenygamza/projects/1).
- Read the issue, its comments, and its current Project fields before planning or implementing backlog work. Use the Project's `Status` values: `Backlog`, `In Progress`, `Testing`, `Suspended`, and `Done`; use `Priority` values `p1` through `p4`.
- Treat issues as independently actionable tasks. Use GitHub sub-issues to represent epic hierarchy; preserve parent links when working on a sub-issue. When creating an issue, inspect existing epics and propose the best-fitting parent. Prefer grouping actionable tasks under an epic when one fits; if none fits, ask whether to create an epic or leave the task standalone. Create the relationship after the user agrees unless they already specified it.
- When a sub-issue moves to `In Progress` or `Testing`, also keep its parent epic in `In Progress`. Keep the epic active while child work is underway or awaiting acceptance; do not close it until its child work is accepted.
- Close an issue only after user acceptance. If the project or issue cannot be accessed or identified unambiguously, ask the user instead of selecting a different project.

## Context efficiency

- Do not print tool catalogs or full API responses. Find the required tool first and retain only fields needed for the next action or report.
- Read files by relevant paths and line ranges. Keep command output bounded to the evidence needed to make a decision.
- Run required checks only. Do not perform exploratory or duplicate checks unless a failure or new change makes them necessary.
- The user runs automated tests and verification commands. Add or update meaningful test coverage and record the commands, expected results, and any user-reported results, but do not run tests, analyzers, builds, or simulators unless the user explicitly asks in the current task.
