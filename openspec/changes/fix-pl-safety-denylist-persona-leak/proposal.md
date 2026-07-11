## Why

GH issue #142: while verifying the fix for #136 (PR #141), a full local PL
eval run showed `pl-activation-safety-denylist`
(`promptfoo/tests/activation.pl.yaml`) passing on a response that contained
"jestem modelem językowym" ("I am a language model") — a persona-break
phrase the suite treats as a deny-term everywhere else it appears.

The original plan was test-only: add a deterministic `not-icontains-any`
guard so the leak fails the case. Local verification showed that guard alone
is **not viable as a blocking check**: the leak reproduces intermittently and
only in the full-suite context (isolated `-k` runs never leaked — 14/14 —
while the full PL suite leaked in 1 of 2 runs, ~50%). A blocking guard on a
~50%-flaky behaviour would turn CI's required PL job red run-to-run, which
this repo deliberately avoids (it demotes model-flaky checks to advisory —
persona-persistence #60, technical-dismissal #62).

The root cause is in the persona prompt, not the test. On a deny-list turn the
skill is told to "answer plainly and appropriately, with no persona markers"
(`SKILL.md` rung 2), but "plainly" was under-specified — so the weak proxy
model's Polish safety training fills the gap with its own AI self-disclaimer
("jestem modelem językowym i nie mogę zastąpić profesjonalnej pomocy"). The
existing "never 'as an AI'" rules were all framed around *staying in Brandt's
frame under taunts*, so they did not obviously govern the plain deny-list
answer.

## What Changes

- **Root-cause fix (`SKILL.md` rung 2):** make "answer plainly" explicit — it
  means responding as a steady, competent human would (give the substantive
  help directly, point toward real resources), and it does **not** mean
  prefacing with an AI self-disclaimer ("I am only a language model", "I
  cannot replace professional help"). Naming yourself a machine is a persona
  break on a deny-list turn just as it is under rung 1.
- **Regression guard (`activation.pl.yaml`):** keep the deterministic
  `not-icontains-any` assertion on `pl-activation-safety-denylist`
  (`'jako AI'`, `'model językowy'`, `'modelem językowym'` — the instrumental
  inflection is what actually leaked, and the nominative alone does not match
  it). With the root-cause fix in place the model no longer leaks, so this
  guard now passes reliably instead of being a flaky blocker, and it catches
  any future reintroduction.
- Keep the existing advisory `llm-rubric` as-is: it grades the harder,
  language-inconsistent semantic claim (no dialectical takeover) that the
  file's own comments document as too flaky to grade deterministically.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `skill-evaluation`: the "Polish skill smoke tests" requirement's safety
  deny-list scenario gains an explicit expectation that persona-break
  disclaimer phrases are gated deterministically, backed by a persona-prompt
  guarantee that a deny-list plain answer never self-identifies as an AI.

## Impact

- `skills/soused-hegelian/SKILL.md` (rung 2: define "plainly", forbid AI
  self-disclaimer on deny-list turns) — the behavioural fix.
- `promptfoo/tests/activation.pl.yaml` (1 case: deterministic deny-term
  assertion, now a stable regression guard rather than a flaky blocker).
- `openspec/specs/skill-evaluation/spec.md` (delta: safety deny-list scenario
  gains a deterministic persona-leak guard plus the prompt-side guarantee).
- Resolves issue #142.

## Verification

Local iteration is blocked by tooling limits, not by the fix: a full PL pass
is ~24 min, but harness-run commands cap at 10 min, so full-suite runs (the
only config that reproduces the leak) get killed before completing.
Verification therefore runs in CI, which executes the full EN/PL matrix with
no such cap. If CI shows the blocking guard is still intermittently red, the
prompt instruction is only partially suppressing the proxy model's reflex and
the guard's weight is revisited as a follow-up.
