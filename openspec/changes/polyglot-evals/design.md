## Context

The persona spec mandates answering in the language of the question; the eval
stack guards it only for EN and PL. The suites run against one local Ollama
model (`gemma4:e4b-it-qat`) both locally and in CI, with a hard-learned
operational rule: language suites run sequentially, never concurrently — a
shared local model produces flaky keyword failures under concurrency. New or
changed cases must go green locally before push (local-first gate). CI runs a
fast core subset on PRs and the full graded suite nightly.

## Goals / Non-Goals

**Goals:**
- DE and LA as gating, core-parity suites (must-haves).
- Cheap, repeatable light coverage for further languages.
- Runner and CI reflect the new stages without changing the gating philosophy.
- The README finally sells the polyglot behaviour.

**Non-Goals:**
- No robustness variants or full eight-behaviour coverage for DE/LA — that tier
  stays EN/PL-only for cost; DE/LA carry the four core behaviours.
- No per-language models: one configured model serves all languages.
- No persona prose changes — the skill already speaks every language; this
  change only guards it.

## Decisions

- **Rigor tiers.** Tier 1 (EN, PL): full suites, eight behaviours plus
  robustness variants — unchanged. Tier 2 (DE, LA): four core behaviours
  (explicit persona, dialectical, technical dismissal, grief), gating. Tier 3
  (FR, ES, IT, and any future language): one answer-in-language case each,
  gating but minimal. Rationale: the user-facing promise is "he answers in your
  language"; Tier 3 guards exactly that promise at near-zero cost, Tier 2 adds
  behavioural depth where the languages matter most to the persona.
- **File and config naming follows the existing pattern.**
  `tests/<behaviour>.de.yaml`, `tests/<behaviour>.la.yaml`,
  `promptfooconfig{,.core}.{de,la}.yaml`; the light set as
  `tests/answer-in-language.multi.yaml` with `promptfooconfig.multi.yaml`
  (one config, since the cases share one stage).
- **Sequential stages everywhere.** `run-tests.sh` order: lint → EN → PL → DE →
  LA → multi. CI keeps one matrix entry per language config so entries stay
  independently reportable; each entry pulls the model and runs alone.
- **Same model for all languages, keyword lists tuned to it.** The small
  model's German is serviceable; its Latin is the risk. The local-first gate is
  the mechanism: keyword lists are chosen from what the model actually
  produces. If Latin proves flaky after honest tuning, the Latin lists may be
  loosened (broader `icontains-any` alternates) but the suite stays gating —
  must-have per the change's mandate; "advisory Latin" is explicitly rejected.
- **Rubrics stay in the grader's language policy.** Any `llm-rubric` added for
  DE/LA writes the rubric instruction in English over the foreign-language
  output (graders follow English instructions more reliably); rubrics remain
  advisory per the existing gating policy.
- **PR fast gate uses DE/LA core configs; nightly runs the full sets.** This
  mirrors how EN/PL already split, keeping PR wall-clock growth bounded (four
  cases per new language on PRs).

## Risks / Trade-offs

- [The small model can't produce assertable Latin] → tune keyword lists
  local-first from observed outputs; loosen lists before ever considering
  dropping the gate; escalate to the user if Latin is genuinely unassertable.
- [CI eval wall-clock grows with three new matrix entries] → core subsets on
  PRs (4 cases per language), full sets nightly; model pull is cached per the
  existing workflow arrangement.
- [Language detection by keyword is crude for Tier 3] → each light case pairs
  an in-language required-any list with a forbidden list of English filler; it
  guards the promise, not literary quality — that bound is stated in the spec.
- [Grief prompts in DE/LA hit the deny-list plain-answer path, not the persona]
  → mirror the EN/PL grief cases' shape (they assert non-technical, humane
  handling rather than persona markers), keeping behaviour-equivalence.

## Open Questions

- Whether the multilingual light stage joins the PR fast gate or runs nightly
  only — default plan: PR (it is tiny); revisit if PR wall-clock becomes a
  complaint.
