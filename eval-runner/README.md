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

## Run

The entrypoint is `run-tests.sh`; it manages the Ollama lifecycle and mirrors CI
exit codes (`0` = all stages passed, non-zero = any failed). Args pass straight
through.

```sh
docker run --rm hegel-evals                              # full suite, default model
docker run --rm -e EVAL_MODEL=llama3.2:3b hegel-evals    # pick a baked model
docker run --rm hegel-evals -k persona-persistence       # filter cases (EN+PL)
```

### Run-time knobs (`-e`)

| Env           | Default             | Purpose                                                  |
| ------------- | ------------------- | -------------------------------------------------------- |
| `EVAL_MODEL`  | `gemma4:e4b-it-qat` | Model under test. Must have been **baked**, or it pulls. |
| `GRADER_MODEL`| = `EVAL_MODEL`      | Judge model for the `llm-rubric` graded suite.           |

> Selecting an `EVAL_MODEL`/`GRADER_MODEL` that was not baked reintroduces a
> run-time pull (network). Keep to the baked set to preserve the offline
> guarantee.

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
