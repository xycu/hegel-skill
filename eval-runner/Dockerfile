# syntax=docker/dockerfile:1
#
# Eval runtime for the soused-hegelian skill: Ollama + the model(s) under test
# baked in, promptfoo pinned to PROMPTFOO_VERSION, run-tests.sh, and the
# promptfoo/ configs. Builds from a clean checkout; pulls NO model at run time.
#
# Build context is the REPOSITORY ROOT (not this directory):
#   docker build -f eval-runner/Dockerfile -t hegel-evals .
#
# Layer order is tuned for cache reuse: the most expensive, least-volatile work
# (baking the multi-GB model) sits as early as possible, and the most volatile
# work (copying the eval configs/tests) sits last. A promptfoo bump or a test
# edit therefore never re-bakes the model.

ARG OLLAMA_VERSION=0.32.1
FROM ollama/ollama:${OLLAMA_VERSION}

LABEL org.opencontainers.image.title="hegel-skill eval runner" \
      org.opencontainers.image.description="Ollama + promptfoo eval runtime with the model under test baked in." \
      org.opencontainers.image.source="https://github.com/xycu/hegel-skill"

# ---------------------------------------------------------------------------
# 1. OS + language runtimes (rarely change) — Python 3.12 for the offline skill
#    lint, Node for promptfoo, curl for the Ollama readiness probe.
# ---------------------------------------------------------------------------
ENV DEBIAN_FRONTEND=noninteractive
ARG NODE_MAJOR=24
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends ca-certificates curl gnupg python3; \
    mkdir -p /etc/apt/keyrings; \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key \
      | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg; \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_${NODE_MAJOR}.x nodistro main" \
      > /etc/apt/sources.list.d/nodesource.list; \
    apt-get update; \
    apt-get install -y --no-install-recommends nodejs; \
    apt-get purge -y gnupg; \
    apt-get autoremove -y; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*; \
    python3 --version; node --version; npm --version

# ---------------------------------------------------------------------------
# 2. Non-root runtime user, and the model store it owns. Creating the (empty)
#    store now and baking as this user avoids a multi-GB `chown -R` layer later.
# ---------------------------------------------------------------------------
ENV OLLAMA_MODELS=/models
RUN set -eux; \
    useradd --create-home --uid 10001 --shell /usr/sbin/nologin evaluser; \
    mkdir -p "${OLLAMA_MODELS}"; \
    chown evaluser:evaluser "${OLLAMA_MODELS}"

# ---------------------------------------------------------------------------
# 3. Bake the model(s) under test (BIG, least-volatile). Space-separated list;
#    every entry is pulled into the image so nothing is fetched at run time.
#    Override to bake a different / additional set:
#      --build-arg EVAL_MODELS="gemma4:e4b-it-qat llama3.2:3b"
# ---------------------------------------------------------------------------
USER evaluser
ARG EVAL_MODELS="gemma4:e4b-it-qat"
RUN set -eux; \
    ollama serve & pid=$!; \
    for i in $(seq 1 60); do \
      curl -sf http://127.0.0.1:11434/api/tags >/dev/null 2>&1 && break; \
      sleep 1; \
    done; \
    for m in ${EVAL_MODELS}; do echo "Baking model: ${m}"; ollama pull "${m}"; done; \
    ollama list; \
    kill "${pid}" 2>/dev/null || true; \
    wait "${pid}" 2>/dev/null || true

# ---------------------------------------------------------------------------
# 4. promptfoo pinned to the single-source-of-truth version (bumps rarely).
#    Placed AFTER the model bake so a version bump doesn't invalidate it.
# ---------------------------------------------------------------------------
USER root
ARG PROMPTFOO_VERSION=0.121.17
RUN set -eux; \
    npm install -g "promptfoo@${PROMPTFOO_VERSION}"; \
    npm cache clean --force; \
    promptfoo --version

# ---------------------------------------------------------------------------
# 5. Eval sources (MOST volatile — copied last). run-tests.sh drives the suite;
#    tools/ + skills/ + .claude-plugin/ back the offline lint; promptfoo/ holds
#    the configs, prompt, asserts, references, and tests.
# ---------------------------------------------------------------------------
WORKDIR /app
COPY --chown=evaluser:evaluser run-tests.sh ./run-tests.sh
COPY --chown=evaluser:evaluser tools/ ./tools/
COPY --chown=evaluser:evaluser promptfoo/ ./promptfoo/
COPY --chown=evaluser:evaluser skills/ ./skills/
COPY --chown=evaluser:evaluser .claude-plugin/ ./.claude-plugin/

# run-tests.sh calls `$PYTHON` (default `python`), but Ubuntu ships only
# `python3`; PROMPTFOO_VERSION is re-exported so the pinned in-image promptfoo is
# never shadowed by an npx fetch. EVAL_MODEL / GRADER_MODEL select which baked
# model to run against at run time (no pull, provided it was baked).
# RUN_LINT=0: this image carries only the eval sources, not the whole package
# surface skill_lint.py validates (install artifacts, command files), so it runs
# evals only — lint stays on the host / CI runner (#79: lint doesn't touch the
# container). Copying those artifacts in just to lint would bloat the image with
# generated files that can drift independently of the evals.
ENV PYTHON=python3 \
    PROMPTFOO_VERSION=${PROMPTFOO_VERSION} \
    OLLAMA_HOST=http://127.0.0.1:11434 \
    EVAL_MODEL=gemma4:e4b-it-qat \
    RUN_LINT=0

USER evaluser

# run-tests.sh manages the Ollama lifecycle itself and mirrors CI exit codes
# (0 = all stages pass, non-zero = any failed). Args pass straight through, e.g.
#   docker run --rm hegel-evals               # full suite, default model
#   docker run --rm -e EVAL_MODEL=... hegel-evals
#   docker run --rm hegel-evals -k persona-persistence
ENTRYPOINT ["./run-tests.sh"]
