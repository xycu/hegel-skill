## Why

The skill's SLM smoke evals run on a hand-rolled Python harness (`tools/run_skill_evals.py`)
with its own Ollama HTTP client, JSON case schema, assertion logic, and a unit test for that
logic. Maintaining a bespoke eval framework is effort better spent elsewhere:
[promptfoo](https://www.promptfoo.dev/) is a mature, declarative eval tool that already does
all of this — Ollama provider, contract assertions, reporting — and unlocks richer assertions
and multi-provider runs later (tracked in #5 and #6) without us writing more harness code.

This change is a deliberate **lift & shift**: same models, same cases, same pass/fail
behaviour, same CI gate — only the engine underneath changes. New capabilities promptfoo
enables are explicitly out of scope and will land on their own branches.

## What Changes

- Add a promptfoo configuration (`promptfooconfig.yaml`) that evaluates the `soused-hegelian`
  skill against the local Ollama model `gemma4:e4b-it-qat`, injecting `SKILL.md` +
  `hegel-reference.md` as the system prompt.
- Port the EN and PL eval cases from `evals/hegel_skill_cases.{en,pl}.json` into promptfoo
  test files, **both languages preserved**.
- Port the assertions 1:1: `must_include_any`→`contains-any`, `must_include_all`→`contains-all`,
  `must_not_include`→`not-icontains` (case-insensitive, as today), and the advisory `slop:`
  footer → a `regex` assertion with `weight: 0` (reported as a metric, never fails the test —
  matching today's advisory behaviour).
- **BREAKING (internal tooling):** remove the custom runner `tools/run_skill_evals.py` and its
  unit test `tools/test_run_skill_evals.py` (the assertion logic they implemented now lives in
  promptfoo); remove the now-superseded `evals/*.json` case files once ported.
- Update `run-tests.sh`: keep the deterministic lint stage, drop the `unit` stage (nothing custom
  left to unit-test), and replace the two custom-runner eval stages with promptfoo invocations.
  Ollama lifecycle management and model auto-pull are preserved.
- Update CI (`.github/workflows/skill-ci.yml`) to run promptfoo for the EN and PL evals.
- Update docs (`README.md`, `AGENTS.md`) to describe the promptfoo-based suite.

Provider scope: **local Ollama only** for now. Hosted providers (#6) and semantic assertions
(#5) are out of scope.

## Capabilities

### New Capabilities
<!-- none: this is a mechanism migration of existing capabilities -->

### Modified Capabilities
- `skill-evaluation`: the SLM eval runner, the contract-based assertions, the slop-footer
  advisory, the CI integration, and the local-execution docs all move from the custom Python
  harness to promptfoo. Behaviour (which markers pass/fail, advisory footer, EN+PL coverage,
  CI gate) is preserved; the mechanism changes.
- `local-test-runner`: the single root command drops the eval-runner unit stage (the custom
  code it tested is removed) and drives promptfoo for the EN/PL eval stages instead of the
  custom runner. Lint stage, Ollama lifecycle, model auto-pull, model override, and the
  all-stages-run/non-zero-on-failure contract are preserved.

## Impact

- **Dependencies:** adds promptfoo as a dev tool. The runner prefers a global `promptfoo`
  binary (`npm install -g promptfoo`) and falls back to a pinned `npx -y promptfoo@<version>`
  when none is on `PATH`; CI installs the pinned version. Node is already required for OpenSpec.
- **New files:** `promptfooconfig.yaml`, a prompt template, and ported EN/PL test files
  (likely under `promptfoo/`).
- **Removed files:** `tools/run_skill_evals.py`, `tools/test_run_skill_evals.py`,
  `evals/hegel_skill_cases.en.json`, `evals/hegel_skill_cases.pl.json`.
- **Modified files:** `run-tests.sh`, `.github/workflows/skill-ci.yml`, `README.md`, `AGENTS.md`.
- **Behaviour preserved:** same model (`gemma4:e4b-it-qat`), same cases, same pass/fail
  semantics, same advisory footer, same CI gate, same local-first workflow.
- **Out of scope (tracked):** richer/semantic assertions (#5), hosted Claude provider (#6).
