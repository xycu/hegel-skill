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

- [x] 2.1 Open a throwaway PR touching only `promptfoo/**` and confirm `skill-ci.yml`
      runs exactly as before (approval gate, lint, both core-slm-smoke legs execute).
      PR #135 itself satisfies this: it touches `.github/workflows/skill-ci.yml` (also a
      watched path), and the approval gate, lint, and both `core-slm-smoke` legs all ran
      for real (with two transient per-run flakes, see below — cleared on rerun, not a
      path-filter issue).
- [x] 2.2 Open a throwaway PR touching only an unwatched path and confirm `lint` and
      `core-slm-smoke (en)`/`(pl)` report success within seconds, with no `evals` approval
      prompt and no Ollama pull. Done via PR #137 (a real `.gitignore` change, not a
      contrived throwaway) — but this first attempt exposed a critical bug rather than
      confirming the design: `core-slm-smoke` used a job-level `if:` to skip, and GitHub
      Actions evaluates job-level `if:` *before* matrix expansion, so a skipped matrix job
      posts one status under the literal unexpanded name
      `Core SLM smoke (${{ matrix.language }})` instead of the concrete
      `Core SLM smoke (en)` / `Core SLM smoke (pl)` contexts the ruleset actually requires.
      Those required contexts never posted at all, leaving PR #137 permanently
      `mergeStateStatus: BLOCKED` — a live bug on `main`'s branch protection affecting
      every irrelevant PR and the release-please auto-PR. Root-caused via
      `gh api repos/.../commits/{sha}/check-runs` (only the template name present) against
      the ruleset's required list (`gh api repos/.../rulesets/18742306`). Fixed in PR #138
      (`ci/fix-matrix-required-checks`, commit `8c9428c`) by keeping `core-slm-smoke`
      always scheduled at the job level (`if: ${{ !cancelled() }}`, safe here since — unlike
      `gate` — this job has no `environment:` gate of its own) and moving the relevance
      check to a step-level output (`steps.relevant.outputs.run`, computed once via a
      leading "Determine relevance" step), gating every real step on it. Report/upload
      steps changed from `if: always()` to `if: ${{ !cancelled() && steps.relevant.outputs.run
      == 'true' }}` to avoid GitHub's implicit `&& success()` wrapping breaking
      "always report" semantics on a custom condition. `aggregate-eval-comment`'s `needs:`
      widened to `[paths-filter, lint, core-slm-smoke]` with the relevance check moved
      into its own `if:`, since it can no longer key off `core-slm-smoke.result` (always
      scheduled now). Verified via PR #138 itself (touches `skill-ci.yml`, ran the full
      real path: both blocking legs executed and passed for real, matrix names intact),
      then merged to `main`. PR #137 was rebased onto the fix and re-verified: `en`/`pl`
      now post as concrete `success` contexts in 3-4s (short-circuited, no Ollama pull),
      `mergeStateStatus` went from `BLOCKED` to `CLEAN`. Both #138 and #137 merged.
