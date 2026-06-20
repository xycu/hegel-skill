## 1. Runner script

- [ ] 1.1 Create executable `run-tests.sh` at the repo root (POSIX `sh`, `set -u`, no bashisms)
- [ ] 1.2 Define `MODEL` (default `gemma4:e4b-it-qat`, overridable via env/positional arg) and EN/PL eval file path constants
- [ ] 1.3 Add a per-stage runner that records each stage's name and exit status without aborting on first failure

## 2. Stages

- [ ] 2.1 Stage: deterministic lint — `python tools/skill_lint.py`
- [ ] 2.2 Stage: unit test — run from `tools/` so `run_skill_evals` imports: `(cd tools && python test_run_skill_evals.py)`
- [ ] 2.3 Stage: English evals — `python tools/run_skill_evals.py --model "$MODEL" --evals evals/hegel_skill_cases.en.json`
- [ ] 2.4 Stage: Polish evals — `python tools/run_skill_evals.py --model "$MODEL" --evals evals/hegel_skill_cases.pl.json`

## 3. Reporting

- [ ] 3.1 Print a per-stage PASS/FAIL summary after all stages run
- [ ] 3.2 Exit `0` only if every stage passed; exit non-zero if any failed (propagating the Ollama-unreachable failure from the eval stages)

## 4. Documentation

- [ ] 4.1 Document `./run-tests.sh` as the canonical pre-push command in the README, with prerequisites (Python 3.12, running Ollama, `ollama pull gemma4:e4b-it-qat`)
- [ ] 4.2 Add/refresh the corresponding note in AGENTS.md

## 5. Verification

- [ ] 5.1 Run `./run-tests.sh` with Ollama running and the model pulled; confirm all four stages pass and exit code is `0`
- [ ] 5.2 Run with Ollama stopped; confirm the runner fails with a non-zero exit and reports Ollama unreachable
