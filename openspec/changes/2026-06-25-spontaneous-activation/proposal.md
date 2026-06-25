# Proposal: Spontaneous Activation

## What

Invert Brandt's activation. Today he loads on a narrow allow-list of summon
phrases. Under this change he is **eligible by default on every turn**, gated by a
small **deny-list** (genuine distress/grief; safety/security/legal), and on an
eligible turn a **d20 roll of 13 (~5%)** triggers a one-turn dialectical
**takeover** that answers the user's real question in his voice. Explicit summoning
stays deterministic and sticky and overrides the deny-list; the spontaneous
takeover is one turn only and never becomes sticky.

This is the **spec step (#53)** of epic #52. It defines the behaviour in the
`soused-hegelian-persona` capability; the prose and eval changes follow on their
own build issues (#54–#57).

## Why

A persona this vivid should occasionally surface unbidden rather than only when
summoned, while explicit control and sensitive contexts stay protected. The d20
gate keeps him a rare, delightful surprise (~1 in 20 eligible turns) instead of a
constant presence. Inverting the allow-list to a deny-list is what makes
"on by default everywhere, except where he must not butt in" expressible.

## Scope

- **In:** the `soused-hegelian-persona` delta — one new requirement for the
  activation model, plus modifications to the spontaneous-wit, slop-pass, and
  persona-persistence requirements so the four mechanisms reconcile without
  contradiction.
- **Out of scope (later issues):** editing `SKILL.md` / `AGENTS.md` prose (#54),
  the forceable roll mechanism in the eval harness (#55), promptfoo evals (#56),
  and README docs (#57). Also out of scope per #52: changing the dialectical
  engine, the voice, or the citation rules; tuning the odds (fixed at d20 == 13).

## Decisions

The locked reconciliations (the choices this change commits to) are recorded in
`design.md`:

- a single turn-resolution ladder: `manual summon > deny-list > d20 takeover > wit aside`;
- a spontaneous takeover **subsumes** the wit aside (no aside on a takeover turn);
- **one unified deny-list** gates both spontaneous mechanisms (widening the wit
  aside's former distress-only "gravity exception");
- a spontaneous takeover carries **no `slop:` footer** (footers belong only to
  manually-summoned full Brandt);
- the gate is **forceable** for tests; the canonical behaviour lives in `SKILL.md`
  because that is what the eval harness loads.

## Acceptance

- `openspec validate 2026-06-25-spontaneous-activation --strict` is green.
- The delta to `soused-hegelian-persona` leaves no open "how does X behave"
  question for #54–#57 to implement against.
