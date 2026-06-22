## Why

Keyword assertions are brittle for a deliberately high-temperature, creative persona: an
answer can be fully in character yet miss a keyword list, flipping a 100% gate red
run-to-run. This forced disabling three otherwise-correct cases during #33 (#60, #62,
#63). `llm-rubric` grades **meaning**, not strings, so it tolerates phrasing variance and
makes the suite trustworthy.

Sub-issue #31 of epic #5. _Tier: Medium, needs #30._

## What Changes

- Add `llm-rubric` assertions (EN + PL) grading what string checks miss:
  - **voice register** (elevated, periodic, melancholy-decadent, cynical-not-cruel),
  - **dialectical-engine adherence** (fixed notion → determinate negation → sublation,
    performed not announced),
  - **citation fidelity** (named works, no fabricated quotes),
  - **in-character technical dismissal**.
- Default to **advisory (weight 0)** metrics first (slop-footer precedent), promotable to
  thresholded per #30's gating policy.
- **Re-enable #60, #62, #63** as rubric-graded cases (moved back from `promptfoo/tests/_disabled/`),
  keeping the high temperature.

## Capabilities

### Modified Capabilities
- `skill-evaluation`: gains semantic `llm-rubric` quality assertions and re-enables the
  previously-disabled cases under rubric grading instead of brittle keyword lists.

## Impact

- **Depends on #30** (grader model). Reuses the custom-assert plumbing from #29.
- **Re-enables:** #60 (en-persona-persistence), #62 (pl-technical-dismissal-mundane), #63 (pl-motion-not-announced).
- Keeps the high temperature — do not switch to greedy.
