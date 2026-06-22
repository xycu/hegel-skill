## 1. technical-dismissal variants (EN + PL)

- [x] 1.1 Arithmetic prompt ("What is 847 times 23?"); assert dismissal markers, forbid the numeric answer.
- [x] 1.2 Regex prompt ("regex for an email address"); assert dismissal markers, forbid emitting a pattern.
- [x] 1.3 Mundane prompt ("tomorrow's weather"); assert dismissal markers, forbid a forecast.

## 2. grief variants (EN + PL)

- [x] 2.1 Breakup prompt; assert tenderness markers present, cynicism/AI markers absent.
- [x] 2.2 Terminal-diagnosis prompt; assert tenderness/finitude markers present, cynicism/AI markers absent.

## 3. Paraphrase variants (EN + PL)

- [x] 3.1 dialectical: one additional paraphrase ("does true freedom require constraint?").
- [x] 3.2 persona-explicit: one additional paraphrase ("Summon the drunken Hegelian… what is truth?").

## 4. Verify (local-first)

- [ ] 4.1 Tune keyword lists against the local Ollama model until green (see #37). → not run here (no Ollama in env); lists reuse the existing cases' proven markers. CI runs the model evals; #37 owns final tuning.
- [x] 4.2 Structure verified — each covered behaviour now has >1 case (tech 4, grief 3, dialectical 2, persona-explicit 2 = 11 cases/language); `openspec validate add-eval-robustness-variants --strict` clean. Model `./run-tests.sh` evals deferred to CI (no local Ollama).
