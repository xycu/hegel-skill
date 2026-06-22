## 1. References + asserts

- [x] 1.1 Curate reference answers for a few representative behaviours (EN + PL) —
      `promptfoo/references/{dialectical,grief}.{en,pl}.md` (+ README).
- [x] 1.2 Add `similar` assertions against them using the #30 embedding provider
      (`ollama:embeddings:nomic-embed-text`, wired via `options.provider.embedding`).

## 2. Gating + verify

- [x] 2.1 Advisory (weight 0) first; loose threshold; embedding pull added to CI and
      `run-tests.sh`. Promote to thresholded per #30's policy later.
- [x] 2.2 `openspec validate add-embedding-similarity-asserts --strict` clean; YAML +
      `bash -n run-tests.sh` pass. (No local Ollama in this env; CI runs the live eval.)
