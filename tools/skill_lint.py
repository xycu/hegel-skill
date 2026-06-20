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
