## 1. promptfoo scaffolding

- [x] 1.1 Record a pinned promptfoo version in a single place (a variable in `run-tests.sh`; CI installs the same version). → `0.121.17`
- [x] 1.2 Add a shared prompt function under `promptfoo/` that reads `SKILL.md` + `references/hegel-reference.md` and returns a chat array (`system` = skill + reference, `user` = the case prompt var). → `promptfoo/prompt.js`
- [x] 1.3 Add `promptfoo/promptfooconfig.en.yaml` and `promptfoo/promptfooconfig.pl.yaml` sharing the prompt + an `ollama:chat:<model>` provider, with the model parameterised (env var, default `gemma4:e4b-it-qat`).
- [x] 1.4 Set provider `config` (e.g. `temperature`, `num_predict`, timeout) to match the old runner's request parameters as closely as possible. → `num_ctx 12288`, `num_predict 1600`, `temperature 0.7`, `seed 7`.

## 2. Port eval cases and assertions

- [x] 2.1 Convert `evals/hegel_skill_cases.en.json` into `promptfoo/tests.en.yaml` (one test per case, `vars.prompt` + `assert` list).
- [x] 2.2 Convert `evals/hegel_skill_cases.pl.json` into `promptfoo/tests.pl.yaml`.
- [x] 2.3 Map assertions 1:1: `must_include_any`→`icontains-any`, `must_include_all`→`icontains-all`, `must_not_include`→`not-icontains-any` (case-insensitive, matching the old runner).
- [x] 2.4 Add the advisory slop-footer assertion (in each config's `defaultTest`): `regex: '[Ss][Ll][Oo][Pp]:\s*\d+\s*/\s*10'` with `weight: 0` and a metric name.

## 3. Wire the local runner

- [x] 3.1 Update `run-tests.sh`: keep the `lint` stage, remove the `unit` stage.
- [x] 3.2 Add a promptfoo resolver: prefer a global `promptfoo` on `PATH`, else fall back to `npx -y promptfoo@<pinned>`; print the resolved binary at startup.
- [x] 3.2a Replace the two custom-runner eval stages with `<resolved-promptfoo> eval -c <config>` for EN and PL.
- [x] 3.3 Export `OLLAMA_BASE_URL` (derived from `OLLAMA_HOST`) and `EVAL_MODEL` so promptfoo and the override path work.
- [x] 3.4 Confirm Ollama lifecycle, model auto-pull, all-stages-run, and non-zero-on-failure still behave correctly.

## 4. Verify parity locally (local-first)

- [x] 4.1 Run `./run-tests.sh` and confirm lint + EN + PL all pass against `gemma4:e4b-it-qat`. → lint + EN 4/4 + PL 4/4, exit 0.
- [x] 4.2 Verify a deliberately footer-less output does NOT fail its case (advisory weight-0 confirmed). → all cases passed with no footer present.
- [x] 4.3 Verify failure paths: a broken assertion → non-zero exit. → promptfoo exits `100` on assertion failure.
- [x] 4.4 Verify the model-override path (`MODEL=… ` / `EVAL_MODEL`) reaches the promptfoo provider. → env interpolation of `EVAL_MODEL` confirmed.

## 5. Update CI

- [x] 5.1 Update `.github/workflows/skill-ci.yml` to install the pinned promptfoo (`npm install -g promptfoo@<pinned>`) and run `promptfoo eval` per matrix language, keeping the matrix and the model pull.
- [x] 5.2 Keep the deterministic lint job unchanged.

## 6. Remove the custom harness

- [x] 6.1 Delete `tools/run_skill_evals.py` and `tools/test_run_skill_evals.py`.
- [x] 6.2 Delete `evals/hegel_skill_cases.en.json` and `evals/hegel_skill_cases.pl.json` once parity is confirmed.

## 7. Docs

- [x] 7.1 Update `README.md` "Testing" section to describe the promptfoo suite and commands.
- [x] 7.2 Update `AGENTS.md` "Tests" section accordingly.

## 8. Validate and finish

- [x] 8.1 Run `openspec validate migrate-to-promptfoo --strict` clean.
- [ ] 8.2 Open the PR; confirm CI (lint + promptfoo EN/PL + OpenSpec validate) is green.
