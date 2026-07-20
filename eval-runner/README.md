# Eval runner image

A reproducible container that runs the soused-hegelian promptfoo eval suite with
**everything baked in** — the Ollama server, the model(s) under test, promptfoo
pinned to `PROMPTFOO_VERSION`, `run-tests.sh`, and the `promptfoo/` configs. It
pulls **no model at run time**, so it runs the same on a laptop, in CI, or as a
GCP Cloud Run Job (epic #79 / `migrate-evals-to-gcp`, Phase 1).

## Build

The build context is the **repository root**, not this directory:

```sh
# from the repo root
docker build -f eval-runner/Dockerfile -t hegel-evals .
```

### Build-time knobs (`--build-arg`)

| Arg                 | Default             | Purpose                                            |
| ------------------- | ------------------- | -------------------------------------------------- |
| `OLLAMA_VERSION`    | `0.32.1`            | Pinned `ollama/ollama` base tag.                   |
| `EVAL_MODELS`       | `gemma4:e4b-it-qat` | Space-separated list of models baked into `/models`. |
| `PROMPTFOO_VERSION` | `0.121.17`          | promptfoo version installed in the image.          |
| `NODE_MAJOR`        | `24`                | Node major version (promptfoo runtime).            |

Bake more than one model so they can be selected at run time without a pull:

```sh
docker build -f eval-runner/Dockerfile \
  --build-arg EVAL_MODELS="gemma4:e4b-it-qat llama3.2:3b" \
  -t hegel-evals .
```

### Building for GCP (linux/amd64)

Cloud Run runs **linux/amd64 only**. A local `docker build` on Apple Silicon
produces an **arm64** image Cloud Run cannot run, so the image destined for
Artifact Registry is built in CI on GitHub's amd64 runners and pushed over keyless
WIF — see `.github/workflows/eval-image.yml` (manual `workflow_dispatch`). Trigger
it with `gh workflow run "Eval image"`; it pushes `…/hegel-evals/runner:latest`
plus a `:<sha>` tag. The local `run-local.sh` path below stays arm64 for laptop
iteration — it never touches GCP.

## Run — local containerised runner

`eval-runner/run-local.sh` is the one command to run the suite **inside** the
container from the repo root. It builds the image once if absent, reuses it
otherwise, and `docker run`s it — propagating the container's exit code unchanged,
so it mirrors CI (`0` = every eval stage passed, non-zero = any failed). This is
the local de-risk step before any cloud spend: what passes here is what a Cloud
Run Job will run.

```sh
eval-runner/run-local.sh                     # full graded suite, default baked model
eval-runner/run-local.sh --core              # fast PR-gate core subset (== skill-ci.yml)
eval-runner/run-local.sh --core -k en-grief  # one behaviour, EN+PL
eval-runner/run-local.sh --offline --core    # prove offline: no run-time pull
eval-runner/run-local.sh --rebuild --core    # force an image rebuild first
```

Wrapper flags: `--core`, `--rebuild`, `--no-build`, `--offline` (adds
`--network none`), `--image NAME`. Everything after them is forwarded verbatim to
`run-tests.sh` in the container (`--core`, `-k PATTERN`, a positional `MODEL`).
`--offline` with an **un-baked** model is how a missing model surfaces as a
non-zero exit — the same signal CI would give.

> **Memory:** the model runs on CPU and needs headroom — `gemma4:e4b-it-qat`
> (multimodal, ~6 GB + KV cache at `num_ctx` 12288) is OOM-killed on Docker
> Desktop's default 8 GB VM (empty output → every keyword gate fails). Give the
> engine **≥ 12 GiB** (Docker Desktop → Settings → Resources → Memory). This is
> also the memory floor to size the Phase 3 Cloud Run Job against.

### Raw `docker run`

The entrypoint is `run-tests.sh`; it manages the Ollama lifecycle. The image sets
`RUN_LINT=0`, so it runs **evals only** — the container carries just the eval
sources, not the whole package surface `skill_lint.py` checks; lint stays on the
host / CI runner (#79). Args pass straight through.

```sh
docker run --rm hegel-evals                        # full graded suite, default model
docker run --rm hegel-evals --core                 # fast core subset (judge off)
docker run --rm hegel-evals mymodel:tag            # pick a baked model (positional)
docker run --rm -e MODEL=mymodel:tag hegel-evals   # ...or via MODEL=
docker run --rm hegel-evals -k persona-persistence # filter cases (EN+PL)
```

### Run-time knobs (`-e`)

| Env           | Default             | Purpose                                                             |
| ------------- | ------------------- | ------------------------------------------------------------------- |
| `MODEL`       | `gemma4:e4b-it-qat` | Model under test. Also settable as a positional arg. Must be **baked**. |
| `GRADER_MODEL`| = `MODEL`           | Judge model for the `llm-rubric` graded suite (full config only).   |
| `RUN_LINT`    | `0` (in image)      | `1` re-enables the lint stage; the image omits its inputs, so leave `0`. |

> Select the model under test with `MODEL=` or the positional arg — `run-tests.sh`
> derives `EVAL_MODEL` from it, so passing `-e EVAL_MODEL=` directly is overridden.
> A `MODEL`/`GRADER_MODEL` that was not baked reintroduces a run-time pull
> (network); keep to the baked set to preserve the offline guarantee.

## Layer-cache design

Layers are ordered least- to most-volatile so rebuilds stay cheap:

1. OS + Node + Python (rarely changes)
2. runtime user + empty model store
3. **baked models** — big and least-volatile; baked as `evaluser` to avoid a
   multi-GB `chown -R` layer
4. pinned promptfoo (after the models, so a version bump doesn't re-bake)
5. eval sources (`run-tests.sh`, `tools/`, `promptfoo/`, `skills/`,
   `.claude-plugin/`) — most volatile, copied last

Editing a test or bumping promptfoo therefore never re-pulls the model.
