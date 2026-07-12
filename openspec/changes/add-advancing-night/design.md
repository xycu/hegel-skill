## Context

The persona's temporal staging (candle, bottle, night) is fixed scenery today.
The skill is prose-only — there is no state store and no turn counter — so any
progression must be something the model infers from the visible conversation
length, the way it already infers stickiness. The eval stack has two tiers:
keyword smoke tests (PR-gating) and advisory `llm-rubric` grading (nightly),
per the skill-evaluation spec.

## Goals / Non-Goals

**Goals:**
- Long summoned sessions feel like one continuous night, not a loop of
  identical openings.
- The progression stays strictly subordinate to every load-bearing rule.
- Coverage that matches the mechanism's softness: rubric-graded, advisory,
  nightly.

**Non-Goals:**
- No explicit turn counter, thresholds, or state machine in the prose.
- No change to footers, engine, citations, deny-list, or the spontaneous
  mechanisms.
- No PR-gating keyword tests for staging — they would be brittle by
  construction.

## Decisions

- **Guidance lives in "Who he is" plus one line in "Staying in character".**
  "Who he is" already carries the grand→mournful→tender arc; the addition ties
  that arc to conversation length. A separate "night mechanics" section was
  rejected: it would invite the model to announce the mechanism instead of
  inhabiting it, the same failure mode the engine rules guard against
  ("performed, not described").
- **Subordination is stated in the requirement itself**, not left to inference:
  flavor never outranks register, engine, citations, slop pass, or boundaries.
  This is the clause reviews will lean on when staging and rules conflict.
- **Takeovers are stateless by specification.** A d20 turn is a stranger
  wandering in once; giving it night-memory would quietly reintroduce
  stickiness that the activation spec forbids.
- **Eval as advisory multi-turn rubric, nightly only.** The rubric compares
  early-vs-late staging in a simulated long session (the persona-persistence
  prompt pattern extended to more turns). Advisory weight-0 per the grader
  strategy's gating policy; promotion to thresholded stays available later.

## Risks / Trade-offs

- [The model overplays the drunkenness late in the night and the prose
  slackens] → the requirement carries the existing "the wine deepens the
  cadence" clause verbatim as a hard boundary; the register requirement still
  gates every answer.
- [The progression is invisible in short sessions] → intended; the guidance
  keys on conversation length, and most sessions never leave early evening.
- [Rubric grading of "staging depth" is subjective] → advisory only; it
  reports, it does not gate. If it proves noisy even as a signal, drop the
  case, keep the prose.
