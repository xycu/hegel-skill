#!/bin/sh
# Run every local test in one command, mirroring CI.
#
# Stages (fastest first): skill lint -> EN evals -> PL evals.
# The evals run via promptfoo (configs under promptfoo/).
# All stages run even if an earlier one fails; the script exits non-zero if any did.
#
# Ollama lifecycle (the SLM eval stages need it):
#   - already running    -> use it, leave it running
#   - installed, stopped -> start it for this run, shut it down afterward
#   - not installed      -> hard failure (evals cannot run), mirroring CI
# The model is pulled automatically if it is not already present.
#
# Usage:
#   ./run-tests.sh                 # default model (gemma4:e4b-it-qat)
#   MODEL=other-model ./run-tests.sh
#   ./run-tests.sh other-model     # positional override
#
# Prerequisites: Python 3.12, Node (for promptfoo), and Ollama. promptfoo is used
# from a global install if present, else fetched via `npx` (pinned). The model is
# pulled automatically. OLLAMA_HOST overrides the server URL.
set -u

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
cd "$ROOT" || exit 1

PYTHON=${PYTHON:-python}
MODEL=${1:-${MODEL:-gemma4:e4b-it-qat}}
OLLAMA_HOST=${OLLAMA_HOST:-http://localhost:11434}
export OLLAMA_HOST
# promptfoo reads OLLAMA_BASE_URL; mirror OLLAMA_HOST onto it. The eval model is
# handed to the promptfoo configs via EVAL_MODEL (so --model override still works).
OLLAMA_BASE_URL=${OLLAMA_BASE_URL:-$OLLAMA_HOST}
export OLLAMA_BASE_URL
EVAL_MODEL=$MODEL
export EVAL_MODEL
CONFIG_EN=promptfoo/promptfooconfig.en.yaml
CONFIG_PL=promptfoo/promptfooconfig.pl.yaml

# Resolve promptfoo: prefer a global binary (fast), else a pinned npx (zero-install,
# reproducible). CI installs the same pinned version, so a local pass predicts CI.
PROMPTFOO_VERSION=${PROMPTFOO_VERSION:-0.121.17}
if command -v promptfoo >/dev/null 2>&1; then
    PROMPTFOO="promptfoo"
else
    PROMPTFOO="npx -y promptfoo@${PROMPTFOO_VERSION}"
fi

summary=""
overall=0
started_ollama=0
ollama_pid=

# Shut down Ollama only if we were the ones who started it.
cleanup() {
    if [ "$started_ollama" -eq 1 ] && [ -n "$ollama_pid" ]; then
        printf '\nStopping the Ollama server we started (pid %s)...\n' "$ollama_pid"
        kill "$ollama_pid" 2>/dev/null
        started_ollama=0
    fi
}
trap cleanup EXIT INT TERM

ollama_up() {
    curl -sf "$OLLAMA_HOST/api/tags" >/dev/null 2>&1
}

# Ensure an Ollama server is reachable. Returns non-zero (without starting anything
# we can't) when Ollama is not installed. Sets started_ollama=1 if we launch one.
ensure_ollama() {
    if ollama_up; then
        printf 'Ollama already running at %s — using it.\n' "$OLLAMA_HOST"
        return 0
    fi
    if ! command -v ollama >/dev/null 2>&1; then
        printf 'Ollama is not installed and not running; cannot run SLM evals.\n' >&2
        return 1
    fi
    printf 'Ollama installed but not running — starting it for this run...\n'
    ollama serve >/tmp/run-tests-ollama.log 2>&1 &
    ollama_pid=$!
    started_ollama=1
    i=0
    while [ "$i" -lt 30 ]; do
        ollama_up && { printf 'Ollama is up (pid %s).\n' "$ollama_pid"; return 0; }
        sleep 1
        i=$((i + 1))
    done
    printf 'Ollama failed to become reachable within 30s (see /tmp/run-tests-ollama.log).\n' >&2
    return 1
}

# Embedding model for the advisory `similar` asserts (#32). Default matches
# EMBED_MODEL's default in the promptfoo configs; override with EMBED_MODEL.
EMBED_MODEL=${EMBED_MODEL:-nomic-embed-text}

# Pull the eval model (and the embedding model for `similar` asserts) if absent. A
# remote server with no local `ollama` binary is left to the eval runner to surface
# a missing-model error. The embedding pull is best-effort: `similar` is advisory
# (weight 0), so a missing embedding model never fails the suite.
ensure_model() {
    command -v ollama >/dev/null 2>&1 || return 0
    if ollama show "$MODEL" >/dev/null 2>&1; then
        printf 'Model %s already present.\n' "$MODEL"
    else
        printf 'Model %s not present — pulling it...\n' "$MODEL"
        ollama pull "$MODEL" || return 1
    fi
    if ! ollama show "$EMBED_MODEL" >/dev/null 2>&1; then
        printf 'Embedding model %s not present — pulling it...\n' "$EMBED_MODEL"
        ollama pull "$EMBED_MODEL" || printf 'warning: could not pull %s; similar asserts will be skipped.\n' "$EMBED_MODEL"
    fi
}

# run <label> <command...>
run() {
    label=$1
    shift
    printf '\n=== %s ===\n' "$label"
    if "$@"; then
        summary="${summary}PASS  ${label}\n"
    else
        summary="${summary}FAIL  ${label}\n"
        overall=1
    fi
}

# fail <label> <reason> — record a stage as failed without running it.
fail() {
    printf '\n=== %s ===\n%s\n' "$1" "$2"
    summary="${summary}FAIL  ${1}\n"
    overall=1
}

run "lint"  "$PYTHON" tools/skill_lint.py

if ensure_ollama && ensure_model; then
    printf 'Using promptfoo: %s\n' "$PROMPTFOO"
    # $PROMPTFOO is intentionally unquoted (it may be "npx -y promptfoo@<v>").
    # --no-cache so each run really calls the model, matching CI (fresh runner).
    # -j 1: one request at a time. These local runs hit a single Ollama model on
    # one machine; promptfoo's default concurrency would fire parallel calls that
    # contend for that one model — slower, prone to context truncation, and flakier
    # keyword assertions. CI runs EN/PL as isolated matrix jobs, so its parallelism
    # is fine and unaffected by this local-only setting.
    run "evals:en"  $PROMPTFOO eval -c "$CONFIG_EN" --no-cache -j 1
    run "evals:pl"  $PROMPTFOO eval -c "$CONFIG_PL" --no-cache -j 1
else
    fail "evals:en" "Skipped: Ollama unavailable or model could not be pulled."
    fail "evals:pl" "Skipped: Ollama unavailable or model could not be pulled."
fi

printf '\n=== summary (model: %s) ===\n' "$MODEL"
printf '%b' "$summary"

if [ "$overall" -eq 0 ]; then
    printf '\nAll stages passed.\n'
else
    printf '\nSome stages failed.\n'
fi
exit "$overall"
