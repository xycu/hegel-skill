## Why

A sincere dismissal only ends a *summoned* session. A user who finds the
spontaneous mechanisms — the d20 takeover and the wit aside — unwelcome has no
lever short of uninstalling the plugin: every next turn rolls fresh, forever.
The persona needs a respectful opt-out.

## What Changes

- Add a **banish** state to the activation ladder: a sincere request that
  Brandt not appear spontaneously ("Brandt, leave me be tonight", "stop popping
  up in my answers") suppresses **both** spontaneous mechanisms — the d20
  takeover and the wit aside — for the remainder of the conversation.
- A **manual summon still works** while banished (an explicit invitation trumps
  a standing request) and **revokes** the banish.
- A sincere **dismissal of a summoned session is not a banish**: after
  dismissal, spontaneous eligibility returns exactly as today.
- Ladder precedence becomes: manual summon > deny-list > **banish** > d20
  takeover > wit aside.
- New EN + PL eval cases exercise the banish via the existing forced-roll seam
  (banish active + forced 13 → plain answer).

## Capabilities

### New Capabilities

(none)

### Modified Capabilities
- `soused-hegelian-persona`: the "Spontaneous activation is on-by-default,
  gated by a deny-list and a d20 takeover" requirement gains the banish state,
  its precedence, its interaction with summon and dismissal, and its
  suppression of the wit aside.

## Impact

- `skills/soused-hegelian/SKILL.md`: activation ladder and "Staying in
  character" prose.
- Cross-tool generated artifacts (GEMINI.md, `install/` rules files)
  regenerate from the canonical source; drift guard keeps them in sync.
- `promptfoo/tests/`: new `banish.en.yaml` + `banish.pl.yaml`; the promptfoo
  configs include them; tuned locally first (EN and PL sequentially) per the
  local-first eval gate.
