# Eval-runner image: Ollama + promptfoo with SLM weights baked in so the
# Cloud Run Job needs no cold-start model pull.
#
# Build context is the repo root:
#   docker build -f infra/docker/Dockerfile -t <region>-docker.pkg.dev/<proj>/hegel-eval/eval:latest .
FROM ollama/ollama:latest

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 python3-pip nodejs npm curl ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN npm install -g promptfoo

# Models to bake in. Keep in sync with the promptfoo configs and tfvars.
ARG EVAL_MODEL=gemma2:2b
ARG GRADER_MODEL=gemma2:9b-instruct-q4_0
ARG EMBED_MODEL=nomic-embed-text

# Pull weights at build time (transient ollama server), so they ship in a layer.
RUN ollama serve & \
    for i in $(seq 1 30); do curl -sf http://127.0.0.1:11434/ >/dev/null && break; sleep 1; done && \
    ollama pull "$EVAL_MODEL" && \
    ollama pull "$GRADER_MODEL" && \
    ollama pull "$EMBED_MODEL" && \
    pkill -f "ollama serve"

COPY . /workspace
WORKDIR /workspace

# Override the base image's ollama entrypoint with our eval driver.
ENTRYPOINT ["/workspace/infra/docker/run-evals.sh"]
