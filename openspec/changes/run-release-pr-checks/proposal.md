## Why

The standing release-please pull request shows every check workflow (Skill CI, OpenSpec,
Conventional Commits, Signed commits) parked as **`action_required`** — they never run
(GitHub issue #66). Cause: `release.yml` authenticates release-please with the default
`GITHUB_TOKEN`, and GitHub's anti-recursion rule forbids a `GITHUB_TOKEN`-triggered event
from triggering further workflow runs. This is cosmetic today (`main` requires no status
checks, so the release PR is still mergeable), but the parked checks look like they "need
approval", add noise, and mean the version-drift / lint checks never actually execute on
the one PR that edits `.claude-plugin/**`.

The clean fix is to author the release PR under a non-`GITHUB_TOKEN` identity so its check
workflows run normally. A GitHub App is one path; a **PAT already exists as a repo secret
(`GH_ADMIN_TOKEN`)**, already used by `infra-plan.yml`. release-please creates its
commits/tag through the GitHub **API** (not a local push), and API-created commits are
web-flow-signed as "Verified" regardless of whether the token is `GITHUB_TOKEN` or a PAT —
so swapping to `GH_ADMIN_TOKEN` is expected to keep signing **and** un-park the checks.
That expectation must be verified on a live release PR before we trust it, since the
signed-commits ruleset (#12) gates `main` on every branch.

## What Changes

- Change `.github/workflows/release.yml` to authenticate `release-please-action` with
  `${{ secrets.GH_ADMIN_TOKEN }}` (the existing PAT) instead of `${{ secrets.GITHUB_TOKEN }}`.
- Update the `release.yml` header comment and the `AGENTS.md` "Releases → Signing" note,
  which currently document the deliberate `GITHUB_TOKEN` choice and its parked-checks
  caveat, to describe the PAT-authored flow (checks run; commits still API-signed).
- Verify on the live release PR that (a) its check workflows execute instead of sitting
  `action_required`, and (b) the release-please commit still shows GitHub's "Verified"
  badge. If either fails (e.g. a `403` from insufficient PAT scope, or an unsigned commit),
  revert to `GITHUB_TOKEN` — the PAT path is abandoned and a GitHub App becomes the only
  clean option.

## Capabilities

### New Capabilities

(none)

### Modified Capabilities

- `release-pipeline`: adds a requirement that the standing release pull request's check
  workflows execute (not park as `action_required`), while the existing "Signed and
  verified release commits and tags" requirement is preserved unchanged — the token used
  to author the release PR must satisfy both.

## Impact

- `.github/workflows/release.yml`: `token:` input to `release-please-action` switches from
  `secrets.GITHUB_TOKEN` to `secrets.GH_ADMIN_TOKEN`; header comment updated.
- `AGENTS.md`: "Releases → Signing" bullet updated to reflect PAT authorship and that the
  release PR's checks now run.
- No Terraform/IAM change: `GH_ADMIN_TOKEN` already exists as a repo secret; this change
  does not create or rotate it. If the live test surfaces a `403`, the fix is a PAT scope
  adjustment (out of band, on the token itself), not a code change here.
- Verification is only fully observable **after merge to `main`**, because release-please
  runs on push to `main`; this change's own PR runs the previously-parked check workflows
  normally (it is not authored by `GITHUB_TOKEN`).
