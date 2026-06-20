#!/bin/sh
# Run every local test in one command, mirroring CI.
#
# Stages (fastest first): skill lint -> eval-runner unit test -> EN evals -> PL evals.
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
# Prerequisites: Python 3.12, Ollama, and the model pulled
# (`ollama pull gemma4:e4b-it-qat`). OLLAMA_HOST overrides the server URL.
set -u

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
cd "$ROOT" || exit 1

PYTHON=${PYTHON:-python}
MODEL=${1:-${MODEL:-gemma4:e4b-it-qat}}
OLLAMA_HOST=${OLLAMA_HOST:-http://localhost:11434}
export OLLAMA_HOST
EVALS_EN=evals/hegel_skill_cases.en.json
EVALS_PL=evals/hegel_skill_cases.pl.json

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

# Pull the eval model if it is not already present. A remote server with no local
# `ollama` binary is left to the eval runner to surface a missing-model error.
ensure_model() {
    command -v ollama >/dev/null 2>&1 || return 0
    if ollama show "$MODEL" >/dev/null 2>&1; then
        printf 'Model %s already present.\n' "$MODEL"
        return 0
    fi
    printf 'Model %s not present — pulling it...\n' "$MODEL"
    ollama pull "$MODEL"
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
# The unit test does `from run_skill_evals import ...`, so run it with tools/ on the path.
run "unit"  sh -c 'cd tools && "$0" test_run_skill_evals.py' "$PYTHON"

if ensure_ollama && ensure_model; then
    run "evals:en"  "$PYTHON" tools/run_skill_evals.py --model "$MODEL" --evals "$EVALS_EN"
    run "evals:pl"  "$PYTHON" tools/run_skill_evals.py --model "$MODEL" --evals "$EVALS_PL"
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
