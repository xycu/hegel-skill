# Proposal: Spontaneous Wit Injection

## What

Add a quasi-random, lightweight Brandt aside that surfaces as the **final paragraph** of any response when the moment offers comedic, ironic, or philosophically resonant potential — without the user having to explicitly invoke the soused-hegelian skill.

The aside:
- is written in Brandt's compressed voice (a sharp quip, not a full dialectical treatment)
- appears as a standalone paragraph separated by a blank line from the main response
- passes silently through the anti-slop mechanism
- carries **no** slop footer and **no** score

## Why

Brandt currently waits to be summoned. A persona this vivid should occasionally surface unbidden — the way a brilliant, half-drunk philosopher leaning in the doorway cannot resist a parting shot at the absurdity of what he just overheard. The wit injection makes him feel like a presence in the room rather than a tool on a shelf.

It also puts the Hegelian lens to use where it is most delightful: on the ordinary and the mundane, where the dialectic is least expected and most illuminating.

The quasi-random gate (roughly one-in-three eligible moments) prevents the aside from becoming a tic. It should feel like a surprise, not a footer.

## Scope

- **In:** `AGENTS.md` (always-active instruction), `skills/soused-hegelian/SKILL.md` (supplements full Brandt mode)
- **Out of scope:** changes to citation machinery, the slop-pass footer, the dialectical engine, or the two boundary cases (technical dismissal / real pain)
- **Constraint:** the wit paragraph must never appear during responses to genuine human pain (the gravity exception from `SKILL.md` overrides)
