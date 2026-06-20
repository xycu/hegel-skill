## Context

The skill's model-based smoke evals run on a bespoke Python harness:

- `tools/run_skill_evals.py` — an Ollama HTTP client that builds a system prompt from
  `SKILL.md` + `hegel-reference.md`, sends each case's prompt, and checks the response
  against a custom JSON assertion schema (`must_include_any` / `must_include_all` /
  `must_not_include`) plus an advisory `slop:` footer check.
- `tools/test_run_skill_evals.py` — a unit test for that assertion logic.
- `evals/hegel_skill_cases.{en,pl}.json` — the EN and PL case files.
- `run-tests.sh` — orchestrates lint → unit → EN evals → PL evals, manages the Ollama
  lifecycle, and auto-pulls the model.
- `.github/workflows/skill-ci.yml` — runs the same on a per-language matrix using
  `gemma4:e4b-it-qat`.

[promptfoo](https://www.promptfoo.dev/) is a mature declarative eval framework with a
first-class Ollama provider, the deterministic assertions we already rely on, and
reporting — so the bespoke harness is maintenance we can shed. Node is already a project
dependency (OpenSpec runs via `npx`).

Constraint: this is a **lift & shift**. The model, the cases, the pass/fail semantics,
the advisory footer, EN+PL coverage, and the CI gate must all be preserved. Anything
promptfoo newly enables (semantic assertions #5, hosted providers #6) is out of scope.

## Goals / Non-Goals

**Goals:**
- Replace the custom eval runner with promptfoo while preserving behaviour exactly.
- Keep the deterministic lint (`tools/skill_lint.py`) as-is and folded into the unified
  flow.
- Preserve `run-tests.sh` as the one local command (Ollama lifecycle + auto-pull intact)
  and keep CI mirroring it.
- Keep both EN and PL coverage.
- Remove the now-dead custom runner, its unit test, and the old JSON case files.

**Non-Goals:**
- Semantic/LLM-graded assertions (`llm-rubric`, custom asserts) — #5.
- Hosted/non-Ollama providers — #6.
- Changing which markers each case checks, the model, or the CI trigger matrix.
- Replacing the Python lint with promptfoo (promptfoo is not a structural linter).

## Decisions

### 1. Resolve promptfoo: prefer a global binary, fall back to pinned `npx`

`run-tests.sh` SHALL use a global `promptfoo` binary if one is on `PATH`, otherwise fall
back to `npx -y promptfoo@<pinned-version>`. This gives the fastest path for a developer
who has run `npm install -g promptfoo`, while keeping a zero-install, reproducible path
for fresh machines. The pinned version lives in a single place (a variable in
`run-tests.sh`) and is the version CI installs.

CI SHALL pin the version explicitly — `npm install -g promptfoo@<pinned-version>` — so a
local pass predicts a CI pass even though developers' global installs may drift. The one
risk of the hybrid is exactly that drift: a developer's global `promptfoo` differing from
the pinned version. Mitigation: the runner prints the resolved promptfoo version at
startup, so a mismatch with CI is visible.

*Alternatives considered:* (a) pinned `npx` only — reproducible but pays resolution
overhead every run; (b) global install only — fastest but silently drifts from CI,
undercutting the local-first guarantee; (c) a `package.json` devDependency — introduces a
lockfile and an install step for a repo with no Node manifest today. The hybrid keeps the
best of (a) and (b).

### 2. Two per-language configs sharing one prompt

Use two promptfoo configs — `promptfoo/promptfooconfig.en.yaml` and `…​.pl.yaml` — each
pointing at its own test file (`promptfoo/tests.en.yaml`, `tests.pl.yaml`) and at a
**shared** prompt definition and provider. This maps cleanly onto the existing EN/PL
split: two `run-tests.sh` stages and the two-entry CI matrix, each pulling the model and
running its language independently.
*Alternative considered:* one config running both languages — simpler file count but
loses the per-language stage/matrix separation and per-language reporting we have today.

### 3. Prompt assembled by a prompt function

The system prompt must concatenate `SKILL.md` + `references/hegel-reference.md` (exactly
what the custom runner did). Use a promptfoo prompt **function** (a small file that reads
both files and returns a chat array of `{system, user}` with the case prompt as the user
turn). This reproduces the current behaviour precisely and keeps the large reference text
out of every case.
*Alternative considered:* Nunjucks templating with file includes — awkward for injecting
two whole files; a function is clearer and testable by just running the suite.

### 4. Assertion mapping (1:1)

| custom schema | promptfoo assertion | notes |
|---|---|---|
| `must_include_any` | `icontains-any` | case-insensitive — the old runner lowercased both sides |
| `must_include_all` | `icontains-all` | case-insensitive, ditto |
| `must_not_include` | `not-icontains-any` | passes when none of the terms appear (case-insensitive) |
| `slop:` footer (advisory) | `regex: '[Ss][Ll][Oo][Pp]:\s*\d+\s*/\s*10'` with `weight: 0` | non-blocking metric |

(The prior runner's `check_case` lowercases both the output and every term, so all three
checks are case-insensitive; the `i`-variants reproduce that exactly.)

The `weight: 0` footer assertion is promptfoo's idiom for a tracking assertion that
contributes a metric but never fails the test — exactly the old advisory semantics.

### 5. Ollama wiring and model override

promptfoo reads `OLLAMA_BASE_URL` (default `http://localhost:11434`); the runner uses
`OLLAMA_HOST`. `run-tests.sh` will export `OLLAMA_BASE_URL` derived from `OLLAMA_HOST` so
both agree. The eval model is parameterised (env var, default `gemma4:e4b-it-qat`)
interpolated into the provider id in the configs, so the existing model-override path
(argument / env var) keeps working; the deterministic lint is unaffected.

### 6. `run-tests.sh` and CI shape

`run-tests.sh`: keep the lint stage; **drop the `unit` stage** (the custom assertion code
it tested is gone); replace the two custom-runner eval stages with
`npx promptfoo eval -c <config>` per language. Ollama lifecycle, auto-pull, all-stages-run,
and non-zero-on-any-failure are unchanged. CI: swap the per-language python eval step for
the matching `npx promptfoo eval`, keeping the matrix and the model pull.

## Risks / Trade-offs

- **`npx` network/version drift** → pin an exact promptfoo version in one place; CI caches
  npx where possible.
- **Provider output differences** (promptfoo's Ollama defaults — `num_predict`,
  `temperature`, timeout — may differ from the custom client) → set the provider `config`
  to match the old runner's request parameters; re-run locally and adjust case markers
  only if a deterministic assertion genuinely shifts (must be justified, not loosened to
  paper over a regression).
- **weight-0 advisory semantics** → verify locally that a deliberately footer-less output
  does not fail its case before trusting it.
- **Loss of the assertion unit test** → acceptable: the logic now lives in promptfoo
  (tested upstream); our remaining risk is config correctness, which is exercised every
  time the suite runs against real cases.
- **Case transcription errors** in the JSON→YAML port → convert carefully and confirm
  parity by running `./run-tests.sh` green before deleting the old JSON.

## Migration Plan

1. Add the promptfoo configs, the shared prompt function, and the ported EN/PL test files.
2. Wire `run-tests.sh` to promptfoo (drop the `unit` stage; map `OLLAMA_HOST` →
   `OLLAMA_BASE_URL`).
3. Update `.github/workflows/skill-ci.yml` to run promptfoo per matrix language.
4. Run `./run-tests.sh` locally and confirm EN + PL parity (green) — local-first, before
   spending CI minutes.
5. Remove `tools/run_skill_evals.py`, `tools/test_run_skill_evals.py`, and
   `evals/hegel_skill_cases.{en,pl}.json`.
6. Update `README.md` and `AGENTS.md` to describe the promptfoo suite.

**Rollback:** revert the branch; the custom runner remains in git history and CI returns
to the prior workflow.

## Open Questions

- Prompt-function language: Python (matches existing tooling) vs JavaScript (promptfoo's
  native path). Leaning Python; will fall back to JS if promptfoo's Python prompt
  integration is fiddly in CI.
- Exact provider tuning (`num_predict`, `temperature`) needed to keep outputs close enough
  that the existing markers still pass without loosening — to be settled empirically in
  step 4.
