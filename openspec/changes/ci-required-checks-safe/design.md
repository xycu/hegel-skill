## Context

`skill-ci.yml` gates on a workflow-level `pull_request.paths:` filter (`&skill_paths`
anchor, lines 10-16 of `.github/workflows/skill-ci.yml`). When a PR's changed files don't
match, GitHub Actions never starts the workflow at all — there is no run, no job, no
status context. A branch-protection required check is matched by context name; if that
context never posts, GitHub treats the requirement as perpetually unsatisfied and the PR
can't merge (surfaced as an eternal "Expected — Waiting for status" in the merge box).

The repo already manages GitHub configuration as code via OpenTofu
(`infra/modules/github-repo/main.tf`, the `github` provider, applied manually by the
maintainer through `infra-plan.yml`'s plan-then-hand-apply flow — see the
`ci-infrastructure` spec's "GitHub configuration as code" requirement). Branch protection
itself is not yet defined there; today `main` has no required status checks at all
(confirmed in issue #73's problem statement). This change is additive to that module and
does not touch the WIF/GCP side.

## Goals / Non-Goals

**Goals:**
- Every `skill-ci.yml` job that could plausibly be required always reports a terminal
  GitHub status context (`success`/`failure`/`neutral`), regardless of which files a PR
  touches.
- PRs that don't touch skill/eval/tooling paths merge exactly as fast as they do today
  (job runs, does real work only when needed, otherwise exits immediately).
- `lint` and the two blocking `core-slm-smoke` matrix legs (`en`, `pl`) become required
  status checks on `main`, version-controlled in the existing Terraform/OpenTofu module.

**Non-Goals:**
- Changing the eval gating *policy* (which behaviours run, advisory vs. blocking split,
  canary handling) — that's #30/#37 territory, referenced but not touched here.
- Migrating `infra-plan.yml`'s manual-apply model to auto-apply. The branch-protection
  resource still goes through the existing plan-on-PR / maintainer-apply flow.
- Building the GPU Cloud Run eval runner from #79 — unrelated and still blocked.

## Decisions

**1. Job-level `dorny/paths-filter` instead of dropping the path filter entirely.**
Removing `paths:` and always running the full job (lint + Ollama pull + eval) on every PR
would work for "always reports a status" but burns CI minutes and the manual `evals`
approval gate on every doc-only PR — a regression from today. `dorny/paths-filter` runs
as the first step of each job (before `gate`, cheaply, without checking out heavy
dependencies), exposes a boolean output, and every downstream step is conditioned on it.
Alternative considered: keep `workflow_dispatch`-style manual bypass — rejected, doesn't
solve the "PR that never touches these paths" case, which is the common one.

**2. Filter check runs *before* the `gate` approval step, not after — and `gate` itself is
job-level skipped when irrelevant, not merely step-gated.**
`gate` uses the `evals` environment (manual reviewer approval); environment protection
rules are evaluated the moment a job is scheduled, before any of its steps run, so a
step-level `if:` inside `gate` cannot prevent the approval prompt. The only way to avoid
forcing a maintainer to click approve on an unrelated PR is to skip the `gate` job itself
via a job-level `if:` keyed off `paths-filter`'s output. `lint` and `core-slm-smoke` are
also skipped at the job level when irrelevant (see Decision 4 for why this is safe for
required checks) — `paths-filter` runs first, ungated, and every downstream job's `if:`
reads its output directly.

**3. Required checks land in `infra/modules/github-repo/main.tf`, not clicked by hand.**
Consistent with the "GitHub configuration as code" requirement already in the
`ci-infrastructure` spec — every other backed-up setting (ruleset, `evals` environment,
labels, Actions variables) lives in this module. A `github_branch_protection` resource
(or `github_repository_ruleset` with a `required_status_checks` rule, matching the style
already used for `signed_commits`) is added here, naming exactly the status contexts that
`lint` and `core-slm-smoke (en)` / `core-slm-smoke (pl)` report. Canary legs and
`aggregate-eval-comment` are excluded (canary is explicitly non-blocking;
`aggregate-eval-comment` is a reporting step, not a gate).
Alternative considered: apply branch protection by hand once via the GitHub UI —
rejected, it's exactly the kind of hand-applied, driftable change the existing IaC
requirement was written to prevent.

**4. Job-level `if:` skipping is safe for required checks — GitHub treats a skipped job as
a satisfied required check, not a stuck-pending one.**
This is the standard, documented `dorny/paths-filter` pattern: a job skipped by its own
`if:` still posts a check run under its job name with conclusion `skipped`, and GitHub's
branch protection treats `skipped` as satisfying a required status check (it is not
`pending`). So `lint` and `core-slm-smoke (en)`/`(pl)` can be conditioned with a plain
job-level `if: needs.paths-filter.outputs.skill-relevant == 'true' && ...` — no need for
per-step conditioning or a synthetic "report success" step, as long as the job *name*
stays identical between the real-run and skipped cases (same job id, no matrix identity
change). This also fixes the release-please PR case for free: those PRs already skip
`lint`/`core-slm-smoke` via the existing `head_ref` check, and once those checks are
required, that job-level skip must resolve as passing — which it does under this
semantics, so release-please PRs keep merging without a special case (relevant to #66).

## Risks / Trade-offs

- **[Risk]** A future path added to `skills/**` etc. that should trigger CI but is missed
  in `dorny/paths-filter`'s filter list → jobs short-circuit to success on a PR that
  actually needed the gate. **Mitigation**: reuse the exact same glob list already in the
  `&skill_paths` YAML anchor, so there is one source of truth instead of two path lists
  drifting apart.
- **[Risk]** Marking `core-slm-smoke (en)`/`(pl)` required before the filter logic is
  fully verified in production could wedge real PRs the same way the unfixed version
  would. **Mitigation**: land and verify the paths-filter behavior (Task 1) on a few real
  PRs — including one that touches no watched path — before adding the branch-protection
  requirement (Task 2), and confirm via the `gh pr checks` output rather than assuming.
- **[Risk]** `terraform plan`/`tofu plan` on `infra-plan.yml` only runs on PRs touching
  `infra/**` — the branch-protection change will show a plan there, but the **apply** is
  still a manual maintainer step; this proposal's acceptance criteria only cover "plan is
  correct," not "protection is live," unless the maintainer applies it.
- **[Trade-off]** Adding a `paths-filter` job in front of `gate` adds one more job hop
  (a few seconds) to every PR's critical path, even fully-filtered ones. Accepted — it's
  far cheaper than the alternative of always running the full eval suite.

## Migration Plan

1. Add `dorny/paths-filter` as a new first job in `skill-ci.yml` (no checkout needed — it
   can read the PR's changed files via the GitHub API); wire its output into `gate`,
   `lint`, `core-slm-smoke`, and `aggregate-eval-comment` via job-level `if:` conditions,
   replacing the workflow-level `on.pull_request.paths:` block with a plain
   `pull_request:` trigger (no `paths:`).
   - When unmatched: `gate`, `lint`, and `core-slm-smoke` are skipped outright (job-level
     `if:` false) — which posts a `skipped` check under the same job name, satisfying a
     required check without running any real work or prompting for approval.
2. Verify on a handful of real PRs: one touching `promptfoo/**` (full run, same as
   today), one touching only e.g. `README.md` (all jobs report success quickly, no
   `evals` approval prompt, no Ollama pull).
3. Add the `github_branch_protection` resource to `infra/modules/github-repo/main.tf`
   naming the `lint` and `core-slm-smoke (en)`/`(pl)` contexts; open a PR so
   `infra-plan.yml` posts the plan.
4. Maintainer reviews the plan and runs `tofu apply` by hand (existing process — this
   change does not add auto-apply).
5. Confirm a live PR now genuinely blocks merge on a failing `lint`/`core-slm-smoke`, and
   that an unrelated PR still merges without manual intervention.

No rollback complexity beyond normal git revert + a follow-up `tofu apply` to drop the
branch-protection resource, since nothing here is stateful beyond GitHub config.

## Open Questions

- `github_branch_protection` (classic) vs. a `github_repository_ruleset` with a
  `required_status_checks` rule (matching the newer resource already used for
  `signed_commits`) — functionally similar; default to the ruleset form for consistency
  with the existing `signed_commits` resource unless the provider version pinned in
  `infra/versions.tf` lacks ruleset status-check support, in which case fall back to
  `github_branch_protection`. Resolve during implementation (Task 2) by checking the
  provider version.
