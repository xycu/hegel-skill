# Reference answers (#32)

Curated, in-character "known-good" Brandt answers used by `similar`
(embedding-similarity) assertions. A response is compared to the reference for its
behaviour; large semantic drift away from the reference register is what these catch —
something neither keyword lists nor the llm-rubric capture directly.

- Embeddings are computed by the local Ollama provider chosen in #30
  (`ollama:embeddings:nomic-embed-text` by default; override with `EMBED_MODEL`).
- Asserts are **advisory (weight 0)** with a deliberately loose threshold, so they record
  a `similarity_*` metric without failing a case — promotable to thresholded per the #30
  gating policy.

One file per behaviour per language: `<behaviour>.<lang>.md`.
