#!/usr/bin/env python3
"""Version-drift guard for the plugin package.

The plugin version is duplicated across fields that MUST stay in lockstep:
  - .claude-plugin/plugin.json            -> version
  - .claude-plugin/marketplace.json       -> metadata.version
  - .claude-plugin/marketplace.json       -> plugins[0].version
  - gemini-extension.json                 -> version   (cross-tool artifact, #43)

The release pipeline (release-please) updates them together via its `extra-files`
config, but a manual edit, a botched updater config, or a partial revert could
desynchronize them. This deterministic check fails (exit 1, naming the divergent
field) if they ever disagree. Any future tool manifest that carries its own
version (per the cross-tool-install spec) is added here so bumping plugin.json
without bumping it fails the build. No model, no third-party dependencies. Run
from anywhere.
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
PLUGIN_JSON = ROOT / ".claude-plugin" / "plugin.json"
MARKETPLACE_JSON = ROOT / ".claude-plugin" / "marketplace.json"
GEMINI_MANIFEST = ROOT / "gemini-extension.json"


def collect() -> list[tuple[str, str]]:
    """Return (label, version) for each tracked field."""
    plugin = json.loads(PLUGIN_JSON.read_text(encoding="utf-8"))
    marketplace = json.loads(MARKETPLACE_JSON.read_text(encoding="utf-8"))
    gemini = json.loads(GEMINI_MANIFEST.read_text(encoding="utf-8"))
    return [
        ("plugin.json:version", plugin["version"]),
        ("marketplace.json:metadata.version", marketplace["metadata"]["version"]),
        ("marketplace.json:plugins[0].version", marketplace["plugins"][0]["version"]),
        ("gemini-extension.json:version", gemini["version"]),
    ]


def check() -> list[str]:
    fields = collect()
    versions = {v for _, v in fields}
    if len(versions) == 1:
        return []
    # Report against the plugin.json value as the reference.
    reference = fields[0][1]
    return [
        f"{label} = {value!r} (expected {reference!r})"
        for label, value in fields
        if value != reference
    ]


def main() -> int:
    errors = check()
    if errors:
        print("version_check: version fields drift:", file=sys.stderr)
        for e in errors:
            print(f"  - {e}", file=sys.stderr)
        return 1
    print(f"version_check: OK ({collect()[0][1]})")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
