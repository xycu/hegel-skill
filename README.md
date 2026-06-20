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

## Testing

The skill is prose, but two automated layers guard against regressions (CI:
[`.github/workflows/skill-ci.yml`](.github/workflows/skill-ci.yml)):

1. **Deterministic lint** — `tools/skill_lint.py` checks the package structure,
   the plugin/marketplace JSON, the `SKILL.md` frontmatter (`name`,
   `description`, activation terms), and that the body still documents the
   load-bearing behaviours. No model, no dependencies.
2. **Local SLM smoke evals** — [promptfoo](https://www.promptfoo.dev/) runs the
   skill against a small local model via [Ollama](https://ollama.com) and checks
   shallow, contract-based markers (`icontains-any` / `icontains-all` /
   `not-icontains-any`) plus an advisory `slop:` footer metric. The configs live
   under [`promptfoo/`](promptfoo/) (EN + PL); both default to `gemma4:e4b-it-qat`.

These smoke evals catch obvious regressions only — they are **not** a measure of
literary quality and **do not replace manual Claude Code testing**. Before a
release, still run the plugin in Claude Code and confirm it discovers and invokes
the skill correctly.

Run everything locally with one command from the repo root — lint plus the EN + PL
promptfoo evals, mirroring CI:

```bash
./run-tests.sh                  # lint + EN evals + PL evals
```

`run-tests.sh` manages Ollama for you: if a server is already running it uses it; if
Ollama is installed but stopped it starts one for the run and shuts it down afterward;
and it auto-pulls the eval model if it is missing. If Ollama is not installed it fails
(the evals cannot run). It exits non-zero if any stage fails. Override the eval model
with `MODEL=other-model ./run-tests.sh` or `./run-tests.sh other-model`. promptfoo is
used from a global install (`npm install -g promptfoo`) if present, otherwise fetched
via a pinned `npx` — no install step required.

To run the layers individually (Python 3.12+ for the lint; Node + Ollama for the evals):

```bash
python tools/skill_lint.py                              # lint, no model
promptfoo eval -c promptfoo/promptfooconfig.en.yaml     # English evals
promptfoo eval -c promptfoo/promptfooconfig.pl.yaml     # Polish evals
```

Set `EVAL_MODEL` to override the eval model (default `gemma4:e4b-it-qat`).
`OLLAMA_BASE_URL` overrides the server URL (default `http://localhost:11434`);
`run-tests.sh` also accepts the legacy `OLLAMA_HOST` and mirrors it across.

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
