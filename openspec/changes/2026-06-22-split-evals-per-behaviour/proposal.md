## Why

The promptfoo eval cases live in two monolithic files (`promptfoo/tests.en.yaml`,
`promptfoo/tests.pl.yaml`). As coverage grows (#35 adds the four untested behaviours,
#36 adds robustness variants) a single file per language becomes hard to navigate and
review per behaviour. Splitting into one file per behaviour (EN + PL) establishes the
layout the new-case work extends cleanly. This is a pure refactor: same eight cases,
same assertions, same model, same pass/fail, same CI gate.

Sub-issue #34 of the eval-coverage epic #33. **Blocks #35 and #36.**

## What Changes

- Split each language's test file into one file per persona behaviour under
  `promptfoo/tests/` (exact naming decided in tasks).
- Migrate the existing eight cases unchanged into the per-behaviour files.
- Update `promptfooconfig.en.yaml` / `promptfooconfig.pl.yaml` to include every
  per-behaviour file.
- No change to assertions, the eval model, or the CI gate.

## Capabilities

### Modified Capabilities
- `skill-evaluation`: the EN/PL smoke-test case sets are organised as one file per
  behaviour rather than one file per language; case content and assertions are preserved.

## Impact

- **Modified files:** `promptfoo/promptfooconfig.{en,pl}.yaml`, the EN/PL test files
  (relocated under `promptfoo/tests/`).
- **Behaviour preserved:** same eight cases, same assertions, same pass/fail.
- **Unblocks:** #35, #36.
