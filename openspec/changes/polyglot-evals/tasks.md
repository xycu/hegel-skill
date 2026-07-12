## 1. German suite (must-have)

- [ ] 1.1 Write the four core test files: `tests/activation.de.yaml` (or `persona-explicit.de.yaml` to match the existing split), `dialectical.de.yaml`, `technical-dismissal.de.yaml`, `grief.de.yaml`
- [ ] 1.2 Create `promptfooconfig.de.yaml` and `promptfooconfig.core.de.yaml`
- [ ] 1.3 Tune keyword lists to green locally against the configured model (sequential run)

## 2. Latin suite (must-have)

- [ ] 2.1 Write the four core test files: `persona-explicit.la.yaml`, `dialectical.la.yaml`, `technical-dismissal.la.yaml`, `grief.la.yaml`
- [ ] 2.2 Create `promptfooconfig.la.yaml` and `promptfooconfig.core.la.yaml`
- [ ] 2.3 Tune keyword lists to green locally from observed model output; loosen lists rather than weaken the gate if Latin is flaky

## 3. Light multilingual smoke

- [ ] 3.1 Write `tests/answer-in-language.multi.yaml` with one case each for FR, ES, IT (in-language reply + persona marker, English-filler forbidden list)
- [ ] 3.2 Create `promptfooconfig.multi.yaml`
- [ ] 3.3 Tune to green locally

## 4. Runner

- [ ] 4.1 Extend `run-tests.sh` with sequential DE, LA, and multi stages after EN and PL; summary lists every stage
- [ ] 4.2 Update the usage header and the `-k` filter docs (a language with no matching cases still passes)
- [ ] 4.3 Full `./run-tests.sh` green locally

## 5. CI

- [ ] 5.1 Extend the skill workflow eval matrix with `de`, `la`, and `multi` entries (core configs on the PR gate, full configs nightly)
- [ ] 5.2 Confirm required status checks still resolve (names unchanged or branch protection updated to match)
- [ ] 5.3 Watch the first CI run on the PR to completion

## 6. Docs

- [ ] 6.1 Add the README polyglot section: Brandt answers in the language of the question; tiers — full (EN, PL), core gating (DE, LA), light smoke (FR, ES, IT)

## 7. Verification

- [ ] 7.1 `python tools/skill_lint.py` passes
- [ ] 7.2 `openspec validate --all --strict` passes
- [ ] 7.3 Manual smoke in Claude Code: one German and one Latin summon read as genuine Brandt
