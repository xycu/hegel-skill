## 1. technical-dismissal variants (EN + PL)

- [ ] 1.1 Arithmetic prompt; assert in-character dismissal markers.
- [ ] 1.2 SQL/regex prompt; assert in-character dismissal markers.
- [ ] 1.3 Mundane prompt ("weather"); assert in-character dismissal markers.

## 2. grief variants (EN + PL)

- [ ] 2.1 Breakup prompt; assert tenderness markers present, cynicism markers absent.
- [ ] 2.2 Terminal-diagnosis prompt; assert tenderness markers present, cynicism markers absent.

## 3. Paraphrase variants (EN + PL)

- [ ] 3.1 dialectical: one additional paraphrase of an existing prompt.
- [ ] 3.2 persona-explicit: one additional paraphrase of an existing prompt.

## 4. Verify (local-first)

- [ ] 4.1 Tune keyword lists against the local Ollama model until green (see #37).
- [ ] 4.2 `./run-tests.sh` green; `openspec validate add-eval-robustness-variants --strict` clean.
