#!/usr/bin/env python3
"""Local SLM smoke evals for the soused-hegelian skill.

Loads SKILL.md + the Hegel reference into the system prompt, sends each eval
case prompt to a local Ollama model, and checks contract-based assertions
(must_include_any / must_include_all / must_not_include) plus the `slop:`
footer. Stdlib only; talks to Ollama over HTTP.

Usage:
    python tools/run_skill_evals.py --model gemma3:1b --evals evals/hegel_skill_cases.en.json

Env:
    OLLAMA_HOST  base URL of the Ollama server (default http://localhost:11434)
"""
from __future__ import annotations

import argparse
import json
import os
import sys
import urllib.error
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SKILL = ROOT / "skills" / "soused-hegelian" / "SKILL.md"
REFERENCE = ROOT / "skills" / "soused-hegelian" / "references" / "hegel-reference.md"

SLOP_FOOTER_MARKER = "slop:"  # checked alongside an N/10 digit run


def build_system_prompt() -> str:
    skill = SKILL.read_text(encoding="utf-8")
    reference = REFERENCE.read_text(encoding="utf-8")
    return (
        "You are running the following skill. Obey its instructions exactly, "
        "including any required output footer.\n\n"
        f"=== SKILL.md ===\n{skill}\n\n"
        f"=== references/hegel-reference.md ===\n{reference}\n"
    )


def call_ollama(model: str, system: str, prompt: str) -> str:
    host = os.environ.get("OLLAMA_HOST", "http://localhost:11434").rstrip("/")
    payload = json.dumps({
        "model": model,
        "stream": False,
        "options": {"temperature": 0, "seed": 7},
        "messages": [
            {"role": "system", "content": system},
            {"role": "user", "content": prompt},
        ],
    }).encode("utf-8")
    req = urllib.request.Request(
        f"{host}/api/chat", data=payload, headers={"Content-Type": "application/json"}
    )
    with urllib.request.urlopen(req, timeout=600) as resp:
        body = json.loads(resp.read().decode("utf-8"))
    return body["message"]["content"]


def has_slop_footer(text: str) -> bool:
    lower = text.lower()
    i = lower.rfind(SLOP_FOOTER_MARKER)
    if i == -1:
        return False
    # require a digit run followed by /10 somewhere after the marker
    tail = lower[i:]
    return "/10" in tail and any(c.isdigit() for c in tail.split("/10")[0])


def check_case(case: dict, output: str) -> list[str]:
    """Return a list of assertion-failure messages (empty == pass)."""
    fails: list[str] = []
    low = output.lower()

    any_terms = case.get("must_include_any", [])
    if any_terms and not any(t.lower() in low for t in any_terms):
        fails.append(f"must_include_any: none of {any_terms} present")

    for t in case.get("must_include_all", []):
        if t.lower() not in low:
            fails.append(f"must_include_all: missing {t!r}")

    for t in case.get("must_not_include", []):
        if t.lower() in low:
            fails.append(f"must_not_include: found forbidden {t!r}")

    if case.get("require_slop_footer", True) and not has_slop_footer(output):
        fails.append("slop footer: missing `slop: N/10`")

    return fails


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--model", required=True, help="Ollama model name")
    ap.add_argument("--evals", required=True, type=Path, help="eval cases JSON file")
    args = ap.parse_args()

    cases = json.loads(args.evals.read_text(encoding="utf-8"))
    system = build_system_prompt()

    failed = 0
    for case in cases:
        cid = case.get("id", "<no-id>")
        try:
            output = call_ollama(args.model, system, case["prompt"])
        except (urllib.error.URLError, OSError) as e:
            print(f"FATAL: cannot reach Ollama for case {cid}: {e}", file=sys.stderr)
            return 2
        fails = check_case(case, output)
        if fails:
            failed += 1
            print(f"FAIL {cid}")
            for f in fails:
                print(f"  - {f}")
            print(f"  --- output ---\n{indent(output)}\n  --------------")
        else:
            print(f"PASS {cid}")

    total = len(cases)
    print(f"\n{total - failed}/{total} passed ({args.model}, {args.evals.name})")
    return 1 if failed else 0


def indent(text: str) -> str:
    return "\n".join("  | " + line for line in text.splitlines())


if __name__ == "__main__":
    sys.exit(main())
