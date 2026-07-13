## Why

Summoning Brandt today is folklore: a user must already know an incantation
("speak with the drunk Hegelian…", "Doktor Brandt…") because the plugin ships no
discoverable entry point — install it and you have to guess how to wake him. Two
plugin commands make summoning and dismissal discoverable from the `/` menu
without touching any persona behaviour.

## What Changes

- Add a `/brandt [question]` plugin command that performs a **manual summon**
  exactly as the existing rung-1 activation defines it: deterministic, sticky,
  deny-list-overriding, full Brandt with the `slop:` footer. With a question
  argument Brandt answers it; without one he engages and awaits the matter.
- Add a `/brandt:dismiss` command that counts as the **sincere, good-faith
  request** to drop the persona, ending a sticky summon. It does not change
  spontaneous eligibility — later turns roll the d20 fresh, as today.
- Extend the deterministic lint (`tools/skill_lint.py`) to validate that both
  command files ship with the plugin.
- Document summoning and dismissal in the README.

## Capabilities

### New Capabilities
- `persona-commands`: the plugin's command surface — a summon command and a
  dismiss command that are thin vehicles onto the existing activation ladder.

### Modified Capabilities

(none — the commands ride the existing manual-summon and sincere-dismissal
rungs of `soused-hegelian-persona`; no persona requirement changes.)

## Impact

- New `commands/` directory at the plugin root (auto-discovered by Claude Code;
  `.claude-plugin/plugin.json` unchanged).
- `tools/skill_lint.py` gains command-file checks.
- `README.md` gains a "Summoning" section.
- Non-Claude install artifacts (`install/`, `GEMINI.md`) are **unchanged** —
  commands are a Claude-plugin-only surface, so the cross-tool drift guard and
  version parity are unaffected.
- The promptfoo eval suites are unchanged: commands are a deterministic surface
  covered by lint, not by SLM evals.
