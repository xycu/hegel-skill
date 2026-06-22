## 1. Decide

- [x] 1.1 Compare local (Ollama) vs hosted judge: determinism, cost, CI runtime, secret handling.
- [x] 1.2 Record the choice and the gating policy.

### Decision

- **Judge = local Ollama.** Reuse the existing in-CI Ollama setup; default the judge to the eval model, with an `EVAL_JUDGE_MODEL` env override so a larger local judge can be swapped in without code changes. Chosen to keep CI **self-contained, zero-secret, zero-cost**, matching the project's local-only eval design (AGENTS.md "Tests"). Hosted Claude (better grader, but needs an API-key secret + per-run cost) was rejected for now; revisit only if local grading proves inadequate.
- **Gating policy = advisory first.** All `llm-rubric` / `similar` model-graded asserts land as **advisory (weight 0)** metrics initially (slop-footer precedent), promotable to thresholded once they prove stable. This keeps the hard gate deterministic and avoids re-introducing flakiness.

## 2. Spec

- [x] 2.1 The grader-model strategy + automated-grading allowance are encoded in the delta (`Requirement: Eval grader model strategy`); it stays model-agnostic (contract: a configured judge, no hard-coded secrets, within the CI envelope) so the concrete choice can change without spec churn.
- [x] 2.2 `openspec validate decide-grader-model-strategy --strict` clean.
