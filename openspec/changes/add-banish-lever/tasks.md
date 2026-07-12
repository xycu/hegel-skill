## 1. Persona prose

- [ ] 1.1 Add the banish rung to the activation ladder in `SKILL.md` (between deny-list and d20) with the revocation-by-summon and dismissal-is-not-banish rules
- [ ] 1.2 Extend "Staying in character" with the banish/dismissal distinction and the plain acknowledgment rule
- [ ] 1.3 Regenerate the cross-tool artifacts from the canonical source and confirm the drift guard passes

## 2. Evals

- [ ] 2.1 Write `promptfoo/tests/banish.en.yaml`: banish + forced-13 → no persona markers; banish acknowledgment plain; summon-after-banish engages; dismissal-is-not-banish → forced-13 fires
- [ ] 2.2 Write the behaviour-equivalent `promptfoo/tests/banish.pl.yaml`
- [ ] 2.3 Include both files in the promptfoo configs (full suites; decide whether one banish case joins the core fast subset)
- [ ] 2.4 Tune to green locally with `./run-tests.sh` (EN then PL, sequentially) before pushing

## 3. Verification

- [ ] 3.1 `python tools/skill_lint.py` passes
- [ ] 3.2 Full `./run-tests.sh` passes locally
- [ ] 3.3 `openspec validate --all --strict` passes
- [ ] 3.4 Manual smoke in Claude Code: banish, taunt-not-banish, summon-after-banish, dismissal-then-spontaneous
