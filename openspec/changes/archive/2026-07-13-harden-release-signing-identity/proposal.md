## Why

The `release-pipeline` spec already requires that "every commit and tag the automation
creates SHALL be cryptographically signed and show as verified … without a bypass." A
prior change (#66/#148) switched release-please's auth to the `GH_ADMIN_TOKEN` **classic
PAT**, whose GitHub API commits are attributed to the user and land **unsigned** — silently
violating that requirement. It surfaced on the v1.11.0 release: the release commit came back
`unsigned`, the all-branches signed-commits ruleset blocked it, and shipping required adding
a temporary admin **bypass** (a second violation of the same requirement). The spec never
pinned *which identities* satisfy the signing guarantee, so nothing caught the regression.

## What Changes

- Strengthen the existing "Signed and verified release commits and tags" requirement to
  **pin the automation identity**: the release pipeline MUST authenticate as an identity
  whose GitHub API commits are web-flow-signed — the Actions `GITHUB_TOKEN` **or** a GitHub
  App installation token — and MUST NOT use a classic Personal Access Token, whose API
  commits are unsigned.
- Reflect the implemented fix (PR #162, merged): `release.yml` mints a GitHub App token via
  `actions/create-github-app-token` from `RELEASE_APP_ID` / `RELEASE_APP_PRIVATE_KEY`.
- Track removal of the temporary `require-signed-commits` admin bypass (ruleset `17943629`),
  added only to ship v1.11.0, to restore the "no bypass" guarantee — gated on an
  App-authored release proving `Verified`.
- Correct stale narrative in `.github/workflows/release.yml` and `AGENTS.md` that wrongly
  claim the API web-flow-signs "regardless of the token."

## Capabilities

### New Capabilities

(none)

### Modified Capabilities

- `release-pipeline`: the "Signed and verified release commits and tags" requirement is
  tightened to constrain the automation's *identity* (web-flow-signable token only; no
  classic PAT) and to state that the flow satisfies signing with no protection bypass in
  steady state.

## Impact

- `.github/workflows/release.yml` — already switched to the App token in PR #162; this change
  ratifies it in the spec and fixes the misleading comment.
- `AGENTS.md` — the "Releases" narrative claiming token-agnostic signing is corrected.
- Ruleset `17943629` (`require-signed-commits`) — the temporary admin bypass is removed once
  an App-authored release is verified (a manual, admin-only ruleset edit).
- Secrets: `RELEASE_APP_ID` / `RELEASE_APP_PRIVATE_KEY` are the release identity going forward.
  `GH_ADMIN_TOKEN` is **retained** — `infra-plan.yml` still needs it as the Terraform
  github-provider token (repo Administration), a permission the release App does not carry.
- No persona, skill, or eval behaviour is touched.
