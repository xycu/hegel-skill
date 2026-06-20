# Change: Add Local SLM Skill Evaluation in CI

## Summary

Add automated validation for the `soused-hegelian` AI skill using a two-layer test strategy:

1. deterministic linting for skill package correctness;
2. local SLM smoke evaluations for English and Polish behavioural regressions.

The CI workflow will use small local models via Ollama:

- `gemma3:1b` for English smoke tests;
- `SpeakLeash/bielik-1.5b-v3.0-instruct:Q8_0` for Polish smoke tests.

## Motivation

The skill is primarily behavioural and stylistic, so normal unit tests are insufficient. However, relying only on manual Claude Code testing makes regressions easy to miss.

This change introduces a lightweight, repeatable CI safety net that verifies:

- the skill package is structurally valid;
- `SKILL.md` contains valid frontmatter;
- required reference files are present;
- the skill responds in the expected persona;
- outputs remain Hegelian/dialectical;
- Polish and English prompts are both covered;
- technical prompts are redirected or dismissed in character;
- the expected `slop:` footer is preserved.

The local SLM tests are not intended to prove literary quality. They are intended to catch obvious regressions.

## Scope

### In scope

- Add deterministic Python lint script.
- Add local SLM eval runner.
- Add English eval cases.
- Add Polish eval cases.
- Add GitHub Actions workflow.
- Use Ollama to run small local models in CI.
- Keep evals contract-based rather than exact-output-based.

### Out of scope

- Full semantic grading by a large frontier model.
- Exact simulation of Claude Code skill triggering.
- Human literary review of the Brandt persona.
- Publishing or marketplace release automation.
- Running large models on every pull request.
- Cloud-hosted model API usage.

## Proposed implementation

Add the following files:

```text
tools/
  skill_lint.py
  run_skill_evals.py

evals/
  hegel_skill_cases.en.json
  hegel_skill_cases.pl.json

.github/
  workflows/
    skill-ci.yml
```

The CI pipeline will have two jobs:

1. `lint`
   - validates JSON metadata;
   - validates `SKILL.md` frontmatter;
   - verifies expected skill files and reference files exist;
   - checks for required instruction terms.

2. `local-slm-smoke`
   - runs a matrix over English and Polish evals;
   - pulls the configured Ollama model;
   - executes prompts against the skill instructions and reference file;
   - checks required and forbidden output markers.

## Risks

### Risk: small models may fail for quality reasons unrelated to the skill

Mitigation: keep assertions shallow and contract-based. Avoid subjective grading.

### Risk: GitHub-hosted runners may be slow

Mitigation: use small models by default. Keep larger models manual or release-only.

### Risk: local SLM behaviour differs from Claude Code

Mitigation: document that local SLM smoke tests are not a replacement for manual Claude Code testing.

### Risk: evals become brittle

Mitigation: use `must_include_any`, `must_include_all`, and `must_not_include` checks rather than exact expected output.

## Success criteria

The change is successful when:

- CI fails on invalid skill frontmatter.
- CI fails when required reference files are missing.
- CI fails when the skill no longer produces the required `slop:` footer.
- CI fails when English persona prompts lose all Hegelian markers.
- CI fails when Polish persona prompts lose all Hegelian markers.
- CI fails when technical prompts are answered as normal coding help.
- CI can run without paid model APIs.
