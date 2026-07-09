## 1. Job-level path detection in Skill CI

- [x] 1.1 Add a `paths-filter` job to `.github/workflows/skill-ci.yml` using
      `dorny/paths-filter` (no checkout needed), with a `skill` filter listing the same
      globs currently in the `&skill_paths` anchor, and expose it as a boolean
      `skill-relevant` output.
- [x] 1.2 Replace `on.pull_request.paths:` in `skill-ci.yml` with a plain `pull_request:`
      trigger (no `paths:`), so the workflow always starts.
- [x] 1.3 Add `needs.paths-filter.outputs.skill-relevant == 'true'` to the job-level `if:`
      of `gate`, `lint`, and `core-slm-smoke` (alongside the existing release-please
      check), and explicitly gate each on its predecessor's success
      (`needs.gate.result == 'success'` for `lint`, `needs.lint.result == 'success'` for
      `core-slm-smoke`) so a skipped/failed upstream job doesn't let a downstream job run
      anyway. Keep job names unchanged — a job-level skip still posts a `skipped` check
      under the same name, which satisfies a required check.
- [x] 1.4 Also skip `aggregate-eval-comment` when `core-slm-smoke` was skipped (irrelevant
      PR), so it doesn't post a "no eval summaries" fallback comment on every unrelated PR.

## 2. Verification of path-gated behavior

- [ ] 2.1 Open a throwaway PR touching only `promptfoo/**` and confirm `skill-ci.yml`
      runs exactly as before (approval gate, lint, both core-slm-smoke legs execute).
- [ ] 2.2 Open a throwaway PR touching only an unwatched path (e.g. a `README.md` typo
      fix) and confirm `lint` and `core-slm-smoke (en)`/`(pl)` report success within
      seconds, with no `evals` approval prompt and no Ollama pull.
- [ ] 2.3 Confirm via `gh pr checks <PR>` that status context names for `lint` and
      `core-slm-smoke (en)`/`(pl)` are identical between the full-run and short-circuited
      cases.

## 3. Required status checks as code

- [x] 3.1 Decide `github_repository_ruleset` (matching the existing `signed_commits`
      resource style) vs. `github_branch_protection`, based on what the pinned GitHub
      provider version in `infra/versions.tf` supports for required status checks.
      Decision: `github_repository_ruleset` with a `required_status_checks` rule —
      provider `integrations/github ~> 6.0` supports it, and it matches the
      `signed_commits` resource already in this module.
- [x] 3.2 Add the chosen resource to `infra/modules/github-repo/main.tf`, requiring the
      `lint` and `core-slm-smoke (en)` / `core-slm-smoke (pl)` status contexts on `main`.
      Do not include canary legs or `aggregate-eval-comment`. (Contexts used are the job
      *names* — `Deterministic skill lint`, `Core SLM smoke (en)`, `Core SLM smoke (pl)`
      — since that's what GitHub matches status checks on.)
- [ ] 3.3 Open a PR touching `infra/**` so `infra-plan.yml` posts the `tofu plan` output;
      confirm the plan shows exactly the intended new resource with no unrelated diffs.
- [ ] 3.4 Hand off to the maintainer to run `tofu apply` (existing manual-apply process —
      out of scope for this change to automate).

## 4. Post-apply confirmation

- [ ] 4.1 After apply, open a throwaway PR that intentionally fails `lint` (or a core
      behaviour) and confirm the PR is blocked from merging.
- [ ] 4.2 Re-run the unwatched-path PR from 2.2 (or a fresh equivalent) and confirm it
      merges without manual intervention now that the checks are required.
- [ ] 4.3 Update `openspec/specs/ci-infrastructure/spec.md` is left to the archive step
      (`/opsx:archive`) — no manual edit needed here.
