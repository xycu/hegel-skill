## Context

Three local test entry points exist today, each invoked separately:

- `python tools/skill_lint.py` — deterministic skill-package lint (stdlib only).
- `python tools/test_run_skill_evals.py` — assertion-logic unit test for the eval
  runner. It does `from run_skill_evals import ...`, so it must run with `tools/` on
  `sys.path` (i.e. run from inside `tools/`, not from the repo root).
- `python tools/run_skill_evals.py --model <m> --evals <f>` — SLM evals against a local
  Ollama model; `--model` and `--evals` are both required, and the runner already exits
  non-zero when Ollama is unreachable.

CI (`.github/workflows/skill-ci.yml`) runs lint, then the SLM evals as a matrix over
`en` and `pl` on `gemma4:e4b-it-qat`. Notably, CI does **not** run the unit test; the
local runner will, since it is fast and free. The project's working rule is to iterate
locally (Ollama + Metal) before spending CI minutes.

## Goals / Non-Goals

**Goals:**
- One command from the repo root runs lint + unit + EN evals + PL evals.
- Behaviour mirrors CI: SLM evals always run; a missing Ollama or model is a hard failure.
- Clear per-stage pass/fail summary and an aggregate non-zero exit on any failure.
- Model overridable for local experimentation without editing the script.

**Non-Goals:**
- No new test framework or dependencies — wrap the existing scripts as-is.
- No change to CI, to the eval runner, or to the skill package.
- No automatic installing of Ollama itself; an absent binary is reported, not fixed. (The
  runner does *start* an already-installed server and *pull* a missing model.)

## Decisions

**A POSIX `sh` script at the repo root (`run-tests.sh`), not a Makefile or Python wrapper.**
The repo is Markdown-first with a few stdlib Python tools; a small shell script is the
lowest-ceremony "single command" and needs nothing installed beyond what CI already
assumes. Alternative — a `Makefile` target — adds a tool the repo doesn't otherwise use;
a Python orchestrator would itself need the `tools/` import dance and more code.

**Run stages sequentially, fastest-first, but do not stop at the first failure.**
Order: lint → unit → EN evals → PL evals. Run all four, collect per-stage results, print a
summary, and exit `1` if any failed. Rationale: deterministic stages are instant and
finding all failures in one pass beats forcing re-runs. (Considered fail-fast; rejected
because the cheap stages give useful signal even when a later eval fails.)

**Fix the unit-test import by running it from `tools/`.** Invoke it as
`(cd tools && python test_run_skill_evals.py)` so `run_skill_evals` is importable. This
keeps the existing test file untouched.

**Default model and eval files are constants matching CI.** `MODEL` defaults to
`gemma4:e4b-it-qat`; EN/PL eval file paths match the workflow. `MODEL` is overridable via
environment variable (and/or first positional arg), so `MODEL=other ./run-tests.sh` works
for experimentation. The deterministic stages ignore the override.

**The runner manages the Ollama server lifecycle.** Before the eval stages it probes
`$OLLAMA_HOST/api/tags`: if a server answers, use it and leave it alone; if not and the
`ollama` binary exists, start `ollama serve` in the background, wait for readiness, and
record that *we* started it so an `EXIT`/`INT`/`TERM` trap shuts down only that server;
if the binary is absent, fail the eval stages with a clear message. This makes the common
"I forgot to start Ollama" case just work without leaking a server the developer didn't
ask for. It also auto-pulls the model when `ollama show "$MODEL"` reports it absent, so a
fresh checkout needs no manual `ollama pull`. The eval runner still owns the per-case
Ollama errors.
Alternative — let `run_skill_evals.py` fail when Ollama is down — was the first cut but
forced the developer to start/stop the server by hand every run.

## Risks / Trade-offs

- [Pulling the model is slow / not present] → The runner does not auto-pull; it fails and
  the summary shows the eval stage failing. Document `ollama pull gemma4:e4b-it-qat` as a
  prerequisite next to the command.
- [SLM evals are slow and nondeterministic] → Accepted: mirroring CI was the explicit
  requirement. The fast deterministic stages still run first so lint/logic regressions
  surface immediately.
- [`sh` portability] → Keep to POSIX constructs (no bashisms); the script targets macOS
  (developer) and Linux (CI parity) shells.
