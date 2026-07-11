## Context

`promptfoo/tests/grief.pl.yaml` and `promptfoo/tests/activation.pl.yaml` gate
PL grief-response cases with `icontains-any` keyword lists (deterministic,
no judge model). All four grief-related assertions in these files use the
root `żał` to catch grief vocabulary. Polish distinguishes `l` and `ł` as
separate letters (`ł` ≈ /w/), so `żał` only matches the `żałoba`/`żałować`
(mourning) word family — it does not match `żal`/`żalu`/`żalem`, the plainer
and more common "grief/regret" noun, which is what the model actually used in
the failing nightly run (issue #136): "ten stan żalu i rozpaczy". The
response was correct; the assertion had a one-letter spelling gap.

## Goals / Non-Goals

**Goals:**
- Make the PL grief-keyword lists match real Polish orthography for both the
  `żal` and `żałoba` word families.
- Fix only the affected assertion lists — no persona prompt or SKILL.md
  changes, since the model behavior was already correct.

**Non-Goals:**
- Not moving these cases to `llm-rubric` grading — the keyword approach is
  sound, it just had a data bug in one root.
- Not auditing every keyword list in the suite for similar issues beyond the
  `żal`/`żał` pair identified from this failure (out of scope; a broader audit
  can be a follow-up if another nightly failure surfaces a different gap).

## Decisions

**Decision: add `żal` alongside the existing `żał`, rather than replacing it.**
Replacing `żał` with `żal` would fix the reported failure but silently drop
coverage for `żałoba`/`żałować` responses, which are equally valid in-character
grief vocabulary. Keeping both roots in each `icontains-any` list covers both
word families without narrowing what counts as a passing response.

**Decision: fix all four occurrences (3 in `grief.pl.yaml`, 1 in
`activation.pl.yaml`), not just the one that failed.**
All four use the identical `żał`-only root for the same purpose (grief
keyword gate); the bug is systemic to the root string, not case-specific.
Fixing only the reported case would leave the same latent gap in the other
three.

## Risks / Trade-offs

- **[Risk] Adding `żal` as a substring could false-positive on an unrelated
  Polish word.** → Mitigation: reviewed common Polish words containing `żal`
  (pożałować, użalać się) — all are in the regret/grief/complaint semantic
  family, so a match remains a true positive for this assertion's purpose.
- **[Risk] Fix is unverified against the full nightly suite until the next
  scheduled run.** → Mitigation: verify locally against a local Ollama model
  per this repo's iterate-locally-first convention before merging, running
  the PL grief and activation suites (not concurrently with EN, per existing
  project convention).

## Migration Plan

1. Edit the keyword lists in `promptfoo/tests/grief.pl.yaml` (3 cases) and
   `promptfoo/tests/activation.pl.yaml` (1 case).
2. Run the PL grief/activation cases locally against a local Ollama model to
   confirm the previously-failing case now passes.
3. Run the full local PL suite (and EN sequentially, not concurrently) to
   check for regressions.
4. Open a PR referencing issue #136; on merge, let the next nightly run
   confirm and auto-close the sticky issue.

No runtime/schema migration — this is a static test-data correction with no
production code path affected. Rollback is a plain revert.

## Open Questions

None blocking.
