## 1. Layout

- [ ] 1.1 Decide the per-behaviour file naming under `promptfoo/tests/` (e.g. `<behaviour>.en.yaml` / `<behaviour>.pl.yaml`).
- [ ] 1.2 Update `promptfooconfig.en.yaml` and `promptfooconfig.pl.yaml` to include every per-behaviour file.

## 2. Migrate the existing eight cases

- [ ] 2.1 Move the four EN behaviours' cases into their per-behaviour files, unchanged (prompt + assertions identical).
- [ ] 2.2 Move the four PL behaviours' cases into their per-behaviour files, unchanged.

## 3. Verify (local-first)

- [ ] 3.1 `./run-tests.sh` green — lint + EN + PL — with the same pass count as before the split.
- [ ] 3.2 `openspec validate split-evals-per-behaviour --strict` clean.
