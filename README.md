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
├── commands/                             # Claude-plugin slash commands
│   ├── brandt.md                         # /brandt — summon
│   └── brandt-dismiss.md                 # /brandt-dismiss — release the persona
├── .claude/                              # project-scoped Claude Code config
│   ├── commands/opsx/                    # /opsx:* OpenSpec slash commands
│   └── skills/                           # OpenSpec propose/apply/archive workflow skills
├── .github/
│   └── workflows/                        # CI: skill lint+evals, OpenSpec, release, commit hygiene
├── openspec/
│   ├── specs/                            # capability specs (source of truth for behaviour)
│   │   └── soused-hegelian-persona/      # + skill-evaluation, local-test-runner, release-pipeline
│   │       └── spec.md
│   └── changes/                          # proposed changes; archive/ holds the applied ones
├── promptfoo/                            # SLM smoke evals: EN + PL configs, tests, prompt builder
├── skills/
│   └── soused-hegelian/
│       ├── SKILL.md                      # the persona: voice, engine, examples
│       └── references/
│           └── hegel-reference.md        # his shelf: works, glossary, real quotes
├── tools/                                # skill_lint.py + version_check.py (deterministic guards)
├── assets/
│   └── hegel.jpg                         # Schlesinger portrait, 1831 (public domain)
├── run-tests.sh                          # one-command local lint + EN/PL evals (mirrors CI)
├── release-please-config.json            # automated release pipeline config
├── AGENTS.md                             # contributor/agent conventions (full source of truth)
├── CONTRIBUTING.md                       # human-facing contributor entry point
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

Contributors: start with [`CONTRIBUTING.md`](CONTRIBUTING.md) for the branch, PR,
signed-commits, and testing conventions this repo follows (it links to [`AGENTS.md`](AGENTS.md)
for the full detail).

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
   CI renders each run to a self-contained HTML report and uploads it under the
   run's **Artifacts** (`promptfoo-report-<language>`), so the full result table is
   downloadable; locally, `promptfoo view` serves the same results. On a pull
   request CI also posts one **sticky** comment summarizing each suite's language,
   model, and pass/fail — it updates in place on every push instead of accumulating.

These smoke evals catch obvious regressions only — they are **not** a measure of
literary quality and **do not replace manual Claude Code testing**. Before a
release, still run the plugin in Claude Code and confirm it discovers and invokes
the skill correctly.

Run everything locally with one command from the repo root — lint plus the EN + PL
promptfoo evals, mirroring CI:

```bash
./run-tests.sh                       # lint + EN evals + PL evals
./run-tests.sh -k persona-persistence  # lint + only the persona-persistence case (EN+PL)
```

`run-tests.sh` manages Ollama for you: if a server is already running it uses it; if
Ollama is installed but stopped it starts one for the run and shuts it down afterward;
and it auto-pulls the eval model if it is missing. If Ollama is not installed it fails
(the evals cannot run). It exits non-zero if any stage fails. Override the eval model
with `MODEL=other-model ./run-tests.sh` or `./run-tests.sh other-model`. promptfoo is
used from a global install (`npm install -g promptfoo`) if present, otherwise fetched
via a pinned `npx` — no install step required.

