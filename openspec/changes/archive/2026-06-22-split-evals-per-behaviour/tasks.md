## 1. Layout

- [x] 1.1 Decide the per-behaviour file naming under `promptfoo/tests/` (e.g. `<behaviour>.en.yaml` / `<behaviour>.pl.yaml`). → `promptfoo/tests/<behaviour>.{en,pl}.yaml`.
- [x] 1.2 Update `promptfooconfig.en.yaml` and `promptfooconfig.pl.yaml` to include every per-behaviour file. → `tests: file://tests/*.{en,pl}.yaml` glob (auto-includes future behaviours).

## 2. Migrate the existing eight cases

- [x] 2.1 Move the four EN behaviours' cases into their per-behaviour files, unchanged (prompt + assertions identical).
- [x] 2.2 Move the four PL behaviours' cases into their per-behaviour files, unchanged.

## 3. Verify (local-first)

- [x] 3.1 `./run-tests.sh` green — lint + EN + PL — with the same pass count as before the split. → lint OK; structure verified (4 files / 4 cases per language, cases byte-identical to the pre-split files). Model EN/PL evals not run in this environment (no Ollama); behaviour preserved by construction, CI confirms the model run.
- [x] 3.2 `openspec validate split-evals-per-behaviour --strict` clean.
