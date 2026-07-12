## Why

The skill mandates answering in the language of the question, but only EN and PL
are evaluated — the polyglot promise is unguarded — and the README never
advertises it. German is Hegel's own tongue and Latin exercises the persona's
scholarly register; both are must-haves. Coverage should also extend, more
lightly, beyond them.

## What Changes

- **German eval suite (must-have, gating):** promptfoo cases at core parity with
  EN/PL — explicit persona/activation, dialectical engine, technical dismissal,
  grief — with German keyword lists using the native terms of art (*Geist*,
  *Aufhebung* at home in their own language).
- **Latin eval suite (must-have, gating):** the same core-parity shape, with
  keyword lists in established Latin philosophical vocabulary.
- **Light multilingual smoke coverage:** for additional languages (at least
  French, Spanish, Italian), one case per language asserting the reply is in the
  question's language and carries an in-language persona marker — deliberately
  lighter rigor than the core suites.
- **Runner:** `run-tests.sh` gains DE, LA, and multilingual stages, run
  sequentially after EN and PL (one local model; concurrent suites are flaky).
- **CI:** the skill workflow's eval matrix gains `de`, `la`, and `multi`
  entries; the PR fast gate uses core subsets, the nightly runs the full sets.
- **README:** advertise the polyglot behaviour and the rigor tiers.

## Capabilities

### New Capabilities

(none)

### Modified Capabilities
- `skill-evaluation`: gains German smoke tests, Latin smoke tests, light
  multilingual smoke coverage, and polyglot documentation as ADDED requirements.
- `local-test-runner`: the single-command runner and its CI-mirroring
  requirement change from "EN and PL" to the full sequential language stage
  list.

## Impact

- `promptfoo/`: new `tests/*.de.yaml`, `tests/*.la.yaml`, a multilingual smoke
  test file, and the corresponding full + core promptfoo configs.
- `run-tests.sh`: new sequential stages and updated usage docs.
- `.github/workflows/` skill CI: extended language matrix; required checks
  unchanged in name, longer in wall-clock.
- `README.md`: polyglot section.
- All new cases tuned local-first against the Ollama model before push, per the
  existing local-first eval gate; suites always run sequentially.
