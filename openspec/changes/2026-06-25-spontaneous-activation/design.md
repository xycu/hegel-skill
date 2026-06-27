# Design: Spontaneous Activation

Design record behind the `soused-hegelian-persona` delta in this change. Captures
the model and the decisions #54 (SKILL.md), #55 (forceable gate), #56 (evals), and
#57 (README) implement against.

## Key constraint: what the eval harness loads

`promptfoo/prompt.js` assembles the system prompt from **`SKILL.md` + the Hegel
reference only** and prepends *"You are running the following skill. Obey its
instructions exactly."* `AGENTS.md` is **not** in the eval prompt. So the takeover
**behaviour** and the **forceable seam** must live in `SKILL.md` for #56 to test
them, and the forced-roll override must be injectable into that prompt.

## Architecture: single source of truth in SKILL.md

The on-by-default + d20 trigger lives in `SKILL.md`. Its frontmatter `description`
broadens from the narrow summon allow-list to **on-by-default, self-gating** (while
still naming the manual-summon phrases as the sticky path). The body carries the
deny-list, the d20 gate, the manual-summon rule, the takeover behaviour, and the
forceable seam. `AGENTS.md` retains the Spontaneous Wit Mode aside for turns where
the skill is genuinely not loaded.

Rejected alternative: keep the trigger in the `AGENTS.md` always-active layer
(parallel to Wit Mode) with the frontmatter unchanged. It matches the existing Wit
Mode pattern, but the eval harness does not load `AGENTS.md`, so the canonical gate
would have to be duplicated into `SKILL.md` anyway to be testable. Single source in
`SKILL.md` is simpler and directly eval-backed; the deliberate cost is a broader
frontmatter description (the client loads the skill on more turns).

## Turn-resolution ladder

Every turn resolves top-down; the first match wins.

1. **Manual summon / persistence** — *deterministic, sticky.* The user explicitly
   asks for Doktor Brandt / the drunk Hegelian / to answer dialectically, **or** a
   prior summon is still active and not sincerely dismissed → **full Brandt**, with
   the `slop:` footer. **Overrides the deny-list.** (Existing behaviour.)
2. **Deny-list** — *spontaneous only.* Not summoned, and the turn is **genuine
   distress/grief** or **safety/security/legal** → **no spontaneous takeover and no
   wit aside.** Plain, appropriate handling.
3. **d20 takeover** — roll a d20 (or read the forced override). On **13** and not
   denied → **one-turn full Brandt takeover**, in voice, answering the real
   question. **No `slop:` footer.** Not sticky — the next turn rolls fresh.
4. **Otherwise** — a normal non-persona answer, after which the existing
   **Spontaneous Wit Mode** gate may append a closing aside.

**Precedence:** `manual summon > deny-list > d20 takeover > wit aside`.

## Locked reconciliations

- **Takeover subsumes the aside** — a takeover turn never also gets a closing wit
  aside; the persona is already present. New override beside Wit Mode's existing
  three.
- **One unified deny-list gates both** spontaneous mechanisms — widening the wit
  aside's former distress-only "gravity exception" to the full deny-list, so no
  aside fires on safety/security/legal turns either.
- **Spontaneous takeover carries no `slop:` footer** — silent like the aside;
  footers fire only on manually-summoned full Brandt.
- **Spontaneous is not sticky** — a takeover lasts exactly one turn; only manual
  summon persists.

From #52, already locked: the 13 outcome addresses the user's actual question
through the dialectic; persistence is one turn for spontaneous, sticky for manual;
deny-list = distress/grief + safety/security/legal; the gate is seedable/forceable.

## Boundary consistency (no new rules)

Technical/mundane questions are **not** on the deny-list, so a forced takeover on
"debug this function" yields the existing **in-character dismissal** ("the business
of the positive sciences"), not a straight answer — consistent with the current
boundary case. #56 covers this so it cannot silently regress.

## Forceability (required here; mechanism is #55)

The spec **requires** the gate be forceable — `force-13` and `force-miss` — so
evals exercise both branches while normal use stays genuinely random.

**Decided in #55:** the seam is the `vars.roll` case var read by
`promptfoo/prompt.js`. A case sets `roll: 13` to force the takeover branch and
`roll: 7` (any integer 1–20 that is not 13, by convention 7) to force a miss;
`prompt.js` appends an explicit "the die shows N" override to the assembled system
prompt, landing last so it is the most salient instruction. `SKILL.md`'s gate reads
"if an explicit roll override is present in your instructions, obey it instead of
rolling," so it honours the injected value. An out-of-range `roll` throws, failing
the case loudly rather than silently reverting to a genuine roll. Production never
goes through `prompt.js` (the live runtime loads `SKILL.md` directly), and no
production path sets `vars.roll`, so unforced use stays genuinely random.
