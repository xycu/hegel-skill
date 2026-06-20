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
import time
import urllib.error
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SKILL = ROOT / "skills" / "soused-hegelian" / "SKILL.md"
REFERENCE = ROOT / "skills" / "soused-hegelian" / "references" / "hegel-reference.md"

SLOP_FOOTER_MARKER = "slop:"  # checked alongside an N/10 digit run


# Known eval languages (for inference). English needs no directive (the skill's
# examples are English, so the default already produces English).
LANG_NAMES = {"en": "English", "pl": "Polish"}

# Per-language output directive, written *in the target language*. Instructing in
# the language itself primes a small model to continue in it — far more reliable
# than an English "write in Polish" meta-instruction, which Bielik answered in
# French. Names no assertion marker terms. Forbids the languages it drifts to.
LANG_DIRECTIVES = {
    "pl": (
        "\n=== JĘZYK ODPOWIEDZI (ważniejszy niż język przykładów powyżej) ===\n"
        "Pytanie użytkownika jest po polsku. Napisz CAŁĄ swoją odpowiedź po polsku, "
        "w głosie Doktora Brandta. Przykłady powyżej są po angielsku tylko dla "
        "ilustracji i nie są powodem, aby odpowiadać po angielsku. Nie odpowiadaj "
        "po angielsku ani po francusku — wyłącznie po polsku.\n"
    ),
}


def build_system_prompt(lang: str | None = None) -> str:
    skill = SKILL.read_text(encoding="utf-8")
    reference = REFERENCE.read_text(encoding="utf-8")
    directive = LANG_DIRECTIVES.get(lang, "")
    if directive:
        # The skill's worked examples are all in English. A weak proxy model
        # parrots/translates them instead of answering in the target language
        # (Bielik regurgitated Example 1 for a "fix my Python" prompt and copied
        # Example 3 verbatim). Drop them for non-English runs so the model relies
        # on the instructions. The capable real runtime keeps the examples.
        skill = skill.split("\n## Examples")[0].rstrip() + "\n"
    prompt = (
        "You are running the following skill. Obey its instructions exactly, "
        "including any required output footer.\n\n"
        f"=== SKILL.md ===\n{skill}\n\n"
        f"=== references/hegel-reference.md ===\n{reference}\n"
    )
    return prompt + directive


def call_ollama(model: str, system: str, prompt: str) -> dict:
    """Return the full Ollama /api/chat response body (message + diagnostics)."""
    host = os.environ.get("OLLAMA_HOST", "http://localhost:11434").rstrip("/")
    payload = json.dumps({
        "model": model,
        "stream": False,
        "options": {
            # num_ctx must exceed the injected SKILL.md+reference (~6k tokens) or
            # Ollama silently truncates the prompt to its 4096 default and the
            # model produces garbage. Sized well above prompt + num_predict so
            # generation is capped by num_predict, never by the context window.
            # KV cache for this fits the 16 GB runner with room to spare.
            "num_ctx": 12288,
            # Full Brandt answers run long; 800 truncated them mid-sentence and a
            # thinking-heavy case spent its whole budget before emitting content.
            "num_predict": 1600,
            "temperature": 0.7,
            "seed": 7,
        },
        "messages": [
            {"role": "system", "content": system},
            {"role": "user", "content": prompt},
        ],
    }).encode("utf-8")
    req = urllib.request.Request(
        f"{host}/api/chat", data=payload, headers={"Content-Type": "application/json"}
    )
    # A 7B model on a CPU runner can take many minutes for one answer (load +
    # ~6k-token prompt eval + generation). The default socket timeout must cover
    # the slowest single call, not the whole job. Override with EVAL_HTTP_TIMEOUT.
    timeout = int(os.environ.get("EVAL_HTTP_TIMEOUT", "2400"))
    with urllib.request.urlopen(req, timeout=timeout) as resp:
        return json.loads(resp.read().decode("utf-8"))


def has_slop_footer(text: str) -> bool:
    lower = text.lower()
    i = lower.rfind(SLOP_FOOTER_MARKER)
    if i == -1:
        return False
    # require a digit run followed by /10 somewhere after the marker
    tail = lower[i:]
    return "/10" in tail and any(c.isdigit() for c in tail.split("/10")[0])


