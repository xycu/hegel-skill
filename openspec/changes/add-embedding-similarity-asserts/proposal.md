## Why

Some regressions are best caught by closeness to a known-good reference answer rather than
keywords or a rubric. promptfoo's `similar` assertion (embedding similarity) covers this —
e.g. a response drifting semantically away from a reference Brandt answer.

Sub-issue #32 of epic #5. _Tier: Medium–High, needs #30_ — sequence last (highest infra surface).

## What Changes

- Add `similar` (embedding-similarity) assertions against curated reference answers for a
  few representative behaviours (EN + PL).
- Use the embedding provider chosen under #30; advisory first, thresholded per the gating policy.

## Capabilities

### Modified Capabilities
- `skill-evaluation`: gains embedding-similarity assertions against reference answers,
  complementing keyword, custom, and rubric checks.

## Impact

- **Depends on #30** (embedding/grader provider). Highest infra surface of the epic → done last.
- **New files:** reference answers + similarity asserts under `promptfoo/`.
