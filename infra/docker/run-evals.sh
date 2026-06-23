#!/usr/bin/env bash
# Entrypoint for the Cloud Run eval job. Starts Ollama, runs the EN + PL promptfoo
# suites, optionally uploads artifacts to GCS, and exits non-zero on any failure.
set -euo pipefail

: "${GRADER_MODEL:?GRADER_MODEL must be set}"
: "${EMBED_MODEL:?EMBED_MODEL must be set}"
ARTIFACT_BUCKET="${ARTIFACT_BUCKET:-}" # optional gs://bucket/prefix for results

echo "Starting Ollama..."
ollama serve &
for i in $(seq 1 60); do
  curl -sf http://127.0.0.1:11434/ >/dev/null && break
  sleep 1
done

echo "Running EN + PL promptfoo suites..."
rc=0
promptfoo eval -c promptfoo/promptfooconfig.en.yaml --output /tmp/results.en.json || rc=$?
promptfoo eval -c promptfoo/promptfooconfig.pl.yaml --output /tmp/results.pl.json || rc=$?

if [ -n "$ARTIFACT_BUCKET" ]; then
  echo "Uploading results to $ARTIFACT_BUCKET ..."
  gsutil cp /tmp/results.en.json /tmp/results.pl.json "$ARTIFACT_BUCKET/" || true
fi

echo "Eval finished with rc=$rc"
exit "$rc"
