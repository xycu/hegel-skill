## Context

The activation ladder in `SKILL.md` resolves each turn as: manual summon >
deny-list > d20 takeover > wit aside. Stickiness and sincere dismissal are
properties of the summon alone; nothing today lets a user switch off the
*spontaneous* mechanisms for a conversation. The persona spec mirrors the ladder
as explicit requirements, and eval cases already use a forced-roll seam
(force-13 / force-miss) to test the spontaneous branches deterministically.

## Goals / Non-Goals

**Goals:**
- A conversation-scoped, sincere opt-out of the d20 takeover and wit aside.
- Predictable interaction with the existing rungs: summon still works and
  revokes; dismissal stays exactly what it is today.
- Deterministic eval coverage via the existing forced-roll seam, EN + PL.

**Non-Goals:**
- No cross-conversation persistence (a prose skill has no store; the banish
  lives and dies with the conversation).
- No configurable d20 odds and no permanent disable switch — uninstalling
  remains the permanent lever.
- No change to the deny-list, footer rules, engine, or voice.

## Decisions

- **Ladder position: below deny-list, above d20** (manual summon > deny-list >
  banish > d20 > wit). The deny-list is per-turn and topic-based; the banish is
  conversation-state. Ordering banish above the d20 keeps the roll from even
  being consulted while banished; keeping it below the deny-list is inert in
  practice (both yield plain answers) but preserves the deny-list's
  unconditional character.
- **A summon revokes the banish** rather than merely overriding it turn-by-turn.
  An explicit invitation is the strongest signal the user's standing preference
  changed; the alternative — banish resumes after the summoned session ends —
  would make the skill track two interacting states in prose, a bug farm for a
  mechanism that should read in three sentences.
- **Banish is honoured liberally, dismissal semantics are not reused.** The
  jailbreak-resistance rules ("drop the act" is sublated, not obeyed) apply to
  breaking a *summoned* Brandt's frame. A request to stop *appearing* is a
  preference about unsolicited behaviour and is honoured plainly — hostility is
  not required to distinguish them, sincerity is, same standard as dismissal.
- **Eval seam: forced roll + prior-turn transcript.** The persona-persistence
  cases already simulate prior turns in the prompt; banish cases reuse that
  pattern — a transcript containing the banish, then a new question with the
  gate forced to 13, asserting no persona markers (`not-icontains-any`).

## Risks / Trade-offs

- [A small eval model conflates banish with dismissal or with the deny-list] →
  keyword lists tuned local-first against the Ollama model per the existing
  local-first gate; EN and PL suites run sequentially, never concurrently.
- [Ladder prose grows and dilutes SKILL.md] → the banish is added as a short
  rung plus two sentences in "Staying in character"; no new section.
- [Users banish accidentally with an offhand remark] → the same sincerity bar
  as dismissal applies ("sincerely asks"); a taunt or rhetorical flourish does
  not banish.
