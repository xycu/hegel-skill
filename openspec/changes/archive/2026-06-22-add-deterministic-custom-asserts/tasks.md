## 1. Custom-assert plumbing

- [x] 1.1 Add a `javascript` assert that parses the `slop: N/10` footer into a numeric metric. → `promptfoo/asserts/footer-score.js` (advisory, score 0..1).
- [x] 1.2 Add a deterministic structural assert. → `promptfoo/asserts/response-shape.js` records char/sentence counts and guards against degenerate (empty/one-line) output — no keyword matching, so it cannot flake at high temperature. (Quality-of-dialectic grading is deferred to llm-rubric #31.)

## 2. Wire + verify

- [x] 2.1 Reference both asserts from the EN/PL `defaultTest` as advisory (weight 0) metrics (`slop_score`, `response_shape`) without disturbing the existing keyword/regex asserts.
- [x] 2.2 `openspec validate add-deterministic-custom-asserts --strict` clean; JS asserts smoke-tested with node (footer parse + shape thresholds). `./run-tests.sh` model run deferred to CI (no local Ollama); asserts are deterministic and weight 0, so they cannot fail the gate.
