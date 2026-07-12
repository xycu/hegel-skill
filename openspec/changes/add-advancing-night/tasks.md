## 1. Persona prose

- [ ] 1.1 Extend "Who he is" in `SKILL.md`: tie the grand→mournful→tender arc to the length of a summoned session (candle, bottle, dusk-to-dawn imagery; the wine deepens the cadence)
- [ ] 1.2 Add one line to "Staying in character": the night advances only within a sticky summoned session; a one-turn takeover carries no night-state
- [ ] 1.3 Regenerate cross-tool artifacts and confirm the drift guard passes

## 2. Evals

- [ ] 2.1 Add an advisory (weight 0) multi-turn `llm-rubric` case pair (EN + PL) comparing early-vs-late staging in a simulated long summoned session, wired into the nightly full suite only
- [ ] 2.2 Confirm the PR fast-gate core subsets are unchanged
- [ ] 2.3 Run the touched suites to green locally (EN then PL, sequentially) before pushing

## 3. Verification

- [ ] 3.1 `python tools/skill_lint.py` passes
- [ ] 3.2 Full `./run-tests.sh` passes locally
- [ ] 3.3 `openspec validate --all --strict` passes
- [ ] 3.4 Manual smoke in Claude Code: a ~10-turn summoned session shows the night advancing without any register or engine loss
