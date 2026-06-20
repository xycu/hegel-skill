## 1. Runner script

- [x] 1.1 Create executable `run-tests.sh` at the repo root (POSIX `sh`, `set -u`, no bashisms)
- [x] 1.2 Define `MODEL` (default `gemma4:e4b-it-qat`, overridable via env/positional arg) and EN/PL eval file path constants
- [x] 1.3 Add a per-stage runner that records each stage's name and exit status without aborting on first failure

## 2. Stages

- [x] 2.1 Stage: deterministic lint — `python tools/skill_lint.py`
- [x] 2.2 Stage: unit test — run from `tools/` so `run_skill_evals` imports: `(cd tools && python test_run_skill_evals.py)`
- [x] 2.3 Stage: English evals — `python tools/run_skill_evals.py --model "$MODEL" --evals evals/hegel_skill_cases.en.json`
- [x] 2.4 Stage: Polish evals — `python tools/run_skill_evals.py --model "$MODEL" --evals evals/hegel_skill_cases.pl.json`

## 3. Ollama lifecycle

- [x] 3.1 Probe `$OLLAMA_HOST/api/tags`; if a server is already running, use it and leave it running
- [x] 3.2 If Ollama is installed but stopped, start `ollama serve`, wait for readiness, and shut it down via an EXIT/INT/TERM trap (only the server we started)
- [x] 3.3 If Ollama is not installed and not running, fail the eval stages with a clear message
- [x] 3.4 Auto-pull the configured model when `ollama show "$MODEL"` reports it absent; fail if the pull fails

## 4. Reporting

- [x] 4.1 Print a per-stage PASS/FAIL summary after all stages run
- [x] 4.2 Exit `0` only if every stage passed; exit non-zero if any failed

## 5. Documentation

- [x] 5.1 Document `./run-tests.sh` as the canonical pre-push command in the README, with prerequisites (Python 3.12, Ollama, `ollama pull gemma4:e4b-it-qat`)
- [x] 5.2 Add/refresh the corresponding note in AGENTS.md

## 6. Verification

- [x] 6.1 Run `./run-tests.sh` with the model pulled; confirm all four stages pass and exit code is `0`
- [x] 6.2 Confirm lifecycle: already-running server is used and left running; an installed-but-stopped server is started and then shut down
- [x] 6.3 Confirm a missing model / unreachable Ollama produces a non-zero exit with a clear message
- [x] 6.4 Confirm a missing model is auto-pulled before the eval stages run
