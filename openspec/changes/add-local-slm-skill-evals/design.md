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

### Behavioural gate (English and Polish)

Use one model for both languages:

```text
gemma4:e4b-it-qat
```

Rationale:

- Gemma 4 E4B (effective-4B), quantization-aware-trained at Q4_0, so it keeps
  near-fp16 quality at 4-bit (~6.2 GB);
- it is the strongest instruction-follower tried and genuinely multilingual: it
  passes EN **and** PL 4/4, producing high-register in-character Polish (it
  dismisses the technical case in Polish rather than fixing the code). Smaller
  Polish models either code-switched (Bielik-4.5B) or were terse and broke
  character (PLLuM-4B); the slow 7B worked but cost 60–80 min;
- it uses a reasoning channel, so `num_predict` must be high enough (1600) for it
  to finish thinking before emitting content (see the eval runner notes).

### Compatibility canaries (Polish-native, non-blocking)

One Polish case (`pl-dialectical`, via `--only`) on each of two Polish-native
models from different families:

```text
hf.co/speakleash/Bielik-Minitron-7B-v3.0-Instruct-GGUF:Q4_K_M
hf.co/mradermacher/Llama-PLLuM-8B-instruct-2512-GGUF:Q4_K_M
```

Rationale:

- the gate model (gemma) is multilingual but not Polish-native; the canaries are
  a thin "a real Polish-native model still runs this skill" signal across the two
  main Polish model families (Bielik / Llama-PLLuM);
- they are **non-blocking** (`continue-on-error`): third-party models may drift,
  so a canary reports pass/fail but never fails the build;
- they are slow 7–8B CPU jobs, so the job keeps a 90-minute timeout and a
  40-minute (`EVAL_HTTP_TIMEOUT=2400`) per-call socket timeout. They run in
  parallel with the gates, so they do not extend wall-clock much.

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
# Behavioural gates (blocking)
- language: en
  model: gemma4:e4b-it-qat
  evals: evals/hegel_skill_cases.en.json
- language: pl
  model: gemma4:e4b-it-qat
  evals: evals/hegel_skill_cases.pl.json

# Compatibility canaries (one PL case each, non-blocking)
- language: pl-canary-bielik7b
  model: hf.co/speakleash/Bielik-Minitron-7B-v3.0-Instruct-GGUF:Q4_K_M
  evals: evals/hegel_skill_cases.pl.json
  only: pl-dialectical
  canary: true
- language: pl-canary-pllum8b
  model: hf.co/mradermacher/Llama-PLLuM-8B-instruct-2512-GGUF:Q4_K_M
  evals: evals/hegel_skill_cases.pl.json
  only: pl-dialectical
  canary: true
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
