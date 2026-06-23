## 1. IaC foundation (kept)

- [x] 1.1 Add an OpenTofu root with the `google` and `integrations/github` providers pinned.
- [x] 1.2 Configure a versioned GCS bucket as the remote state backend.
- [x] 1.3 Add tflint config and a plan-on-PR GHA workflow (auth via WIF). _(trivy/checkov: follow-up.)_

## 2. Keyless auth (WIF), scoped down

- [x] 2.1 Module `wif/`: a Workload Identity pool + provider trusting this repo's GHA OIDC.
- [x] 2.2 Scope the GHA principal's IAM to **state-bucket read/write only** (`roles/storage.objectAdmin` on `tfstate_bucket`) — removed the Cloud Run / Secret Manager / Artifact Registry grants.
- [x] 2.3 Confirm no long-lived service-account keys exist anywhere in the config.

## 3. Drop the GPU eval runner

- [x] 3.1 Delete the `cloud-run-eval/` module and its wiring from the root.
- [x] 3.2 Delete `infra/docker` (the eval-runner image + entrypoint).
- [x] 3.3 Remove Secret Manager + Artifact Registry resources/vars/outputs and trim the enabled APIs.
- [x] 3.4 `infra-plan.yml` now plans only `wif/` + `github-repo/` + the state backend (no eval-specific inputs).

## 4. GitHub config as code (kept)

- [x] 4.1 Module `github-repo/`: repo settings, branch protection, signed-commits ruleset, the `evals` environment + reviewers + prevent-self-review, labels, Actions variables. Dropped the `EVAL_JOB_NAME` variable.
- [ ] 4.2 Verify a destroy-then-reapply reproduces the live settings (drift check). _(needs apply)_

## 5. Eval split: fast PR + nightly full

- [x] 5.1 Separate the judge from the fast path. promptfoo parses YAML before templating, so asserts can't be env-toggled in one config; instead added lean `promptfooconfig.core.{en,pl}.yaml` (deterministic asserts only, no grader/embedding provider) for PRs, keeping `promptfooconfig.{en,pl}.yaml` as the full graded configs. Stripped inline model-graded asserts from the core behaviour files; retired the `similar` asserts (references kept, re-wireable).
- [x] 5.2 Reworked `skill-ci.yml`: PR run = lint + 3 core behaviours EN+PL (core configs) filtered via `--filter-pattern`, judge off; kept the `evals` gate and the sticky comment; `timeout-minutes` 90 → 30.
- [x] 5.3 Added `skill-ci-nightly.yml`: `schedule:` cron + `workflow_dispatch`, full configs (all behaviours, judge on), 330-min timeout, no gate; writes a job-summary table and opens/closes a sticky tracking issue on failure/recovery.
- [x] 5.4 Moved the 5 parked behaviours from `promptfoo/tests/_disabled/` into `promptfoo/tests/`; the PR run selects only the 3 core via `--filter-pattern` while nightly runs all 8.
- [x] 5.5 Removed `promptfoo/tests/_disabled/` and its README; updated `promptfoo/references/README.md` (similar retired/unwired).

## 6. Document & finish

- [x] 6.1 Updated `AGENTS.md` (Way of working + Tests + Infrastructure) and `CONTRIBUTING.md`: two-tier eval split (fast PR vs nightly full) and the GPU-free IaC.
- [x] 6.2 `openspec validate 2026-06-23-ci-infrastructure-as-code --strict` clean (and `--all --strict`).
- [ ] 6.3 Verify `./run-tests.sh` still green locally (full suite, all 8 behaviours). _(needs a local Ollama; configs `promptfoo validate`-clean here.)_
- [ ] 6.4 Confirm the PR fast gate is green on this PR; confirm the nightly workflow runs (schedule or `workflow_dispatch`) and reports.
