## Why

Auto-merge only waits for status checks marked **required** in branch protection. The
`skill-ci.yml` jobs (`gate`, `lint`, `core-slm-smoke`, `aggregate-eval-comment`) only run
when a PR touches `skills/**`, `promptfoo/**`, `tools/**`, `.claude-plugin/**`,
`run-tests.sh`, or the workflow file itself, via a workflow-level `paths:` filter. When a
PR doesn't touch those paths, GitHub never runs the workflow, so a required check derived
from it never reports and sits in `Pending` forever — wedging the PR. Today that means
auto-merge cannot safely gate on the fast eval/lint suite: making the existing checks
required would break every doc-only or infra-only PR (GitHub issue #73).

## What Changes

- Replace `skill-ci.yml`'s workflow-level `paths:` trigger filter with an always-on
  trigger plus job-level path detection (`dorny/paths-filter`), so the workflow always
  starts and its jobs always report a terminal status (success/neutral) — never silently
  skipped-pending.
- When the changed paths don't match the skill/eval/tooling globs, the `gate`, `lint`,
  `core-slm-smoke`, and `aggregate-eval-comment` jobs report success without running the
  approval gate, lint, or evals (no wasted CI minutes, no wedging on unrelated PRs).
- Add `lint` and `core-slm-smoke` (both matrix legs, non-canary) as **required status
  checks** on the `main` branch protection, via the existing OpenTofu `github-repo`
  module (`infra/modules/github-repo/main.tf`) so the requirement is version-controlled
  alongside the rest of the GitHub-config-as-code, consistent with the `ci-infrastructure`
  capability.
- Canary matrix legs (e.g. `pl-canary-bielik7b`) stay non-required — they're already
  `continue-on-error` and must not block merges.

## Capabilities

### New Capabilities

(none)

### Modified Capabilities

- `ci-infrastructure`: the "Fast eval gate on every pull request" requirement gains a
  constraint that the gate's jobs must always report a terminal status context (so they
  are safe to mark required), and the "GitHub configuration as code" requirement extends
  to cover required-status-check branch protection on `main`.

## Impact

- `.github/workflows/skill-ci.yml`: trigger and job conditionals change from
  workflow-level `paths:` to job-level `dorny/paths-filter` output checks.
- `infra/modules/github-repo/main.tf` (and its `variables.tf`/callers as needed): new
  `github_branch_protection` (or ruleset-based equivalent) resource requiring the `lint`
  and `core-slm-smoke` (en/pl) checks on `main`.
- No change to `skill-ci-nightly.yml` (unaffected — it's schedule-triggered, not
  path-filtered).
- Applying the branch-protection change requires a maintainer `tofu apply` (or
  equivalent manual GitHub Settings change if IaC isn't applied yet) — this proposal
  does not apply it automatically.
