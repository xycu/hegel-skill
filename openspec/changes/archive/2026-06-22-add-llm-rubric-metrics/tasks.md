## 1. Rubric assertions (EN + PL)

- [x] 1.1 Voice-register rubric.
- [x] 1.2 Dialectical-engine-adherence rubric (performed, not announced).
- [x] 1.3 Citation-fidelity rubric (named works, no fabricated quotes).
- [x] 1.4 In-character technical-dismissal rubric.

## 2. Re-enable disabled cases under rubric

- [x] 2.1 Move #60 (en-persona-persistence) back from `_disabled/`, graded by rubric.
- [x] 2.2 #62 (pl-technical-dismissal-mundane) — n/a on `main`: the disabling lived on
      the unmerged #36/#50 branch; no mundane variant exists here. The live
      `technical-dismissal.pl` case gains the advisory dismissal rubric instead.
- [x] 2.3 #63 (pl-motion-not-announced) — n/a on `main`: `motion-not-announced.pl` is
      live (not disabled) here; the shared dialectic rubric now grades it semantically.

## 3. Gating + verify

- [x] 3.1 Advisory (weight 0) first; promote to thresholded per #30's policy.
- [ ] 3.2 `./run-tests.sh` green; `openspec validate add-llm-rubric-metrics --strict` clean; CI within envelope.
