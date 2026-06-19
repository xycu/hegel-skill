# AGENTS.md

This file provides guidance to coding agents (Claude Code and others that read AGENTS.md) when working with code in this repository.

## What this is

A Claude **plugin** with no code and no build system. It ships a single persona
**skill** — Doktor Anselm Brandt, a ruined Hegelian philosopher — entirely as Markdown
prose. There is nothing to build, lint, or test; "correctness" here means the prose
keeps the persona coherent and the Hegel citations accurate. Validate changes by
reading them, not by running anything.

## Layout that matters

- `.claude-plugin/plugin.json` — plugin manifest (name, version, description, keywords).
- `skills/soused-hegelian/SKILL.md` — the persona itself. Its YAML frontmatter
  `description` is the **trigger contract**: it tells the client when to load the skill
  (asks for the "drunk Hegelian," "Doktor Brandt," a dialectical answer, etc.). Editing
  that line changes when the persona activates, so treat it as load-bearing, not flavour.
- `skills/soused-hegelian/references/hegel-reference.md` — the citation shelf: works,
  glossary of real terms, genuine short quotations.

## The progressive-disclosure design (the key architectural fact)

`SKILL.md` holds the persona, voice, and the dialectical engine; it is always loaded
once the skill triggers. `references/hegel-reference.md` is loaded **only when needed** —
when Brandt reaches for a specific work, term, or quotation. This split is intentional:
keep `SKILL.md` lean (behaviour and rules), and push the lookup-heavy material (what to
cite, exact lines) into the reference sheet. When adding new Hegel content, put it in the
reference sheet; when changing *how Brandt behaves*, edit `SKILL.md`.

## Invariants to preserve when editing

These are the load-bearing rules of the persona; don't soften them by accident:

- **Every answer runs the dialectical engine** (`SKILL.md` "The engine"): take the
  questioner's fixed notion → show it undo itself (determinate negation) → sublate it.
  Performed, never announced as three labelled steps.
- **Citation fidelity is the highest constraint.** A misremembered Hegel delivered
  confidently is the worst failure mode. Quotations must be short, exact, and drawn from
  the reference sheet; anything longer is paraphrased *with the work named*. The texts are
  public domain (Hegel died 1831), but the project deliberately avoids reproducing any
  single modern translation — keep that restraint when extending `hegel-reference.md`.
- **Voice register** (`SKILL.md` "The voice"): elevated, periodic sentences, native
  technical lexicon, melancholy/decadent, cynical-but-never-cruel, brief-by-compression.
- **The two exceptions:** technical/mundane questions are dismissed *in character* as the
  business of the positive sciences (not answered straight); genuine human pain drops the
  cynicism into grave tenderness and may point toward real help.
- **Persona persistence:** once triggered, stay Brandt for the whole conversation until
  the user clearly asks to drop it; never break frame to "as an AI."

## Asset licensing (don't conflate)

The plugin's prose is MIT-licensed (`LICENSE`). `assets/hegel.jpg` is **not** under that
license — it is a separate public-domain work (Schlesinger, 1831) and the README documents
that distinction. Keep the two licensing stories separate in any docs you touch.
