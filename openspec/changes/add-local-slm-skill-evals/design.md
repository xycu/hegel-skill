# Design: Local SLM Skill Evaluation

## Overview

The evaluation system has two layers:

1. deterministic linting;
2. model-based smoke testing.

The deterministic layer checks package structure and static content. The model-based layer checks behavioural contracts using small local models.

The design intentionally avoids exact string matching against full generated answers. AI outputs are non-deterministic, especially across model versions and quantisations. Instead, each eval case defines:

- prompt;
- required terms where all must appear;
- required terms where at least one must appear;
- forbidden terms.

## Architecture

```text
GitHub Actions
  |
  +-- lint job
  |     |
  |     +-- python tools/skill_lint.py
  |
  +-- local-slm-smoke job
        |
        +-- install Ollama
        +-- start Ollama server
        +-- pull matrix model
        +-- python tools/run_skill_evals.py --model <model> --evals <eval-file>
```

## Model strategy

### English

Use:

```text
gemma4:e4b-it-qat
```

Rationale:

- Gemma 4 E4B (effective-4B), quantization-aware-trained at Q4_0, so it keeps
  near-fp16 quality at 4-bit;
- ~6.2 GB to load — smaller than the `e2b` fp16 build yet more capable, and
  4-bit speeds up CPU inference on the standard runner (4 vCPU / 16 GB RAM);
- earlier tiny models (`gemma3:1b`, `gemma4:e2b`) returned near-empty output;
  the smoke job allows 45 minutes for CPU inference at this size.

### Polish

Use:

```text
hf.co/speakleash/Bielik-Minitron-7B-v3.0-Instruct-GGUF:Q4_K_M
```

Rationale:

- Bielik is Polish-native; the 7B Minitron build produces noticeably cleaner
  Polish than the 4.5B, which code-switched into broken German/English on the
  harder cases;
- the trade-off is speed: 7B CPU inference is slow, so the job runs with a
  90-minute timeout and a 40-minute (`EVAL_HTTP_TIMEOUT=2400`) per-call socket
  timeout; quality is preferred over wall-clock here;
- a capable Polish model is required because the persona must answer in the
  language of the question (see the language rule in `SKILL.md`).

## Eval file format

Each eval case uses this schema:

```json
{
  "id": "case-id",
  "prompt": "User prompt passed to the model",
  "must_include_any": ["term1", "term2"],
  "must_include_all": ["term3"],
  "must_not_include": ["forbidden1", "forbidden2"]
}
```

## Prompt construction

The eval runner loads:

- `skills/soused-hegelian/SKILL.md`;
- `skills/soused-hegelian/references/hegel-reference.md`.

It injects both into the system prompt and then sends the eval case prompt as the user message.

For non-English eval files the runner appends a short output-language directive
after the skill content (which ends in English worked examples). A small local
proxy model otherwise mirrors those English examples and answers in English — or,
given an English "write in Polish" instruction, drifts to a third language. The
directive is therefore written *in the target language itself*, at maximum
recency, which reliably primes the model to continue in it. It names no marker
terms, so it does not feed the assertions their answers.

This does not perfectly replicate Claude Code skill activation. It deliberately tests whether the skill instructions themselves are coherent and executable by a local model.

## Deterministic linting

The lint script validates:

- `.claude-plugin/plugin.json` is valid JSON;
- `.claude-plugin/marketplace.json` is valid JSON;
- `skills/soused-hegelian/SKILL.md` exists;
- `skills/soused-hegelian/references/hegel-reference.md` exists;
- `SKILL.md` starts with standalone YAML frontmatter delimiters;
- frontmatter contains `name`;
- frontmatter contains `description`;
- description contains key trigger terms;
- body contains required behavioural terms.

## CI behaviour

The workflow runs on:

- push to `main`;
- pull request;
- manual dispatch.

The model smoke job uses a matrix:

```yaml
- language: en
  model: gemma4:e4b-it-qat
  evals: evals/hegel_skill_cases.en.json

- language: pl
  model: hf.co/speakleash/Bielik-Minitron-7B-v3.0-Instruct-GGUF:Q4_K_M
  evals: evals/hegel_skill_cases.pl.json
```

## Failure policy

A failed deterministic lint check blocks the change.

A failed smoke eval also blocks the change, but assertions must remain conservative. The purpose is to catch regression, not to grade literary quality.

## Non-goals

The system will not:

- call hosted LLM APIs;
- require paid tokens;
- require GPUs;
- compare full generated output to golden files;
- determine whether the output is aesthetically excellent;
- guarantee identical behaviour in Claude Code.