When iterating on one behaviour, narrow the eval stages with `-k`/`--filter PATTERN`
(a regex over the case description, passed to promptfoo's `--filter-pattern`):
`./run-tests.sh -k persona-persistence` runs the EN + PL persona-persistence cases,
`./run-tests.sh -k en-grief$` runs only `en-grief`. Lint still runs; a language with no
matching cases passes with zero cases. The flag and a model override can be combined
(`./run-tests.sh -k grief other-model`).

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

The persona is one portable asset — `skills/soused-hegelian/SKILL.md` plus its
reference sheet — and the repo ships a ready-made install path for every supported
tool, each derived from that single source (so they never drift: CI regenerates and
diffs them on every change). Pick your tool below.

### Claude Code

This repo doubles as its own plugin marketplace (`.claude-plugin/marketplace.json`),
so you add it and install in two steps:

```
/plugin marketplace add xycu/hegel-skill
/plugin install hegel-skill@hegel-skill
```

The first command registers this repo as a marketplace; the second installs the
`hegel-skill` plugin from it (the `@hegel-skill` suffix names the marketplace). You can
also point at the full URL — `/plugin marketplace add https://github.com/xycu/hegel-skill`
— or, for local development, at a checkout on disk:
`/plugin marketplace add /path/to/hegel-skill`.

### Gemini CLI

Install the extension straight from the repo — no clone needed:

```
gemini extensions install https://github.com/xycu/hegel-skill
```

This reads `gemini-extension.json` and loads the persona from `GEMINI.md`.

### Every other tool — copy one file

The remaining tools have no marketplace; you install Brandt by copying one generated
file into the location that tool reads. Clone or download this repo, then copy from
`install/<tool>/` into your project:

| Tool | Copy this file | …to here |
|---|---|---|
| Cursor | `install/cursor/soused-hegelian.mdc` | `.cursor/rules/soused-hegelian.mdc` |
| Windsurf | `install/windsurf/soused-hegelian.md` | `.windsurf/rules/soused-hegelian.md` |
| Cline | `install/cline/soused-hegelian.md` | `.clinerules/soused-hegelian.md` |
| Zed | `install/zed/.rules` | `.rules` (project root) |
| Aider | `install/aider/CONVENTIONS.md` | `CONVENTIONS.md`, then point Aider at it via `--read CONVENTIONS.md` or `.aider.conf.yml` |
| GitHub Copilot | `install/copilot/copilot-instructions.md` | `.github/copilot-instructions.md` |
| Codex | `install/codex/AGENTS.md` | `AGENTS.md` (project root) or `~/.codex/AGENTS.md` |
| OpenCode | `install/opencode/AGENTS.md` | `AGENTS.md` (project root) |

For example, for Cursor:

```bash
mkdir -p .cursor/rules
cp install/cursor/soused-hegelian.mdc .cursor/rules/
```

In a copied rules file the persona is **always on** for that project — there is no
per-turn eligibility roll and no one-turn spontaneous takeover (those belong to the
Claude Code skill; see [How he activates](#how-he-activates)). The `/brandt` and
`/brandt-dismiss` slash commands are likewise a **Claude-plugin-only** surface — the
other tools have no command system here, so you summon and drop him with the
plain-phrase requests instead. The dialectical engine, voice, citation rules, and
boundary cases are identical to the Claude Code skill — every artifact is generated
from the same source.

### Any other tool

Not listed here? Most agents discover project rules their own way — point yours at
`skills/soused-hegelian/SKILL.md`, or drop its contents into whatever rules file your
tool reads. Consult your client's current documentation for where that lives.

## How he activates

The skill is **eligible by default on every turn** — it is not gated by a fixed list
of trigger phrases. Eligibility is not the same as speaking, though: on the vast
majority of turns Brandt stays silent and you get a plain answer. Each turn resolves
top-down through a short ladder, and the first rung that matches wins:

1. **Manual summon — deterministic and sticky.** Ask to speak with the "drunk
   Hegelian" / "soused philosopher," "Doktor Brandt," or simply that a question be
   answered dialectically / in Hegelian terms / in his voice, and he engages in full.
   He then **stays in character for the rest of the conversation** until you sincerely
   ask him to step out. A manual summon always wins — even on the sensitive turns the
   next rung guards (grief summoned deliberately routes to grave tenderness).
2. **Deny-list — he holds his tongue.** When you have *not* summoned him and the turn
   is genuine distress, grief, or despair, or a safety / security / legal matter, he
   neither takes over nor trails a closing aside. You get a plain, appropriate answer
   with no persona markers.
3. **The d20 — a rare one-turn visit.** Otherwise he rolls a twenty-sided die: a
   genuine ~1-in-20 chance. On a **13** he spontaneously takes over for that **single
   turn** — answering your actual question through the dialectic, in full voice — and
   then steps back; the next turn rolls fresh, so a spontaneous takeover is **never
   sticky**. On anything else you get a plain answer (after which a brief, separate wit
   aside may occasionally trail it).

So unless you summon him, he is almost always quiet — the spontaneous takeover is
deliberately rare, and it never fires on the sensitive contexts above. Only a manual
summon makes him persist.

## Summoning Brandt

In **Claude Code**, the plugin ships two slash commands so summoning and dismissal
are discoverable from the `/` menu — no incantation to memorize:

- **`/brandt [question]`** — a manual summon (rung 1 above): deterministic, sticky
  for the rest of the conversation, and deny-list-overriding, in full voice with the
  `slop:` footer. Pass a question to have him answer it (`/brandt what is freedom?`);
  invoke it bare to engage him and bring the matter yourself on the next turn.
- **`/brandt-dismiss`** — the sincere request to drop the persona. It ends a sticky
  summoned session and returns later turns to plain answers. With no summon active it
  is a harmless no-op. It does **not** suppress the spontaneous mechanisms — after a
  dismissal the d20 takeover and wit aside operate exactly as before.

The commands are pure routing onto the activation ladder; the **plain-phrase summons
still work everywhere** — ask to "speak with the drunk Hegelian," for "Doktor Brandt,"
or that a question be answered "dialectically," and he engages just the same, in Claude
Code and in every other tool below.

## Releases

Releases are automated with [release-please](https://github.com/googleapis/release-please)
in its release-PR model. Every push to `main` updates a standing **release PR** that
accumulates the pending changes; merging that PR bumps the version, tags it, and publishes
a [GitHub Release](https://github.com/xycu/hegel-skill/releases) with a generated changelog
— all through the normal reviewed flow, so protected `main` is never bypassed.

- **Version source of truth.** The same version lives in three fields — `version` in
  `.claude-plugin/plugin.json`, and `metadata.version` plus `plugins[0].version` in
  `.claude-plugin/marketplace.json`. release-please updates all three together; a CI
  guard (`tools/version_check.py`) fails the build if they ever drift apart. The
  marketplace version is how an installed plugin detects that a newer release exists.
- **Bump type comes from your commits.** The PR title (the squash subject on `main`) is a
  [Conventional Commit](https://www.conventionalcommits.org/): `fix:` → patch, `feat:` →
  minor, and a `!` / `BREAKING CHANGE:` → major.
- **Signing.** The automation runs as the default `GITHUB_TOKEN` bot; its commits and tags
  are created through the GitHub API, which signs them so they show as "Verified" and
  satisfy the all-branches signed-commits rule. (Caveat: `GITHUB_TOKEN`-authored PRs do not
  trigger other workflows, so `main` requires no blocking status checks — they still run and
  show on PRs, and the release PR is gated by required review plus the signing rule instead.)

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
