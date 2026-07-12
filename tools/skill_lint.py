#!/usr/bin/env python3
"""Deterministic lint for the soused-hegelian skill package.

Validates package structure and static SKILL.md content with no model calls and
no third-party dependencies. Exit 0 on success, 1 (with reasons) on failure.
"""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SKILL = ROOT / "skills" / "soused-hegelian" / "SKILL.md"
REFERENCE = ROOT / "skills" / "soused-hegelian" / "references" / "hegel-reference.md"
PLUGIN_JSON = ROOT / ".claude-plugin" / "plugin.json"
MARKETPLACE_JSON = ROOT / ".claude-plugin" / "marketplace.json"

# Plugin command surface (add-brandt-commands). The summon command is fixed at
# commands/brandt.md; the dismiss command ships in the preferred nested form
# (commands/brandt/dismiss.md → /brandt:dismiss) or, if the loader rejects the
# file/dir coexistence, the flat fallback (commands/brandt-dismiss.md). Both must
# exist and carry well-formed frontmatter with a description; the commands are thin
# vehicles over the activation ladder, so no body content is asserted here.
COMMANDS_DIR = ROOT / "commands"
SUMMON_COMMAND = COMMANDS_DIR / "brandt.md"
DISMISS_COMMANDS = [
    COMMANDS_DIR / "brandt" / "dismiss.md",
    COMMANDS_DIR / "brandt-dismiss.md",
]

# Per-tool install artifacts (#43). Each generated artifact MUST exist at its
# agreed path, so deleting or renaming one fails the lint. This is the presence
# contract; content/version drift is guarded separately by
# tools/build_install_artifacts.py --check and tools/version_check.py. Keep in
# step with the targets in tools/build_install_artifacts.py and the README matrix.
INSTALL_ARTIFACTS = [
    "gemini-extension.json",                      # Gemini CLI extension (#41)
    "GEMINI.md",
    "install/codex/AGENTS.md",                    # Codex (#42)
    "install/opencode/AGENTS.md",                 # OpenCode (#42)
    "install/cursor/soused-hegelian.mdc",         # editor rules files (#40)
    "install/windsurf/soused-hegelian.md",
    "install/cline/soused-hegelian.md",
    "install/zed/.rules",
    "install/aider/CONVENTIONS.md",
    "install/copilot/copilot-instructions.md",
]

# Terms the description must mention so the client triggers the skill.
DESCRIPTION_TERMS = ["brandt", "hegel", "dialectic"]
# Behavioural rules the body must keep documenting.
BODY_TERMS = ["dialectic", "sublate", "slop", "positive sciences"]


def parse_frontmatter(text: str) -> str | None:
    """Return the raw YAML frontmatter block, or None if not standalone-delimited."""
    if not text.startswith("---\n"):
        return None
    end = text.find("\n---", 4)
    if end == -1:
        return None
    return text[4:end]


def lint() -> list[str]:
    errors: list[str] = []

    for path, label in [(SKILL, "SKILL.md"), (REFERENCE, "reference sheet")]:
        if not path.exists():
            errors.append(f"missing {label}: {path.relative_to(ROOT)}")

    for path in (PLUGIN_JSON, MARKETPLACE_JSON):
        rel = path.relative_to(ROOT)
        if not path.exists():
            errors.append(f"missing {rel}")
            continue
        try:
            json.loads(path.read_text(encoding="utf-8"))
        except json.JSONDecodeError as e:
            errors.append(f"invalid JSON in {rel}: {e}")

    for rel in INSTALL_ARTIFACTS:
        if not (ROOT / rel).exists():
            errors.append(f"missing install artifact: {rel}")

    command_files: list[Path] = []
    if SUMMON_COMMAND.exists():
        command_files.append(SUMMON_COMMAND)
    else:
        errors.append(f"missing command file: {SUMMON_COMMAND.relative_to(ROOT)}")
    dismiss = next((p for p in DISMISS_COMMANDS if p.exists()), None)
    if dismiss is None:
        expected = " or ".join(str(p.relative_to(ROOT)) for p in DISMISS_COMMANDS)
        errors.append(f"missing dismiss command file: expected {expected}")
    else:
        command_files.append(dismiss)

    for path in command_files:
        rel = path.relative_to(ROOT)
        fm = parse_frontmatter(path.read_text(encoding="utf-8"))
        if fm is None:
            errors.append(f"{rel}: missing standalone YAML frontmatter delimiters")
        elif not re.search(r"^description:", fm, re.MULTILINE):
            errors.append(f"{rel} frontmatter: missing 'description'")

    if not SKILL.exists():
        return errors  # nothing more to check without the file

    text = SKILL.read_text(encoding="utf-8")
    fm = parse_frontmatter(text)
    if fm is None:
        errors.append("SKILL.md: missing standalone YAML frontmatter delimiters")
        return errors

    if not re.search(r"^name:\s*soused-hegelian\s*$", fm, re.MULTILINE):
        errors.append("SKILL.md frontmatter: name must equal 'soused-hegelian'")
    if not re.search(r"^description:", fm, re.MULTILINE):
        errors.append("SKILL.md frontmatter: missing 'description'")
    else:
        fm_lower = fm.lower()
        missing = [t for t in DESCRIPTION_TERMS if t not in fm_lower]
        if missing:
            errors.append(f"SKILL.md description missing activation terms: {missing}")

    body_lower = text[len(fm) + 8:].lower()  # skip '---\n' + fm + '\n---'
    missing = [t for t in BODY_TERMS if t not in body_lower]
    if missing:
        errors.append(f"SKILL.md body missing behavioural terms: {missing}")

    return errors


def main() -> int:
    errors = lint()
    if errors:
        print("skill_lint: FAILED")
        for e in errors:
            print(f"  - {e}")
        return 1
    print("skill_lint: OK")
    return 0


if __name__ == "__main__":
    sys.exit(main())
