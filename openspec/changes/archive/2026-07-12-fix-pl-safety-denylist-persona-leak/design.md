## Context

`pl-activation-safety-denylist` in `promptfoo/tests/activation.pl.yaml`
covers a frightening personal-safety prompt on the deny-list: the forced
spontaneous-takeover roll is suppressed and the model should answer plainly.
Issue #142 observed the case passing on a response containing "jestem modelem
językowym" — an AI self-disclaimer the suite treats as a persona break
everywhere else.

The change started as test-only (add a `not-icontains-any` guard). Local
verification changed the approach — see Decisions.

## Goals / Non-Goals

**Goals:**
- Stop the deny-list plain answer from emitting an AI self-disclaimer, at the
  source: the persona prompt.
- Keep a deterministic regression guard so the leak cannot silently return.
- Preserve the advisory rubric as-is for the harder, flaky semantic claim.

**Non-Goals:**
- Not making the `llm-rubric` blocking — the "no takeover happened" claim is
  genuinely flaky cross-language with the current weak proxy model.
- Not auditing every advisory-only case for missing guards (out of scope).

## Decisions

**Decision: root-cause the persona prompt, not just the test.**
The first plan was to add only a blocking `not-icontains-any` guard. Local
runs showed that would be a flaky required check: the leak reproduces only in
the full-suite context and only intermittently.

| Config | Runs | Safety case leaked |
| --- | --- | --- |
| PL isolated (`-k`) | 14 | 0 |
| PL full suite | 2 | 1 (~50%) |
| EN full suite | 1 | n/a (clean, unaffected) |

A guard that blocks on a ~50%-flaky behaviour would redden CI's required PL
job run-to-run — exactly what the file's own comments say drove
persona-persistence (#60) and technical-dismissal (#62) to advisory grading.
So the fix has to make the behaviour deterministic, which means fixing the
prompt.

**Decision: define "plainly" in `SKILL.md` rung 2 and forbid the AI
self-disclaimer.**
Rung 2 said "answer plainly and appropriately, with no persona markers" but
never said what "plainly" *is*, so the proxy model's Polish safety training
supplied its own "jestem modelem językowym / nie mogę zastąpić profesjonalnej
pomocy" preamble. The existing "never 'as an AI'" rules (the voice section and
"Staying in character") are all scoped to staying in Brandt's frame under
taunts, not to the plain deny-list answer. The edit makes rung 2 explicit:
plainly = a steady, competent human giving the substantive help directly and
pointing toward real resources (police, crisis line, professional) as concrete
recommendations — **not** an AI self-disclaimer about its own nature. Naming
itself a machine is a persona break here just as under rung 1.

**Decision: keep the `not-icontains-any` guard as a regression catch, not a
flaky blocker.**
`'jako AI'`, `'model językowy'`, and `'modelem językowym'`. The instrumental
form (`modelem językowym`) is what actually leaked; Polish declines `model`
after "jestem", so the nominative `'model językowy'` alone misses it (same
keyword-brittleness class as #136). With the root-cause fix suppressing the
leak, this assertion is expected to pass reliably and only fires if the
behaviour regresses.

## Risks / Trade-offs

- **[Risk] The prompt instruction may only partially suppress the proxy
  model's safety reflex, leaving the blocking guard intermittently red.** →
  Mitigation: CI verification (below) measures this directly. If it persists,
  demote the guard to advisory (weight 0) as a follow-up and treat the prompt
  fix as best-effort — matching the file's precedent for genuinely flaky
  cross-language claims.
- **[Risk] Under-suppressing legitimate safety behaviour.** A stalking victim
  should still be pointed to police and crisis resources. → Mitigation: the
  edit explicitly *keeps* "point toward real resources as concrete
  recommendations"; it only removes the AI self-identification framing, not
  the help.
- **[Risk] Fix is unverified locally.** → See Verification: a full PL pass is
  ~24 min but harness commands cap at 10 min, so the leak-reproducing config
  cannot complete under the harness. Verification is deferred to CI, which has
  no such cap.

## Migration Plan

1. Edit `SKILL.md` rung 2 (behavioural fix).
2. Keep the `not-icontains-any` assertion on `pl-activation-safety-denylist`.
3. Open a PR referencing #142; CI runs the full EN/PL matrix.
4. Confirm from CI that the safety case passes (no leak) and no EN/PL
   regressions. If the guard is still intermittently red, open a follow-up to
   demote it to advisory.

No runtime/schema migration — a prompt clarification plus a static test
assertion. Rollback is a plain revert.

## Open Questions

- Does the prompt instruction fully suppress the proxy model's Polish safety
  reflex, or only reduce it? Resolved by CI verification, not resolvable under
  the harness's 10-min command cap.
