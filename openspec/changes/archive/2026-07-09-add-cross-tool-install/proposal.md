## Why

The plugin ships only as a Claude Code marketplace plugin (`.claude-plugin/` +
`skills/soused-hegelian/`), which is **already working today**. The persona itself is
a single portable asset — `skills/soused-hegelian/SKILL.md` (voice, dialectical engine,
activation, boundary cases) plus `references/hegel-reference.md` (the shelf) — but no
other tool can discover or load it. Cross-tool packaging widens reach with **zero change
to the persona**: the same dialectical engine, summoned from more places.

Before any per-tool artifact is built, the epic (#38) needs one agreed answer to *how*
the single source becomes a per-tool artifact. This change is that answer. It is the
foundational sub-issue **#39** — _do first, blocks #40/#41/#42/#43/#44_. Output is a
design note plus a `cross-tool-install` capability spec the other sub-issues implement
against; no persona behaviour changes.

## What Changes

- **Claude Code stays the canonical home, untouched.** `.claude-plugin/plugin.json`,
  `marketplace.json`, and `skills/soused-hegelian/` already work and are not modified by
  this epic. They are the single source every other artifact derives from.
- **Add a `cross-tool-install` capability spec** (`openspec/specs/cross-tool-install/`)
  stating the rules every per-tool artifact obeys: single canonical source, generated +
  committed + drift-guarded artifacts, two documented install modalities, version parity,
  and behaviour-unchanged. This change only ADDs the spec — no code, no manifests.
- **Record the design decisions** (below) so #40–#44 have no open "how do we derive X"
  questions: the single-source → per-tool map, committed-vs-generated, the modality split,
  reference/progressive-disclosure handling, and the tool list.

No artifacts, generator script, or CI guard are built here — those are #40–#43, which this
change scopes.

## Decisions (the design note)

### 1. Single source of truth
`skills/soused-hegelian/SKILL.md` + `references/hegel-reference.md` is canonical. Every
per-tool artifact is **derived** from it, never hand-forked. Divergence is a bug, caught
mechanically (see #2), not a matter of discipline.

### 2. Generated **and** committed **and** drift-guarded — recommended
A generator (`tools/build_install_artifacts.py`, built in #40–#42) reads the canonical
source and emits every per-tool artifact. The outputs are **committed** to the repo, and
CI **regenerates and fails on any `git diff`** (the generator is the source of truth for
the derived files). This is the recommendation over the two alternatives:

| Option | Verdict |
|---|---|
| Hand-maintained committed copies (no generator) | **Rejected** — drift-prone, violates single-source. |
| Generated only at install time (nothing committed) | **Rejected** — kills the "copy one rules file" story, and native installs (`gemini extensions install <repo>`) need a manifest already in the repo. |
| **Generated → committed → CI regenerate-and-diff** | **Chosen** — ponytail-style copy-from-repo discoverability *with* a mechanical no-drift guarantee. |

### 3. Two install modalities
- **Native install** — tools with a plugin/extension/marketplace system get a manifest at
  the tool-expected location so they install directly from the repo.
- **Copy-a-rules-file** — tools that only read a project rules file get a generated,
  ready-to-copy file under `install/<tool>/`; the README matrix (#44) says where to drop it.

### 4. Reference / progressive disclosure
Claude Code loads `hegel-reference.md` on demand (progressive disclosure); most other tools
have no such mechanism. The generator therefore: ships the reference as a **second linked
file** where the tool supports multiple rules files or file references, and **inlines** it
under a fenced "Brandt's shelf" section where the tool takes a single rules blob. One source,
both shapes.

### 5. Derivation method: transclude + reformat, never paraphrase
The persona body is **transcluded verbatim** from `SKILL.md`; only the frontmatter/header is
rewritten to each tool's format. The dialectical engine, voice, citation fidelity, and the two
boundary cases are copied **unchanged**. The only **adaptation** is activation mechanics: a
persona rules file is always-on for its project, so Claude-specific self-gating (the d20 roll,
the deny-list, "load this skill") is rephrased tool-neutrally by the generator for tools that
have no skill-eligibility concept. No persona text is paraphrased by hand.

### 6. A `cross-tool-install` capability spec is warranted — yes
The repo already specs its infra capabilities (`release-pipeline`, `ci-infrastructure`). The
sub-issues need stable requirements to implement against, so this change adds the spec rather
than leaving the agreement in an issue comment.

### 7. Tool list and target artifacts
Single source → per-tool map. Exact rules-dir paths are confirmed against each tool's current
docs at implementation time; the **derivation method is fixed here**.

| Tool | Modality | Artifact (recommended target) | Sub-issue |
|---|---|---|---|
| Claude Code | native | `.claude-plugin/` + `skills/` — **done, canonical, untouched** | — |
| Gemini CLI | native | `gemini-extension.json` + `GEMINI.md` (root) | #41 |
| Codex | native | `AGENTS.md` / config manifest | #42 |
| OpenCode | native | plugin / `opencode.json` manifest | #42 |
| Cursor | copy-file | `install/cursor/` → `.cursor/rules/*.mdc` | #40 |
| Windsurf | copy-file | `install/windsurf/` → `.windsurf/rules/` | #40 |
| Cline | copy-file | `install/cline/` → `.clinerules/` | #40 |
| Zed | copy-file | `install/zed/` → `.rules` | #40 |
| Aider | copy-file | `install/aider/` → conventions file | #40 |
| GitHub Copilot | copy-file | `install/copilot/` → `.github/copilot-instructions.md` | #40 |

No tools are hard-dropped. Open items are only "where exactly does tool *T* read its rules,"
resolved per artifact in #40–#42 — **not** "how do we derive it," which is settled above.

## Impact

- New spec capability: `cross-tool-install`. No persona/behaviour spec is touched.
- Unblocks #40, #41, #42; #43 (version-parity + drift CI guard) and #44 (README install
  matrix) build on the modalities and version-parity requirement defined here.
- Constraint honoured: **packaging only** — `soused-hegelian-persona` is unchanged.
