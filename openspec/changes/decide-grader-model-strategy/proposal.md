## Why

`llm-rubric` and `similar` assertions need a **judge/grader model**. Choosing it (local
Ollama vs a hosted model), and how it interacts with the spec's manual-validation
boundary, is a decision that blocks the rubric work. This change records the decision and
the boundary update so #31 and #32 implement against a settled strategy.

Sub-issue #30 of epic #5. _Decision / spike_ — **blocks #31 and #32.**

## What Changes

- Decide the grader-model strategy: local (Ollama) vs hosted judge, including cost/runtime
  envelope and how secrets (if any) are provided — no hard-coded secrets.
- Update the eval spec to permit **automated judge-model grading** as a distinct, bounded
  mechanism (refining the manual-release-validation boundary so model-graded asserts are
  allowed in CI under the agreed gating policy).

## Capabilities

### Modified Capabilities
- `skill-evaluation`: gains a stated grader-model strategy and an explicit allowance for
  automated judge-model grading (advisory or thresholded per the gating policy).

## Impact

- **Decision doc / spec delta only** — no eval cases yet. Unblocks #31 (llm-rubric) and #32 (similar).
- **Secrets:** strategy must avoid hard-coded secrets; hosted option uses CI secrets if chosen.
