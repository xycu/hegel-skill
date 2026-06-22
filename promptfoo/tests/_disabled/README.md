# Parked eval cases

Files here are **excluded** from the eval suite: the configs glob `tests/*.{en,pl}.yaml`
(non-recursive), so this subdirectory is not picked up.

## Why parked (CI runtime)

Each live case now runs the model-graded `llm-rubric` asserts (#31) and, for some,
`similar` embedding asserts (#32), all on a single CPU-bound Ollama in CI. Running all
eight behaviours per language overran the 90-minute job timeout. To keep CI green we run
the **three core behaviours** — `dialectical`, `grief`, `technical-dismissal` (EN + PL) —
and parked the rest here:

- `motion-not-announced`, `ordinary-engine`, `persona-explicit`, `persona-persistence`,
  `voice-register`.

Restore them (move back up to `tests/`) once llm-rubric grading is fast/cheap enough —
tracked by the eval-tuning-gate work (#37). The shared rubrics in `defaultTest` still
cover whatever is live, so the parked cases lose only their behaviour-specific keyword
asserts while parked.
