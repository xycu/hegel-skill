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
gemma4:e2b
```

Rationale:

- ~7.2 GB to load; fits the standard public-repo runner (4 vCPU / 16 GB RAM,
  CPU-only) with room to spare;
- follows the long persona system prompt far better than `gemma3:1b`, which
  returned near-empty output and ignored the persona entirely in the first CI run;
- CPU inference is slow at this size, so the smoke job allows 45 minutes.

### Polish

Use:

```text
SpeakLeash/bielik-1.5b-v3.0-instruct:Q8_0
```

Rationale:

- small enough to be practical in CI;
- Polish-oriented;
- adequate for detecting basic Polish-language regressions.

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
  model: gemma3:1b
  evals: evals/hegel_skill_cases.en.json

- language: pl
  model: SpeakLeash/bielik-1.5b-v3.0-instruct:Q8_0
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
