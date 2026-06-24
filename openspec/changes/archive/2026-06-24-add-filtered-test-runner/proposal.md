# Proposal: Filter the local test runner to a single behaviour

## What

Add an optional `-k <pattern>` / `--filter <pattern>` flag to `run-tests.sh` that
narrows the promptfoo eval stages to the cases whose description matches `<pattern>`,
passed straight through to promptfoo's `--filter-pattern`. With no flag the runner
behaves exactly as today (every behaviour, both languages).

## Why

Iterating on one behaviour currently means running the whole suite — every behaviour
in both languages, with the model-graded judge on — which is ~13 minutes locally.
During a bugfix you usually care about one case. A filter turns that into a
single-case run of a few seconds to a couple of minutes, so the local-first
discipline ([[ci-iterate-local-first]]) is cheap enough to actually follow tightly.

The mechanism already exists: the CI fast gate uses `--filter-pattern` to narrow to
the three core behaviours. This exposes the same lever locally.

## Scope

- **In:** `run-tests.sh` argument parsing (a new `-k`/`--filter` flag + `-h` usage),
  threading the filter into both eval stages, and a one-line note in the usage header.
- **Out of scope:** changing the no-argument behaviour (still runs everything); the
  config tier (still the full, model-graded configs — no separate "core vs full"
  switch); skipping the lint or Ollama-lifecycle stages.
- **Behaviour:** the pattern is a regex matched against the case description
  (e.g. `persona-persistence` matches EN+PL; `en-grief$` matches only `en-grief`). A
  language whose cases don't match runs zero cases and passes (promptfoo exits 0).
