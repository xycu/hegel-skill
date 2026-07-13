## Context

`release-pipeline` already mandates signed, verified commits and tags "without a bypass,"
but never constrained the *identity* the automation runs as. GitHub web-flow-signs commits
created through its API only for the Actions `GITHUB_TOKEN` and **GitHub App** installation
tokens; a **classic PAT's** API commits are attributed to the user and are unsigned. #66/#148
moved release-please onto the `GH_ADMIN_TOKEN` classic PAT (to make the release PR's check
workflows trigger, which `GITHUB_TOKEN`-authored events do not), unknowingly trading away the
signing guarantee. The break surfaced at v1.11.0 and was shipped only via a temporary admin
bypass on the `require-signed-commits` ruleset. PR #162 (merged) already switched the workflow
to a GitHub App token; this change ratifies that in the spec and closes the loop.

## Goals / Non-Goals

**Goals:**
- Make the signing guarantee robust by pinning the automation identity in the spec, so a
  future switch back to an unsigned-commit identity (e.g. a classic PAT) is a spec violation
  caught in review, not a silent regression.
- Keep both properties #66 cared about: signed commits **and** triggered PR check workflows —
  a GitHub App token delivers both.
- Restore the "no bypass" steady state by removing the stopgap ruleset bypass.

**Non-Goals:**
- Changing versioning, drift-guard, or marketplace-detection requirements.
- Retiring `GH_ADMIN_TOKEN` — it remains the Terraform github-provider token in
  `infra-plan.yml`, which needs repo Administration that the release App does not have.
- Persona, skill, or eval behaviour.

## Decisions

- **Pin identity by capability, not by exact token name.** The requirement names the allowed
  *kinds* (Actions `GITHUB_TOKEN` or a GitHub App installation token) and forbids classic
  PATs, rather than hard-coding `RELEASE_APP_ID`. Rationale: the invariant is "API commits are
  web-flow-signed," which is a property of the identity kind; the exact secret is an
  implementation detail recorded in the workflow.
- **GitHub App over reverting to `GITHUB_TOKEN`.** Reverting would restore signing but reland
  the #66 problem (release-PR checks park as `action_required`). The App token is the only
  option satisfying both, so it is the chosen mechanism.
- **Bypass removal is gated, not immediate.** Removing the `require-signed-commits` admin
  bypass before an App-authored release is proven `Verified` would re-block the next release.
  The task is therefore ordered after a verification step (inspect a real App-authored release
  commit's `verification.verified == true`).
- **Correct the narrative in place.** The false "signs regardless of token" claim lives in the
  `release.yml` header comment and `AGENTS.md`; both are fixed so the documented rationale
  matches reality.

## Risks / Trade-offs

- [The proving release is deferred] The signed-commit proof only lands on the next
  releasable (`fix:`/`feat:`) merge, since a `ci:`/`docs:` change is not user-facing and
  release-please creates no commit → keep the bypass until then.
- [App credential lifecycle] A GitHub App private key can expire or be rotated; if the token
  step fails the release simply does not run (fails loudly), which is safer than silently
  producing unsigned commits. Documented in the workflow comment.
- [Two-identity split] Keeping `GH_ADMIN_TOKEN` for Terraform while the App handles releases
  means two credentials to maintain; accepted because their permission needs differ
  (Administration vs Contents/PRs) and over-scoping the release App would weaken least-privilege.