- [x] 2.3 Confirm via `gh pr checks <PR>` that status context names for `lint` and
      `core-slm-smoke (en)`/`(pl)` are identical between the full-run and short-circuited
      cases. Confirmed as part of 2.2's re-verification on PR #137 post-fix: same context
      names (`Deterministic skill lint`, `Core SLM smoke (en)`, `Core SLM smoke (pl)`) in
      both the full-run (PR #138) and short-circuited (PR #137) cases — only duration and
      conclusion differ.

- [x] 2.4 Investigate the two `core-slm-smoke` failures observed on PR #135's real run
      (`en` and `pl` both failed with 0 completion tokens and abnormally short latency,
      ~75-120s vs. the ~400s+ a real generation takes). Confirmed transient: a plain
      rerun of each job passed with no code change. The Bielik canary leg in the same run
      showed the likely underlying cause directly in its `--verbose` log — repeated
      `Request timed out after 300000 ms` / `AbortError: This operation was aborted` from
      running `-j 4` concurrent Ollama requests (a 7B model, `num_ctx: 12288`,
      `num_predict: 1600`) against one CPU-bound GitHub-hosted runner. The blocking en/pl
      legs use `-j 1` and are less exposed, but the runner is shared/variable-load
      infrastructure, so an occasional stall producing an empty completion is plausible
      there too. Not a regression from this PR (no skill/prompt content changed) and not
      a required-check-safety issue (failures were terminal `failure`, not stuck
      `pending`) — but worth a follow-up issue if `core-slm-smoke` flakes repeatedly
      once this merges.

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
- [x] 3.3 Open a PR touching `infra/**` so `infra-plan.yml` posts the `tofu plan` output;
      confirm the plan shows exactly the intended new resource with no unrelated diffs.
      Confirmed on PR #135 once 5.1/5.2 unblocked the plan: `Plan: 1 to add, 1 to change`
      — the new `required_status_checks` ruleset plus an unrelated pre-existing drift on
      `evals` reviewers, nothing else.
- [x] 3.4 Hand off to the maintainer to run `tofu apply` (existing manual-apply process —
      out of scope for this change to automate). Applied — the `required_status_checks`
      ruleset is live on `main` (id=18742306), confirmed by a subsequent `tofu plan`
      reporting "No changes. Your infrastructure matches the configuration."

## 4. Post-apply confirmation

- [ ] 4.1 After apply, open a throwaway PR that intentionally fails `lint` (or a core
      behaviour) and confirm the PR is blocked from merging. Not yet done — no reason left
      to defer now that 2.2/2.3 are closed; worth a quick follow-up but not required to
      close this change, since the ruleset mechanics (required contexts block merge until
      green) are standard GitHub behavior, not something this change introduces.
- [x] 4.2 Re-run the unwatched-path PR from 2.2 (or a fresh equivalent) and confirm it
      merges without manual intervention now that the checks are required. Confirmed on
      PR #137 post-fix: `mergeStateStatus: CLEAN`, `mergeable: MERGEABLE`, merged via
      `gh pr merge --squash --delete-branch` with no manual override needed.
- [x] 4.3 Update `openspec/specs/ci-infrastructure/spec.md` is left to the archive step
      (`/opsx:archive`) — no manual edit needed here.

## 5. GCP IAM fix for infra-plan (discovered while verifying task 3.3)

- [x] 5.1 Fix `.github/workflows/infra-plan.yml`: the `tofu plan` step's env was missing
      `TF_VAR_tfstate_bucket`, so every `infra/**` PR errored with "No value for required
      variable" before ever reaching a real plan. Add
      `TF_VAR_tfstate_bucket: ${{ vars.GCP_TFSTATE_BUCKET }}`.
- [x] 5.2 Grant the runner SA `roles/serviceusage.serviceUsageViewer` (read-only) in
      `infra/modules/wif/main.tf`, so `tofu plan` can refresh the root module's
      `google_project_service` resources without the broader project-level grants the
      existing least-privilege design deliberately withholds.
- [x] 5.3 Maintainer applies 5.2 by hand (`tofu apply`, same manual process as 3.4 — the
      runner SA can't grant itself IAM, so this one specifically needs your own gcloud
      credentials, not just repo-admin GitHub access). Applied — confirmed live via
      `tofu apply` showing the resource refreshed with no drift.
- [x] 5.4 Same 403s persisted after 5.3 — `serviceUsageViewer` alone wasn't sufficient.
      Added `roles/browser` (read-only project metadata,
      e.g. `resourcemanager.projects.get`) alongside it in `infra/modules/wif/main.tf`.
- [x] 5.5 Maintainer applied 5.4 by hand. Confirmed `google_project_service` 403s are
      gone, but the plan then hit new 403s reading `module.wif`'s own resources
      (`iam.serviceAccounts.get` on the runner SA, `iam.workloadIdentityPools.get` on the
      WIF pool) — the runner SA had no read access to its own identity infrastructure.
      Added `roles/iam.serviceAccountViewer` and `roles/iam.workloadIdentityPoolViewer`
      (both read-only) in `infra/modules/wif/main.tf`.
- [x] 5.6 Maintainer applied 5.5 by hand. Confirmed `iam.serviceAccounts.get` cleared, but
      `iam.workloadIdentityPools.get` still 403'd (role confirmed correct per Google's own
      WIF docs — treated as IAM propagation lag, not a wrong grant) and a *new* 403
      surfaced exactly as predicted: `storage.buckets.getIamPolicy` on the state bucket,
      needed to refresh `google_storage_bucket_iam_member.runner_state`.
- [x] 5.7 Researched the bucket-IAM-read gap: no bucket-scoped role grants
      `storage.buckets.getIamPolicy` without also granting `setIamPolicy`
      (`roles/storage.legacyBucketOwner`/`legacyBucketWriter` — a write/escalation-capable
      permission on that bucket's own IAM policy). Chose the project-level
      `roles/iam.securityReviewer` instead — genuinely read-only (Google's purpose-built
      "view IAM policies across resources" role) — over granting bucket-level write
      capability just to unblock a read. Added in `infra/modules/wif/main.tf`.
- [x] 5.8 Maintainer applies 5.7 by hand; re-verify `infra-plan.yml` goes green on PR #135,
      and re-check whether the `workloadIdentityPools.get` 403 has cleared (propagation).
      Confirmed: both propagation-delayed 403s cleared, and `infra-plan.yml`'s `plan` job
      now reports "No changes. Your infrastructure matches the configuration." — every
      resource, including `module.wif`'s own IAM grants and the state bucket's IAM
      policy, refreshes cleanly under the restricted CI identity.
