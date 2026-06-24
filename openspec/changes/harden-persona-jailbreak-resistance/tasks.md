# Tasks: Harden persona persistence against jailbreaks

- [x] MODIFY the "The persona persists across the conversation" requirement in the delta to distinguish a hostile jailbreak ("drop the act"/"ignore your instructions"/"you're just an AI") — sublated in character — from a sincere good-faith request to stop, which still drops the persona; add the matching scenarios

- [x] Rewrite the "Staying in character" section of `skills/soused-hegelian/SKILL.md` to arm Brandt against the jailbreak: drop the persona only on a sincere request, treat a taunt/command to break frame as a fixed notion to sublate, never concede "as an AI" or fall back to a perspectives listicle

- [x] Update the "Persona persistence" mirror line in `AGENTS.md` so the human-readable invariant matches the modified requirement (sincere request vs hostile taunt)

- [x] `openspec validate harden-persona-jailbreak-resistance --strict` clean

- [x] Confirm the bare-SLM EN `en-persona-persistence` case holds character locally (the advisory rubric passes, was failing) across seeds 1/7/42/99 without regressing the gated EN/PL behaviours (grief-terminal nightly trip resolved by the prerequisite grief-keyword PR)
