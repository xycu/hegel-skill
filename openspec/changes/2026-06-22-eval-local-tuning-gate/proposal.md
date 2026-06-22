## Why

Keyword assertions run against a small local model are noisy: a term list that looks right
can misfire on the actual SLM output. Discovering that in CI wastes runner minutes and reds
`main`. New or changed eval cases SHALL therefore be tuned to green locally before they are
pushed. This codifies the local-first discipline the epic depends on.

Sub-issue #37 of the eval-coverage epic #33. **Needs #35 and #36** (the cases to tune).
Do last.

## What Changes

- Run the full EN + PL suite locally against the Ollama SLM, tune each new/changed case's
  keyword lists until green, and only then push.
- Document the local-first eval gate so the rule is discoverable, not folklore.

## Capabilities

### Modified Capabilities
- `skill-evaluation`: adds a local-first tuning gate — new/changed cases must pass locally
  against the configured model before push.

## Impact

- **Modified files:** tuned keyword lists in the per-behaviour EN/PL test files; a docs note
  on the local-first gate.
- **Depends on:** #35, #36.
- **No CI behaviour change** beyond fewer red runs caused by untuned keyword lists.
