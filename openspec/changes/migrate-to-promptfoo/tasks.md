## 1. promptfoo scaffolding

- [ ] 1.1 Record a pinned promptfoo version in a single place (a variable in `run-tests.sh`; CI installs the same version).
- [ ] 1.2 Add a shared prompt function under `promptfoo/` that reads `SKILL.md` + `references/hegel-reference.md` and returns a chat array (`system` = skill + reference, `user` = the case prompt var).
- [ ] 1.3 Add `promptfoo/promptfooconfig.en.yaml` and `promptfoo/promptfooconfig.pl.yaml` sharing the prompt + an `ollama:chat:<model>` provider, with the model parameterised (env var, default `gemma4:e4b-it-qat`).
- [ ] 1.4 Set provider `config` (e.g. `temperature`, `num_predict`, timeout) to match the old runner's request parameters as closely as possible.

## 2. Port eval cases and assertions

- [ ] 2.1 Convert `evals/hegel_skill_cases.en.json` into `promptfoo/tests.en.yaml` (one test per case, `vars.prompt` + `assert` list).
- [ ] 2.2 Convert `evals/hegel_skill_cases.pl.json` into `promptfoo/tests.pl.yaml`.
- [ ] 2.3 Map assertions 1:1: `must_include_any`→`contains-any`, `must_include_all`→`contains-all`, `must_not_include`→`not-icontains`.
- [ ] 2.4 Add the advisory slop-footer assertion to each case: `regex: 'slop:\s*\d+\s*/\s*10'` with `weight: 0` (and a metric name).

## 3. Wire the local runner

- [ ] 3.1 Update `run-tests.sh`: keep the `lint` stage, remove the `unit` stage.
- [ ] 3.2 Add a promptfoo resolver: prefer a global `promptfoo` on `PATH`, else fall back to `npx -y promptfoo@<pinned>`; print the resolved version at startup.
- [ ] 3.2a Replace the two custom-runner eval stages with `<resolved-promptfoo> eval -c <config>` for EN and PL.
- [ ] 3.3 Export `OLLAMA_BASE_URL` (derived from `OLLAMA_HOST`) and the eval-model env var so promptfoo and the override path work.
- [ ] 3.4 Confirm Ollama lifecycle, model auto-pull, all-stages-run, and non-zero-on-failure still behave correctly.

## 4. Verify parity locally (local-first)

- [ ] 4.1 Run `./run-tests.sh` and confirm lint + EN + PL all pass against `gemma4:e4b-it-qat`.
- [ ] 4.2 Verify a deliberately footer-less output does NOT fail its case (advisory weight-0 confirmed).
- [ ] 4.3 Verify failure paths: Ollama unavailable → non-zero; a broken assertion → the right stage fails.
- [ ] 4.4 Verify the model-override path (`MODEL=… ./run-tests.sh` / positional arg) reaches the promptfoo provider.

## 5. Update CI

- [ ] 5.1 Update `.github/workflows/skill-ci.yml` to install the pinned promptfoo (`npm install -g promptfoo@<pinned>`) and run `promptfoo eval` per matrix language, keeping the matrix and the model pull.
- [ ] 5.2 Keep the deterministic lint job unchanged.

## 6. Remove the custom harness

- [ ] 6.1 Delete `tools/run_skill_evals.py` and `tools/test_run_skill_evals.py`.
- [ ] 6.2 Delete `evals/hegel_skill_cases.en.json` and `evals/hegel_skill_cases.pl.json` once parity is confirmed.

## 7. Docs

- [ ] 7.1 Update `README.md` "Testing" section to describe the promptfoo suite and commands.
- [ ] 7.2 Update `AGENTS.md` "Tests" section accordingly.

## 8. Validate and finish

- [ ] 8.1 Run `openspec validate migrate-to-promptfoo --strict` clean.
- [ ] 8.2 Open the PR; confirm CI (lint + promptfoo EN/PL + OpenSpec validate) is green.
