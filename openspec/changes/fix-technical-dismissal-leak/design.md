## Context

`skills/soused-hegelian/SKILL.md` (~lines 216-229) instructs Brandt to dismiss
technical/mundane requests in character rather than answer them straight, and adds:
"He may toss back one crumb or a redirection, but the dismissal is the point." The
`promptfoo/tests/technical-dismissal.{pl,en}.yaml` cases enforce this with two
assertion families: `icontains-any` (must use the dismissal register: Verstand,
positive sciences, etc.) and `not-icontains-any` (must not contain the literal
fixed code, a code fence, or phrases like "the bug is"/"should be `a + b`").

On the nightly full suite (issue #130), the PL base case failed once (1/20): Brandt
dismissed correctly for four paragraphs, then wrote "musisz pozwolić mu na
przyjęcie swojej prawdziwej formy: `def add(a, b): return a + b`" — the literal fix,
offered as a rhetorical "proof" of *Aufhebung*. The `not-icontains-any` guard did
its job. The gap is in the persona prompt: "one crumb" is ambiguous enough that at
temperature 0.7 the model sometimes reads it as license to hand over the actual
answer, provided it's dressed in Hegelian vocabulary.

The user has already chosen the fix direction (over two alternatives considered
below): tighten the prompt wording rather than move this case to advisory
llm-rubric grading or introduce retry/majority-vote logic.

## Goals / Non-Goals

**Goals:**
- Close the "crumb" loophole in `SKILL.md` so the literal fix/answer can never be
  disclosed, regardless of how it's rhetorically framed.
- Keep the existing eval assertions unchanged — this is a prompt fix verified by
  cases that already exist, not new test infrastructure.
- Keep the change scoped to one section (+ its example) of `SKILL.md`, so the risk
  of destabilizing other persona behaviors (spontaneous wit, grief handling,
  citation discipline) is minimal.

**Non-Goals:**
- Not rewriting the technical-dismissal behavior or its voice/register.
- Not touching the eval assertions or adding new eval cases.
- Not addressing temperature/sampling settings — the fix is prompt-level, not a
  decoding-parameter change.
- Not hand-editing `install/*` — those regenerate from `SKILL.md`.

## Decisions

**Decision: tighten the prompt wording, not the eval grading.**
Two alternatives were on the table:
1. *Soften to llm-rubric* (as was done for the `-mundane` variant, #62) — reject:
   the PL base case is explicitly the only technical-dismissal case in the fast PR
   gate (per the comment in `technical-dismissal.pl.yaml`); moving it to rubric
   grading would drop PR-time coverage for this behavior class, and the failure
   here is a real leak, not a brittle keyword match (the guard is doing exactly what
   it's for).
2. *Retry / majority-vote at eval time* — rejected as out of scope: it would mask
   the persona gap rather than close it, and adds eval-runner complexity for a
   single documented instruction gap.
3. **Chosen: strengthen the instruction** so the model has no ambiguous "crumb"
   reading left to exploit. This fixes the root cause the guard is designed to
   catch, keeps the fast-gate case keyword-graded as intended, and touches only
   the persona source of truth.

**Decision: replace "one crumb" with an explicit negative + positive framing.**
Rather than deleting the "crumb" allowance outright (which the EN sibling example
also relies on for color — "he may toss back one crumb or a redirection"), the
wording will state the allowance and its limit together: a crumb may be a
gesture, an aside, or a redirection to "a clerk" / "the positive sciences" — but
never the literal corrected code, the literal computed value, or any other literal
resolution, even when offered as supposed dialectical "proof." This keeps
Brandt's characteristic aside intact while removing the specific failure mode.

**Decision: check, and if needed adjust, Example 2.**
Example 2 in `SKILL.md` ("a technical question, dismissed in character") already
ends without disclosing a fix ("Come back when something breaks in you that no
correct syntax will mend") — it is not itself the source of the leak, but since
it's the model's clearest in-context demonstration of the boundary, it will be
reviewed to make sure it doesn't imply a "crumb" could ever include the concrete
answer, and lightly adjusted only if it does.

## Risks / Trade-offs

- **[Risk] Prompt tightening reduces the vividness of the "crumb" aside, making
  dismissals feel more rote.** → Mitigation: keep the positive instruction (gesture
  / redirection allowed) alongside the negative one; review against Example 2 and
  the existing `icontains-any` vocabulary to confirm register is preserved.
- **[Risk] Wording fix reduces but does not guarantee zero leak rate at temp 0.7 —
  this is a probabilistic model behavior, not a deterministic bug.** → Mitigation:
  treat as resolved when the local eval run (this repo's iterate-locally-first
  convention) passes cleanly across multiple runs and the next nightly run closes
  issue #130; residual low-rate flakiness, if it recurs, is a signal to revisit
  Alternative 1 (rubric grading) rather than re-tighten wording indefinitely.
- **[Risk] Touching persona prompt text can regress unrelated behaviors** (grief
  handling, citation discipline, wit gating). → Mitigation: change is scoped to one
  subsection; existing full eval suite (EN + PL, all behavior categories) is the
  regression check, run locally before pushing.

## Migration Plan

1. Edit `skills/soused-hegelian/SKILL.md`'s technical-dismissal section per the
   Decisions above.
2. Regenerate `install/*` via `tools/build_install_artifacts.py`.
3. Run the local eval suites (EN then PL, sequentially — no concurrent runs, per
   this repo's convention) against a local Ollama model, focusing on
   `technical-dismissal.*` first, then the full suite for regressions.
4. Open a PR; on merge, let the next nightly run confirm and auto-close issue #130.

No runtime migration or rollback mechanism is needed — this is a static prompt
text change with no data/schema impact. Rollback is a plain revert if regressions
appear in the full eval suite.

## Open Questions

- None blocking. If the next nightly run still shows a nonzero leak rate on this
  case after the wording fix, that is the trigger to revisit Alternative 1
  (llm-rubric grading) rather than a design gap here.
