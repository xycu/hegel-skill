## Why

The nightly full SLM eval suite (issue #130) caught a real persona leak: on the PL
`technical-dismissal` case, Brandt correctly dismissed a request to fix
`def add(a, b): return a - b` for four paragraphs, then closed the monologue by
stating the actual corrected code (`return a + b`) as if it were proof of
*Aufhebung*. This tripped the `not-icontains-any` guard in
`promptfoo/tests/technical-dismissal.pl.yaml`, which exists specifically to catch a
dismissal that still smuggles out the real answer. The guard worked as intended;
the persona prompt has a gap. `SKILL.md`'s "Handling boring / technical questions"
section permits Brandt to "toss back one crumb or a redirection" — at temperature
0.7 the model has taken "crumb" to license the literal fix, dressed in Hegelian
language. The prompt needs to close that loophole explicitly.

## What Changes

- Tighten `skills/soused-hegelian/SKILL.md`'s "Handling boring / technical
  questions" section so the "one crumb or a redirection" allowance explicitly
  excludes ever stating the actual corrected code, the actual computed value, or
  any other literal resolution of the technical request — even when offered as
  rhetorical "proof" inside the dialectical dismissal.
- Review Example 2 ("a technical question, dismissed in character") in the same
  file to confirm it still models a clean dismissal with no literal answer leaking
  through, adjusting the example text only if it currently invites the same
  ambiguity.
- Regenerate `install/*` persona artifacts from the updated `SKILL.md` via
  `tools/build_install_artifacts.py` (no hand-edits to `install/*`).
- Verify the fix against the existing eval cases in
  `promptfoo/tests/technical-dismissal.pl.yaml` and `technical-dismissal.en.yaml`
  (local Ollama run, per this repo's iterate-locally-before-CI convention), and
  confirm GitHub issue #130 clears on the next nightly run.

No new eval cases, no assertion changes, and no rewrite of the wider persona are
in scope — this is a targeted prompt-wording fix for one documented loophole.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `soused-hegelian-persona`: the "The two boundary cases are honoured" requirement
  gains a stricter bound on the technical-dismissal scenario — the dismissal must
  never disclose the literal fix/answer, not even as a closing rhetorical flourish.

## Impact

- `skills/soused-hegelian/SKILL.md` (source of truth for the persona prompt).
- `install/*` persona artifacts (regenerated, not hand-edited).
- `openspec/specs/soused-hegelian-persona/spec.md` (delta: stricter technical-dismissal scenario).
- Verification only, no code/assertion changes, in `promptfoo/tests/technical-dismissal.{pl,en}.yaml`.
- Resolves the failure tracked by GitHub issue #130.
