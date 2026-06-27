#!/usr/bin/env python3
"""Generate per-tool install artifacts from the canonical persona source.

Canonical single source of truth — never hand-fork a copy of the persona:
  skills/soused-hegelian/SKILL.md                       -- persona body + activation
  skills/soused-hegelian/references/hegel-reference.md  -- the shelf

Every file written here is DERIVED and COMMITTED. CI (issue #43) regenerates and
diffs to guard against drift, per openspec/specs/cross-tool-install. Stdlib only,
no model, no third-party deps; runs from anywhere:

  python3 tools/build_install_artifacts.py            # write artifacts
  python3 tools/build_install_artifacts.py --check    # exit 1 if anything is stale

This build covers: Gemini CLI (#41), Codex + OpenCode (#42), and the editor rules
files (#40) for Cursor / Windsurf / Cline / Zed / Aider / GitHub Copilot.
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SKILL = ROOT / "skills" / "soused-hegelian" / "SKILL.md"
REFERENCE = ROOT / "skills" / "soused-hegelian" / "references" / "hegel-reference.md"
PLUGIN_JSON = ROOT / ".claude-plugin" / "plugin.json"

ACTIVATION_HEADER = "## When he speaks — activation"

# Replaces the Claude-Code-specific activation ladder. A rules-file persona is
# always-on for its project; per the design note (#39) only this activation phrasing
# is adapted — the engine, voice, citations, slop pass, and boundary cases are
# transcluded verbatim.
ADAPTER = """## Activation — always on

You are Doktor Anselm Brandt for this project: the persona is **always on**, in full,
and stays in his voice across the whole conversation. There is no per-turn eligibility
roll and no one-turn spontaneous takeover here — those belong to the Claude Code skill
this file is derived from, so any mention below of a "d20", "eligibility", or a
"spontaneous wit aside" describes that mechanism and does not apply.

