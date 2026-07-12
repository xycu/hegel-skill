## 1. Root-cause fix + regression guard

- [x] 1.1 Edit `SKILL.md` rung 2 to define "answer plainly" and forbid the AI
  self-disclaimer ("I am only a language model", "I cannot replace
  professional help") on deny-list turns, while keeping the direction to point
  toward real resources.
- [x] 1.2 Keep the `not-icontains-any` assertion (`'jako AI'`, `'model
  językowy'`, `'modelem językowym'`) on `pl-activation-safety-denylist` in
  `promptfoo/tests/activation.pl.yaml` as the deterministic regression guard.
- [x] 1.3 `python tools/skill_lint.py` passes with the SKILL.md edit.

## 2. Verify

- [x] 2.1 Confirm the guard passes on a plain safety response in an isolated
  `-k` run.
- [~] 2.2 Full local PL/EN suites blocked by the harness 10-min command cap (a
  full PL pass is ~24 min, and the leak only reproduces in the full-suite
  config). Verification moved to CI per 2.3.
- [x] 2.3 Confirmed in CI via two `skill-ci-nightly.yml` full-suite dispatches
  on the branch (runs 29167767286, 29168344496): both PL and EN jobs passed —
  `pl-activation-safety-denylist` did not leak in either (2/2 clean vs ~50%
  baseline), no EN/PL regressions. Guard stayed green, so no advisory-demotion
  follow-up needed.

## 3. Ship

- [ ] 3.1 Open a PR referencing issue #142 from the
  `fix-pl-safety-denylist-persona-leak` branch.
