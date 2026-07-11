## Why

GH issue #136: the nightly full SLM eval suite failed on the PL suite (19/20,
`pl-grief-breakup` case in `promptfoo/tests/grief.pl.yaml`). Reading the
promptfoo report, the model response was in character and on-topic — it used
"stan żalu i rozpaczy" ("a state of grief and despair") to describe the
breakup — but the `icontains-any` keyword assertion still failed. The
assertion's word list contains `żał` (with the diacritic `ł`), which only
matches words in the `żałoba`/`żałować` (mourning) family. It does not match
`żal`/`żalu`/`żalem` (the plain, far more common "grief/regret" noun family),
because `ł` and `l` are distinct Polish letters. The model produced a
genuinely correct grief response; the keyword list has a spelling bug that
made it miss the most common grief word in the language. This is the same
"keyword-brittleness" class of failure the suite has previously moved cases
away from via rubric grading (see comments in `grief.pl.yaml`), except here
the fix is a one-letter data correction, not a grading-strategy change.

## What Changes

- Fix the Polish grief-keyword assertion lists in
  `promptfoo/tests/grief.pl.yaml` (all three cases: `pl-grief`,
  `pl-grief-breakup`, `pl-grief-terminal`) and
  `promptfoo/tests/activation.pl.yaml` (`pl-activation-grief-denylist`) so the
  `żał` entry becomes `żal`, and add `żał` back alongside it — covering both
  the `żal` (grief noun) and `żałoba`/`żałować` (mourning) word families
  instead of only the rarer one.
- No changes to `skills/soused-hegelian/SKILL.md` or any persona prompt — the
  model's behavior was already correct; only the test assertion is wrong.
- No changes to `install/*` artifacts — those are generated from `SKILL.md`,
  which is untouched.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `skill-evaluation`: the "Polish skill smoke tests" requirement's grief
  scenario gains an explicit expectation that grief-keyword assertions cover
  the actual inflected Polish word forms the model produces (both the `żal`
  and `żałoba` roots), not just one spelling variant.

## Impact

- `promptfoo/tests/grief.pl.yaml` (3 cases: keyword list correction).
- `promptfoo/tests/activation.pl.yaml` (1 case: keyword list correction).
- `openspec/specs/skill-evaluation/spec.md` (delta: grief scenario keyword
  coverage clarified).
- Resolves the failure tracked by GitHub issue #136; no persona/runtime code
  is affected.
