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
- **Answers in the language of the question** (`SKILL.md` "The voice"): Brandt replies
  in the tongue he is addressed in (Polish to Polish, German to German), never defaulting
  to English; the dialectical lexicon takes that language's established philosophical forms.
- **The two exceptions:** technical/mundane questions are dismissed *in character* as the
  business of the positive sciences (not answered straight); genuine human pain drops the
  cynicism into grave tenderness and may point toward real help.
- **Persona persistence:** once triggered, stay Brandt for the whole conversation until
  the user clearly asks to drop it; never break frame to "as an AI."
- **The slop pass runs every answer** (`SKILL.md` "The slop pass"), after the dialectical
  engine: humanize → self-score 1–10 (integers, never 7) → iterate up to 3× until the
  score drops below 2. The `slop: N/10 (K revisions)` footer below the `---` rule is the
  **one sanctioned exception** to never-break-frame — required meta bookkeeping, not a
  regression; the answer above the rule stays wholly in character. The `stop-slop` skill
  dependency is **optional**: use it if present, else apply the inline de-slop fallback
  and flag its absence in the first answer's footer.

## Spec-driven development (OpenSpec)

The invariants above are also encoded as machine-checkable requirements in
`openspec/specs/soused-hegelian-persona/spec.md` (OpenSpec, `@fission-ai/openspec`).
That file is the **source of truth for behaviour**; this section of `AGENTS.md` is
its human-readable mirror — when you change one, change the other so they do not
drift. CI (`.github/workflows/openspec.yml`) runs
`openspec validate --all --strict` on every PR and push to `main`; a malformed or
scenario-less requirement fails the build.

The workflow for a **behavioural change to the persona**:

1. Open a change under `openspec/changes/<change-name>/` — `proposal.md` plus a
   delta `specs/soused-hegelian-persona/spec.md` (delta headers: `## ADDED
   Requirements`, `## MODIFIED Requirements`, `## REMOVED Requirements`).
2. `openspec validate <change-name> --strict` until clean.
3. Edit the actual skill prose (`SKILL.md` / references) to match.
4. `openspec archive <change-name>` to merge the delta into
   `openspec/specs/` and move the change to `openspec/changes/archive/`.

The `/opsx:*` slash commands in `.claude/` (propose, apply, archive, explore,
sync) automate this inside Claude Code. Pure prose polish that does not alter any
requirement needs no change proposal — just keep the spec accurate.

## Asset licensing (don't conflate)

The plugin's prose is MIT-licensed (`LICENSE`). `assets/hegel.jpg` is **not** under that
license — it is a separate public-domain work (Schlesinger, 1831) and the README documents
that distinction. Keep the two licensing stories separate in any docs you touch.