What carries across unchanged: the dialectical engine on **every** answer, the voice,
the citation rules, the slop pass with its `slop: N/10 (K revisions)` footer, and the
boundary cases — the **deny-list** (genuine distress, grief, or despair, or a safety /
security / legal matter, is answered plainly with no persona markers) and the grave
tenderness owed to someone in real pain."""


def _persona_markdown() -> str:
    """Transclude SKILL.md (minus frontmatter), swap the activation ladder for the
    always-on adapter, and inline the reference shelf. One source, one derived blob."""
    text = SKILL.read_text(encoding="utf-8")
    if not text.startswith("---\n"):
        raise SystemExit("build_install_artifacts: SKILL.md missing frontmatter")
    close = text.find("\n---", 4)
    if close == -1:
        raise SystemExit("build_install_artifacts: SKILL.md frontmatter not closed")
    body = text[close + len("\n---"):].lstrip("\n")

    start = body.find(ACTIVATION_HEADER)
    nxt = body.find("\n## ", start + len(ACTIVATION_HEADER)) if start != -1 else -1
    if start == -1 or nxt == -1:
        raise SystemExit("build_install_artifacts: could not locate activation section")
    body = body[:start] + ADAPTER + "\n\n" + body[nxt + 1:]

    reference = REFERENCE.read_text(encoding="utf-8").strip()
    return (
        body.rstrip()
        + "\n\n## Brandt's shelf — the reference sheet\n\n"
        + reference
        + "\n"
    )


def _plugin() -> dict:
    return json.loads(PLUGIN_JSON.read_text(encoding="utf-8"))


# --- Targets -----------------------------------------------------------------

GEMINI_MANIFEST = ROOT / "gemini-extension.json"
GEMINI_CONTEXT = ROOT / "GEMINI.md"
CODEX_AGENTS = ROOT / "install" / "codex" / "AGENTS.md"
OPENCODE_AGENTS = ROOT / "install" / "opencode" / "AGENTS.md"


def _gemini_targets() -> dict[Path, str]:
    """Gemini CLI extension (#41): repo-root manifest + context file. Installed with
    `gemini extensions install https://github.com/xycu/hegel-skill`. The version is
    stamped from plugin.json so it stays in parity (CI-guarded in #43)."""
    plugin = _plugin()
    manifest = {
        "name": "hegel-skill",
        "version": plugin["version"],
        "description": plugin["description"],
        "contextFileName": "GEMINI.md",
    }
    return {
        GEMINI_MANIFEST: json.dumps(manifest, indent=2, ensure_ascii=False) + "\n",
        GEMINI_CONTEXT: _persona_markdown(),
    }


def _agents_md_targets() -> dict[Path, str]:
    """Codex (#42) and OpenCode (#42) both read the AGENTS.md standard
    (https://agents.md) — plain markdown instructions, no schema. The persona is
    derived once and written to each tool's copy-in file; users drop it at their
    project root or in the tool's global config (e.g. ~/.codex/AGENTS.md). Documented
    per-tool in the README install matrix (#44)."""
    persona = _persona_markdown()
    return {CODEX_AGENTS: persona, OPENCODE_AGENTS: persona}


# Editor agents (#40): no plugin marketplace — you install Brandt by copying ONE
# generated rules file into the tool's rules dir. Each takes a single rules blob, so
# the shelf is inlined (per design note #4). The persona body is identical across all
# six; only the per-tool header/frontmatter differs, and only where the tool needs it
# to treat the file as always-on. Destination paths the README matrix (#44) points at:
#   Cursor   -> .cursor/rules/soused-hegelian.mdc
#   Windsurf -> .windsurf/rules/soused-hegelian.md
#   Cline    -> .clinerules/soused-hegelian.md
#   Zed      -> .rules
#   Aider    -> CONVENTIONS.md (referenced via --read / .aider.conf.yml)
#   Copilot  -> .github/copilot-instructions.md
EDITOR = ROOT / "install"


def _editor_targets() -> dict[Path, str]:
    persona = _persona_markdown()
    description = _plugin()["description"]
    # Cursor only applies an .mdc rule when its frontmatter says so; alwaysApply: true
    # makes the persona project-wide. Empty globs => not path-scoped.
    cursor_frontmatter = (
        "---\n"
        f'description: "{description}"\n'
        "globs:\n"
        "alwaysApply: true\n"
        "---\n\n"
    )
    # Windsurf reads the activation mode from frontmatter; always_on mirrors Cursor.
    windsurf_frontmatter = "---\ntrigger: always_on\n---\n\n"
    return {
        EDITOR / "cursor" / "soused-hegelian.mdc": cursor_frontmatter + persona,
        EDITOR / "windsurf" / "soused-hegelian.md": windsurf_frontmatter + persona,
        # Cline, Zed, Aider, and Copilot load their rules file unconditionally — the
        # "always on" adapter in the body is all the activation note they need.
        EDITOR / "cline" / "soused-hegelian.md": persona,
        EDITOR / "zed" / ".rules": persona,
        EDITOR / "aider" / "CONVENTIONS.md": persona,
        EDITOR / "copilot" / "copilot-instructions.md": persona,
    }


def build() -> dict[Path, str]:
    """All artifacts this build produces, as {path: desired content}."""
    return {**_gemini_targets(), **_agents_md_targets(), **_editor_targets()}


def main(argv: list[str]) -> int:
    check = "--check" in argv[1:]
    files = build()
    if check:
        stale = [
            p for p, content in files.items()
            if (p.read_text(encoding="utf-8") if p.exists() else None) != content
        ]
        if stale:
            print(
                "build_install_artifacts: stale/missing (run without --check):",
                file=sys.stderr,
            )
            for p in stale:
                print(f"  - {p.relative_to(ROOT)}", file=sys.stderr)
            return 1
        print(f"build_install_artifacts: {len(files)} artifact(s) up to date")
        return 0

    for path, content in files.items():
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(content, encoding="utf-8")
    print(f"build_install_artifacts: wrote {len(files)} file(s)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
