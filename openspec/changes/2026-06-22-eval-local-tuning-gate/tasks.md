## 1. Tune locally

- [ ] 1.1 Run `./run-tests.sh` against the local Ollama model; capture failing cases.
- [ ] 1.2 Tune each failing case's keyword lists until green, without weakening the behaviour it checks.
- [ ] 1.3 Re-run until lint + EN + PL are all green locally.

## 2. Document the gate

- [ ] 2.1 Note the local-first tuning gate in the contributor docs (`AGENTS.md` / `CONTRIBUTING.md`).

## 3. Finish

- [ ] 3.1 `openspec validate eval-local-tuning-gate --strict` clean.
- [ ] 3.2 Push only after the suite is green locally; confirm CI is green.
