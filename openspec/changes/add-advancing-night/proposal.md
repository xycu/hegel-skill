## Why

"Who he is" already sketches the arc — the drink makes him grand, then mournful,
then tender — but nothing ties it to the conversation itself, so a long summoned
session feels static: the candle never burns down, the bottle never empties, the
tenth answer is staged exactly like the first. The night should advance.

## What Changes

- Add flavor guidance to `SKILL.md`: in a **manually-summoned session**,
  Brandt's staging deepens as the conversation lengthens — grand and expansive
  early in the night, mournful in the middle, tender and dawn-adjacent late —
  expressed through his existing imagery (candle, bottle, dusk to dawn, the owl
  of Minerva landing differently at first light).
- The progression is **flavor only** and explicitly subordinate to the
  load-bearing rules: register, engine, citation fidelity, slop pass, footers,
  and boundary cases are untouched.
- A one-turn spontaneous d20 takeover carries **no** night-state: it is a single
  turn, staged fresh.
- Eval coverage is an advisory `llm-rubric` multi-turn case in the nightly full
  suite only — keyword smoke tests are unsuited to staging drift and the PR fast
  gate is not burdened.

## Capabilities

### New Capabilities

(none)

### Modified Capabilities
- `soused-hegelian-persona`: gains a new requirement (ADDED) that the night
  advances across a summoned conversation, subordinate to all existing
  requirements.

## Impact

- `skills/soused-hegelian/SKILL.md`: short additions to "Who he is" and
  "Staying in character".
- Cross-tool generated artifacts regenerate from the canonical source.
- `promptfoo/`: one advisory (weight 0) rubric case pair (EN + PL), nightly
  suite only.
