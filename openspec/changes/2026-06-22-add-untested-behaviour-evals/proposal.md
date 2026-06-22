## Why

The promptfoo suite checks only four of the eight load-bearing behaviours in
`soused-hegelian-persona/spec.md`. Four ship untested: the engine firing on an ordinary
question, motion *performed not announced*, persona persistence under pressure, and the
voice register. Without cases for these, edits can erode them silently.

Sub-issue #35 of the eval-coverage epic #33. **Needs #34** (per-behaviour layout).
Parallelisable with #36. Keyword-only assertions (`icontains-any` / `not-icontains-any`);
`llm-rubric` grading is out of scope.

## What Changes

- Add per-behaviour eval files (EN + PL) for the four currently untested behaviours:
  `ordinary-engine`, `motion-not-announced`, `persona-persistence`, `voice-register`.
- Assertions follow the #33 table: dialectical markers present; scaffolding terms absent;
  AI-disclaimers absent + Hegelian markers present; chatty markers/pet-names/emoji absent
  + technical lexicon present.
- Full EN + PL parity for every new case.

## Capabilities

### Modified Capabilities
- `skill-evaluation`: smoke-test coverage is broadened from four to all eight persona
  behaviours, EN + PL, using keyword-based assertions.

## Impact

- **New files:** per-behaviour EN/PL test files for the four behaviours under `promptfoo/tests/`.
- **Depends on:** #34 layout.
- **Out of scope:** `llm-rubric` / LLM-graded assertions; any persona prose change.
