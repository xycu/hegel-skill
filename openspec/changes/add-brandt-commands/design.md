## Context

The plugin ships exactly one artifact — the `soused-hegelian` skill — and users
reach Brandt only through summon phrases they must already know. Claude Code
plugins auto-discover commands from a `commands/` directory at the plugin root;
the repo has none. The cross-tool-install capability requires a single canonical
persona source with generated, drift-guarded artifacts, so any new surface must
not fork the persona text.

## Goals / Non-Goals

**Goals:**
- Discoverable summon and dismissal from the `/` menu in Claude Code.
- Zero behavioural change to the persona: commands are routing, not rules.
- Deterministic validation (lint), consistent with how the rest of the package
  is guarded.

**Non-Goals:**
- No banish/opt-out of spontaneous mechanisms (separate change:
  `add-banish-lever`).
- No command surface for other tools (Gemini, Cursor, etc. have no plugin
  command system here; their install artifacts stay unchanged).
- No SLM eval coverage of commands — they are deterministic files, covered by
  lint and the manual release validation boundary.

## Decisions

- **Naming and layout: `commands/brandt.md` → `/brandt`, and a nested
  `commands/brandt/dismiss.md` → `/brandt:dismiss`.** Nested directories give
  the namespaced form users expect. If the plugin loader cannot serve both a
  `brandt.md` file and a `brandt/` directory side by side, fall back to a flat
  `commands/brandt-dismiss.md` (→ `/brandt-dismiss`); the spec names the
  preferred form but the dismiss requirement is form-agnostic.
- **Thin-wrapper principle.** Each command body is a short directive ("summon
  Doktor Brandt as a manual summon; treat `$ARGUMENTS` as the question" /
  "treat this as the sincere request to drop the persona") that leans on the
  installed skill. Rationale: the cross-tool-install spec's single-canonical-
  source requirement — duplicating engine prose in a command would create a
  second place for the persona to drift.
- **Lint extension over a new tool.** `skill_lint.py` already validates package
  shape (files, JSON, frontmatter); command checks are two more file checks in
  the same pass. Alternative — a separate command linter — rejected as
  needless surface.
- **Dismiss ≠ banish.** `/brandt:dismiss` maps to the already-specified sincere
  dismissal, which does not suppress future spontaneous mechanisms. Keeping
  that mapping exact avoids entangling this change with the banish lever.

## Risks / Trade-offs

- [Plugin command discovery/namespacing may differ across Claude Code versions]
  → verify manually in Claude Code before release, per the existing "Manual
  release validation boundary" requirement; the flat-name fallback is the
  escape hatch.
- [A user runs `/brandt:dismiss` with no summon active] → specified as a plain
  no-op acknowledgment, so no confusing error and no accidental persona turn.
- [Command text could drift from SKILL.md summon semantics over time] → the
  command carries no semantics of its own beyond "this is a manual summon /
  sincere dismissal"; the lint guards presence, the spec guards meaning.
