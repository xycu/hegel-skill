# Reference answers (#32)

Curated, in-character "known-good" Brandt answers. One file per behaviour per language:
`<behaviour>.<lang>.md`.

> **Note (currently unwired).** These fed the `similar` embedding-similarity asserts
> (#32). Those asserts were **retired** when the eval suite split into a fast per-PR gate
> and a nightly full run: `similar` ran inline in the core behaviour files, which made it
> impossible to keep the PR run model-graded-free, and the three generic `llm-rubric`
> grades (voice / dialectic / citation) already cover semantic quality on the nightly run.
> The files are kept as curated exemplars and are trivial to re-wire (add a `similar`
> assert pointing at `file://promptfoo/references/<behaviour>.<lang>.md` plus an Ollama
> `embedding` provider) should embedding-similarity grading be wanted again.
