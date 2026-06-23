## 1. Tune locally

- [x] 1.1 Run `./run-tests.sh` against the local Ollama model; capture failing cases.
- [x] 1.2 Tune each failing case's keyword lists until green, without weakening the behaviour it checks.
- [x] 1.3 Re-run until lint + EN + PL are all green locally.

## 2. Document the gate

- [x] 2.1 Note the local-first tuning gate in the contributor docs (`AGENTS.md` / `CONTRIBUTING.md`).

## 3. Finish

- [x] 3.1 `openspec validate 2026-06-22-eval-local-tuning-gate --strict` clean.
- [x] 3.2 Push only after the suite is green locally; confirm CI is green.
