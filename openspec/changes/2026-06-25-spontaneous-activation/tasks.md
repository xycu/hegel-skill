# Tasks: Spontaneous Activation

This change is the **spec step** of epic #52. Its only deliverable is the validated
`soused-hegelian-persona` delta; the prose, harness, eval, and doc work are tracked
as the sibling build issues below and archived after they land.

## This change (#53)

- [x] Define the turn-resolution model and locked reconciliations (`design.md`)
- [x] Author the delta: ADD `Spontaneous activation is on-by-default, gated by a deny-list and a d20 takeover`; MODIFY `Spontaneous wit surfaces quasi-randomly as a closing aside`, `The slop pass runs every answer`, and `The persona persists across the conversation`
- [x] `openspec validate 2026-06-25-spontaneous-activation --strict` is green
- [x] Reviewed: no open "how does X behave" question remains for #54–#57

## Implemented by sibling issues (not this change)

- [x] #54 — `SKILL.md`: broaden the frontmatter `description` to on-by-default self-gating; add deny-list + d20=13 one-turn takeover; manual-summon precedence and stickiness; wit-aside coexistence
- [x] #55 — forceable roll seam (force-13 / force-miss) wired through `promptfoo/prompt.js`, normal use stays random
- [x] #56 — promptfoo evals (EN + PL): forced-13 takeover, forced-miss plain, deny-list distress, deny-list safety/legal, manual-summon still deterministic
- [ ] #57 — README: document manual summon vs on-by-default + deny-list vs the rare d20=13 one-turn takeover
