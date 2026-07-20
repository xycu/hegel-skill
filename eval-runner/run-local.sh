#!/bin/sh
# Run the eval suite INSIDE the eval-runner container, locally, from the repo root.
#
# This is the Phase 2 local runner for migrate-evals-to-gcp (#79 / #171): it wraps
# `docker build` + `docker run` around the image built from eval-runner/Dockerfile,
# and — because the container's entrypoint is run-tests.sh — its exit code mirrors
# CI (0 = every stage passed, non-zero = any stage failed). De-risks the image
# before any cloud spend: what passes here is what a Cloud Run Job will run.
#
# The image is built once if absent and reused (it bakes a multi-GB model, so a
# rebuild is slow); pass --rebuild to force one.
#
# Usage:
#   eval-runner/run-local.sh                    # full suite, default baked model
#   eval-runner/run-local.sh --core             # fast PR-gate core subset (skill-ci.yml)
#   eval-runner/run-local.sh --core -k en-grief # one behaviour, EN+PL
#   eval-runner/run-local.sh --rebuild --core   # force an image rebuild first
#   eval-runner/run-local.sh --offline nope:1   # prove offline: no run-time pull
#
# Everything after the wrapper's own flags is passed straight through to
# run-tests.sh in the container (--core, -k PATTERN, a positional MODEL, ...).
#
# Wrapper flags:
#   --rebuild        Build the image even if it already exists.
#   --no-build       Never build; fail if the image is missing.
#   --offline        Run with `--network none` (no network at run time). The baked
#                    model still works; selecting an un-baked model then fails,
#                    which is exactly how a missing model surfaces as a non-zero exit.
#   --image NAME     Image tag to build/run (default: hegel-evals:latest, or $IMAGE).
#   -h, --help       Show this help.
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
DOCKERFILE=eval-runner/Dockerfile
IMAGE=${IMAGE:-hegel-evals:latest}
BUILD=auto        # auto | always | never
NETWORK_OPT=

usage() { sed -n '2,30p' "$0" | sed 's/^# \{0,1\}//'; }

# Consume wrapper flags until the first token we don't recognise (or `--`); the
# rest is forwarded verbatim to run-tests.sh inside the container.
while [ $# -gt 0 ]; do
    case "$1" in
        --rebuild)  BUILD=always; shift ;;
        --no-build) BUILD=never;  shift ;;
        --offline)  NETWORK_OPT="--network none"; shift ;;
        --image)
            [ $# -ge 2 ] || { printf '%s requires a NAME argument.\n' "$1" >&2; exit 2; }
            IMAGE=$2; shift 2 ;;
        --image=*)  IMAGE=${1#*=}; shift ;;
        -h|--help)  usage; exit 0 ;;
        --)         shift; break ;;
        *)          break ;;   # first run-tests.sh arg — stop parsing, forward the rest
    esac
done

cd "$ROOT" || exit 1

command -v docker >/dev/null 2>&1 || {
    printf 'docker is not installed or not on PATH; cannot run the containerised suite.\n' >&2
    exit 1
}

image_exists() { docker image inspect "$IMAGE" >/dev/null 2>&1; }

case "$BUILD" in
    always) do_build=1 ;;
    never)  do_build=0 ;;
    auto)   if image_exists; then do_build=0; else do_build=1; fi ;;
esac

if [ "$do_build" -eq 1 ]; then
    printf 'Building %s from %s (context: repo root)...\n' "$IMAGE" "$DOCKERFILE"
    docker build -f "$DOCKERFILE" -t "$IMAGE" .
elif ! image_exists; then
    printf 'Image %s is missing and --no-build was given; build it first.\n' "$IMAGE" >&2
    exit 1
else
    printf 'Reusing existing image %s (pass --rebuild to force a rebuild).\n' "$IMAGE"
fi

printf 'Running: docker run --rm %s %s %s\n' "$NETWORK_OPT" "$IMAGE" "$*"

# The container exit code IS run-tests.sh's exit code — propagate it unchanged so
# this wrapper is a drop-in stand-in for the CI check (and, later, the Cloud Run
# Job's completion status).
set +e
docker run --rm $NETWORK_OPT "$IMAGE" "$@"
status=$?
set -e
exit "$status"
