## Why

Each of the four currently-covered behaviours hinges on a single case and a single keyword
match. One lucky phrasing can carry a behaviour green while the underlying rule is broken.
Adding variants — different surface phrasing and different domains per behaviour — makes the
signal robust.

Sub-issue #36 of the eval-coverage epic #33. **Needs #34** (per-behaviour layout).
Parallelisable with #35. Keyword-only assertions; `llm-rubric` is out of scope.

## What Changes

- Add robustness variant cases (EN + PL) to the existing behaviours:
  - **technical-dismissal:** arithmetic, SQL/regex, and a mundane prompt ("weather").
  - **grief:** a breakup and a terminal-diagnosis prompt.
  - **dialectical:** one additional paraphrase.
  - **persona-explicit:** one additional paraphrase.
- Full EN + PL parity. Target ~15 cases per language (up from four), combined with #35.

## Capabilities

### Modified Capabilities
- `skill-evaluation`: each covered behaviour is exercised by more than one case (EN + PL),
  varying phrasing and domain, so no single prompt phrasing alone satisfies a behaviour.

## Impact

- **Modified/new files:** additional cases in the per-behaviour EN/PL test files under `promptfoo/tests/`.
- **Depends on:** #34 layout.
- **Out of scope:** `llm-rubric` / LLM-graded assertions; any persona prose change.
