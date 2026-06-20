## Why

The repository now has three separate local test entry points — the deterministic
skill lint, the eval-runner unit test, and the per-language SLM evals — but no single
way to run them all. Contributors must remember three commands, the correct model name,
and both eval files, which makes "run everything before I push" error-prone and
discourages the local-first iteration the project relies on to avoid burning CI minutes.

## What Changes

- Add a single executable script at the repository root that runs **all** existing tests
  in one command: deterministic skill lint, the eval-runner unit test, and the SLM evals
  for English and Polish.
- The runner mirrors CI: it always runs the SLM evals and **fails** (non-zero exit) if
  Ollama is unreachable or the configured model is unavailable — there is no silent skip.
- The runner uses the same default model as CI (`gemma4:e4b-it-qat`) and the same eval
  files (`evals/hegel_skill_cases.en.json`, `evals/hegel_skill_cases.pl.json`), with the
  model overridable for local experimentation.
- The runner reports a per-stage pass/fail summary and exits non-zero if any stage fails.
- Document the single command in the project README / AGENTS guidance as the canonical
  pre-push check.

## Capabilities

### New Capabilities
- `local-test-runner`: a single root-level command that orchestrates every existing local
  test (lint, unit, SLM evals EN+PL), mirrors CI strictness, and reports an aggregate result.

### Modified Capabilities
<!-- None. The individual lint/unit/eval commands are unchanged; this only orchestrates them. -->

## Impact

- New file: a runner script at the repo root (e.g. `run-tests.sh`).
- Wraps existing tools unchanged: `tools/skill_lint.py`, `tools/test_run_skill_evals.py`,
  `tools/run_skill_evals.py`.
- Documentation: README / AGENTS.md gain a "run all tests locally" entry.
- Dependencies: requires Python 3.12 and a running Ollama server with the configured model
  pulled — the same prerequisites as the CI SLM smoke jobs.
- No change to CI workflows or to the skill package itself.
