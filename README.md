# hegel-skill

<p align="center">
  <img src="assets/hegel.jpg" alt="Portrait of G.W.F. Hegel by Jakob Schlesinger, 1831" width="300"><br>
  <em>G.W.F. Hegel, portrait by Jakob Schlesinger, Berlin 1831 (public domain).</em>
</p>

A Claude plugin containing a single persona skill: **Doktor Anselm Brandt**, a
ruined, melancholy, decadent philosopher who drinks through the night and answers
every question through the dialectic, grounded in the real philosophy of
G.W.F. Hegel.

He takes the questioner's fixed notion (the work of the *Understanding*), shows it
undo itself, and sublates it into something higher — naming Hegel's actual works and
leaning on genuine lines as he goes. Technical or mundane questions he dismisses
*in character* as the business of the positive sciences. When someone is in real
pain, the cynicism falls away into grave tenderness.

## What's inside

```
hegel-skill/
├── .claude-plugin/
│   ├── plugin.json                       # plugin manifest
│   └── marketplace.json                  # marketplace manifest (for install)
├── .github/
│   └── workflows/
│       └── openspec.yml                  # CI: strict OpenSpec validation
├── openspec/
│   ├── specs/
│   │   └── soused-hegelian-persona/
│   │       └── spec.md                   # the persona's invariants as requirements
│   └── changes/                          # proposed changes (one dir each)
├── skills/
│   └── soused-hegelian/
│       ├── SKILL.md                      # the persona: voice, engine, examples
│       └── references/
│           └── hegel-reference.md        # his shelf: works, glossary, real quotes
├── assets/
│   └── hegel.jpg                         # Schlesinger portrait, 1831 (public domain)
└── README.md
```

The skill uses progressive disclosure: the persona and its rules live in `SKILL.md`,
while the reference sheet (works to cite, a glossary of real terms, and genuine short
quotations) is loaded only when Brandt reaches for the text.

## Spec-driven development

The skill is prose, but its load-bearing rules — the dialectical engine on every
answer, citation fidelity, the voice register, the slop pass, persona
persistence, the two boundary cases, progressive disclosure — are mirrored as
explicit requirements in [`openspec/specs/soused-hegelian-persona/spec.md`](openspec/specs/soused-hegelian-persona/spec.md),
using [OpenSpec](https://github.com/Fission-AI/OpenSpec). That spec is the source
of truth for *how Brandt must behave*; the `AGENTS.md` invariants narrate the
same rules for human readers.

CI runs `openspec validate --all --strict` on every pull request and push to
`main` (see [`.github/workflows/openspec.yml`](.github/workflows/openspec.yml)),
so a malformed or incomplete spec fails the build. Behavioural changes to the
persona should go through an OpenSpec change first:

```
npx -y @fission-ai/openspec@latest validate --all --strict   # what CI runs
openspec list --specs                                        # see the capability
```

Project-scoped `/opsx:*` slash commands (in `.claude/`) drive the propose →
apply → archive workflow inside Claude Code.

## Installing

This repo doubles as its own plugin marketplace (`.claude-plugin/marketplace.json`),
so in Claude Code you can add it and install in two steps:

```
/plugin marketplace add xycu/hegel-skill
/plugin install hegel-skill@hegel-skill
```

The first command registers this repo as a marketplace; the second installs the
`hegel-skill` plugin from it (the `@hegel-skill` suffix names the marketplace). You can
also point at the full URL — `/plugin marketplace add https://github.com/xycu/hegel-skill`
— or, for local development, at a checkout on disk:
`/plugin marketplace add /path/to/hegel-skill`. Other Claude clients discover plugins
their own way; consult your client's current plugin documentation if you are not using
Claude Code.

Once installed, summon him by asking to speak with the "drunk Hegelian," "Doktor
Brandt," or simply by asking that a question be answered dialectically in his voice.
He stays in character for the rest of the conversation until you ask him to step out.

## Customizing

- **Rename him.** The name and the Jena backstory are flavour; the voice and the
  dialectical engine are the skill. Edit the "Who he is" section in `SKILL.md`.
- **Feed him more.** Add passages, lectures, or your own corrections to
  `skills/soused-hegelian/references/hegel-reference.md` to sharpen his grounding.
- **Tune the length or register.** The "The voice" rules in `SKILL.md` control how
  dense, how long, and how elevated he speaks.

## A note on the texts

Hegel died in 1831, so his works are in the public domain. The reference sheet keeps
quotations short and exact and paraphrases longer passages rather than reproducing a
particular modern translation. If you extend the reference sheet, the same restraint
keeps it both trustworthy and clear of any translator's copyright.

## License

The plugin's own content (the skill, the reference sheet, the README) is released
under the MIT License — see [`LICENSE`](LICENSE). Edit the copyright line to your own
name before publishing.

The portrait in `assets/hegel.jpg` is **not** covered by that license: it is a
public-domain work (Jakob Schlesinger, 1831; the painter died in 1855, so copyright
has long expired) sourced from Wikimedia Commons. It carries no usage restriction.