def check_case(case: dict, output: str) -> tuple[list[str], list[str]]:
    """Return (failures, advisories). Failures fail the case; advisories never do."""
    fails: list[str] = []
    low = output.lower()

    if not output.strip():
        fails.append("empty model output")

    any_terms = case.get("must_include_any", [])
    if any_terms and not any(t.lower() in low for t in any_terms):
        fails.append(f"must_include_any: none of {any_terms} present")

    for t in case.get("must_include_all", []):
        if t.lower() not in low:
            fails.append(f"must_include_all: missing {t!r}")

    for t in case.get("must_not_include", []):
        if t.lower() in low:
            fails.append(f"must_not_include: found forbidden {t!r}")

    # The slop footer is a skill feature built on the stop-slop machinery and a
    # multi-pass self-scoring loop. A bare system-prompted local model (with no
    # stop-slop skill, which CI never installs) usually can't perform it, so it
    # is advisory — reported for visibility, never a smoke-test failure.
    advisories: list[str] = []
    if not has_slop_footer(output):
        advisories.append("slop footer absent (advisory — stop-slop not installed in CI)")

    return fails, advisories


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--model", required=True, help="Ollama model name")
    ap.add_argument("--evals", required=True, type=Path, help="eval cases JSON file")
    ap.add_argument("--only", default="", help="comma-separated case ids to run (default: all)")
    args = ap.parse_args()

    cases = json.loads(args.evals.read_text(encoding="utf-8"))
    only = {c.strip() for c in args.only.split(",") if c.strip()}
    if only:
        cases = [c for c in cases if c.get("id") in only]
        missing = only - {c.get("id") for c in cases}
        if missing:
            print(f"FATAL: --only ids not found: {sorted(missing)}", file=sys.stderr)
            return 2
    # Infer target language from the eval filename (…en.json / …pl.json) so the
    # runner can pin output language for weak proxy models.
    name = args.evals.name.lower()
    lang = next((code for code in LANG_NAMES if f"{code}.json" in name or f".{code}." in name), None)
    system = build_system_prompt(lang)
    host = os.environ.get("OLLAMA_HOST", "http://localhost:11434")
    show_full = os.environ.get("EVAL_DEBUG") == "1"

    total = len(cases)
    log(f"== {args.model} | {args.evals.name} | lang={lang} | {total} cases | host {host}")
    log(f"   system prompt: {len(system)} chars")

    failed = 0
    for i, case in enumerate(cases, 1):
        cid = case.get("id", "<no-id>")
        prompt = case["prompt"]
        log(f"\n[{i}/{total}] {cid} — calling {args.model} "
            f"(prompt {len(prompt)} chars)...")
        start = time.monotonic()
        try:
            body = call_ollama(args.model, system, prompt)
        except (urllib.error.URLError, OSError) as e:
            log(f"FATAL: cannot reach Ollama for case {cid}: {e}")
            return 2
        elapsed = time.monotonic() - start
        msg = body.get("message", {})
        output = msg.get("content", "")
        thinking = msg.get("thinking") or ""
        log(f"[{i}/{total}] {cid} — {elapsed:.1f}s, {len(output)} chars returned "
            f"(done_reason={body.get('done_reason')}, "
            f"prompt_tokens={body.get('prompt_eval_count')}, "
            f"gen_tokens={body.get('eval_count')}, "
            f"thinking_chars={len(thinking)})")

        fails, advisories = check_case(case, output)
        for a in advisories:
            log(f"  ~ {a}")
        # On failure (or EVAL_DEBUG) show the whole answer, not a one-line teaser.
        if fails or show_full:
            log(f"  --- output ({cid}) ---\n{indent(output)}\n  ----------------------")
            if thinking and (fails or show_full):
                log(f"  --- thinking ({cid}) ---\n{indent(thinking)}\n  ----------------------")
        if fails:
            failed += 1
            log(f"FAIL {cid}")
            for f in fails:
                log(f"  - {f}")
        else:
            log(f"PASS {cid}")

    log(f"\n{total - failed}/{total} passed ({args.model}, {args.evals.name})")
    return 1 if failed else 0


def log(msg: str) -> None:
    """Print and flush immediately so CI shows live progress, not a final dump."""
    print(msg, flush=True)


def indent(text: str) -> str:
    return "\n".join("  | " + line for line in text.splitlines())


if __name__ == "__main__":
    sys.exit(main())
