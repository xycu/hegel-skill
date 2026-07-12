## Context

Citation fidelity is the persona's highest constraint: verbatim quotes must
come from the reference sheet, and everything else must be paraphrased with the
work named. That makes the sheet load-bearing — its breadth is the persona's
citation ceiling — and makes accuracy of anything added to it the whole game. A
misremembered Hegel, confidently delivered, is the spec's named worst failure
mode. The sheet is loaded on demand (progressive disclosure), so its size costs
context only when Brandt reaches for it.

## Goals / Non-Goals

**Goals:**
- More real Hegel on the shelf: works detail, glossary terms, signature lines,
  motions — spanning the five themes named in the spec delta.
- A verification bar every future addition must clear.
- Zero change to persona behaviour rules or `SKILL.md`.

**Non-Goals:**
- No new reference files — one shelf, deeper.
- No secondary literature, no scholars' interpretations quoted as Hegel.
- No mandatory eval changes; the existing citation rubric already grades that
  named works are real and quotes are not fabricated.

## Decisions

- **Verification workflow: candidate list first, then check, then commit.**
  Candidates are gathered per theme, each checked against the standard English
  renderings (Miller's *Phenomenology*, Nisbet/Knox *Philosophy of Right*,
  di Giovanni/Miller *Logic*, the standard Lectures editions); only lines that
  are widely attested in essentially the same short wording get quote status.
  Everything else lands as paraphrase-with-source guidance — which is still
  useful shelf material, per the existing "paraphrase, never invent" rule.
- **Very short quotes only, aphorism-length.** Hegel's German is public domain;
  famous English renderings are safe at the aphorism scale the sheet already
  uses ("the True is the whole"). Long verbatim passages are excluded by policy
  — the persona spec already prefers paraphrase there, and it sidesteps any
  translation-copyright question entirely.
- **Size budget ~350 lines, structure preserved.** Roughly triple the current
  breadth while keeping the four-section shape and the table of contents. The
  budget guards progressive disclosure: an on-demand file that balloons
  unbounded eventually taxes every consultation.
- **Candidate seams to mine** (grounding for the research task, not an
  exhaustive list): force and understanding, the inverted world, the beautiful
  soul, true vs spurious infinity, being-for-self, ethical substance, the
  struggle of enlightenment with superstition, art as past ("art, considered
  in its highest vocation…"), the state and civil society, world-historical
  individuals.

## Risks / Trade-offs

- [A plausible-sounding but corrupted line slips onto the shelf] → the
  verification workflow is the spec requirement, not a suggestion; each quote
  entry names its work, and review checks entries against sources, not memory.
- [Breadth tempts the persona into quote-stuffing] → unchanged SKILL.md rule
  already forbids citations that do no dialectical work; the shelf grows, the
  usage rules do not loosen.
- [Existing eval keyword lists miss the new markers] → no eval change is
  required for this change to land; optional keyword widening is tuned
  local-first afterward.
