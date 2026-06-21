## Context

The plugin version is frozen at `0.1.0` across three fields and has never tracked
`main`. Marketplace clients detect updates by version string, so the static version means
installed copies never see updates. The repo already enforces Conventional Commits (#11),
branch protection (#13), an all-branches signed-commits ruleset (#12), and Node-24 actions
(#10/#16). The release pipeline must build on those without weakening any of them — in
particular it must not bypass protected `main` and every commit/tag it makes must be
signed and verified.

## Goals / Non-Goals

**Goals:**
- Automated semver bump derived from Conventional Commit types, applied to all three
  version fields in lockstep.
- Git tag + GitHub Release with a generated changelog on every release.
- The whole flow goes through a reviewed PR into protected `main`; no bypass.
- Automation commits/tags are signed and show "Verified".
- A deterministic CI guard against version-field drift.
- First release establishes a `1.0.0` baseline so existing installs detect an update.

**Non-Goals:**
- A GitHub App or bot signing key (explicitly deferred — see Decisions).
- Publishing to any registry other than GitHub Releases.
- Hand-curated release notes beyond conventional-commit grouping.
- Any change to the persona, evals, or local test runner.

## Decisions

### release-please (release-PR model) over push-to-main tools

release-please maintains a standing "release PR" that accumulates changes; merging it
performs the bump, tag, and Release through the normal reviewed flow. Alternatives like
`semantic-release` push the bump and tag directly to `main`, which would require bypassing
branch protection (#13) — rejected for that reason.

### All three version fields via release-please `extra-files`

The plugin manifest is not a recognized ecosystem file, so the release type tracks the
version generically (e.g. `simple` with a manifest) and the three fields are updated with
`extra-files` JSON entries targeting `$.version` in `plugin.json` and `$.metadata.version`
and `$.plugins[0].version` in `marketplace.json`. A separate deterministic drift check
(below) is the safety net that does not depend on release-please being configured right.

### Drift guard is independent of release-please

A small CI check parses the three fields and fails if they disagree. Keeping it separate
from release-please means a hand-edit, a botched updater config, or a partial revert is
still caught. It runs on PRs and on `main`.

### Signing via the default `GITHUB_TOKEN`, no GitHub App

release-please creates its branch commits, the merge, and the tag through the **GitHub
API**, and GitHub signs API-created commits/tags with its own web-flow key — they show as
"Verified". That satisfies the #12 ruleset with zero credential setup. A GitHub App or a
bot signing key would also work and would additionally let the release PR trigger other
workflows (see Risks), but it is extra infrastructure we are deliberately deferring until
a concrete need appears.

### First release pinned to `1.0.0`

The first pipeline release reconciles the stale `0.1.0` and declares the plugin stable.
Implemented by seeding release-please's manifest and forcing the initial release version
(e.g. `Release-As: 1.0.0` on the bootstrap, or an explicit initial/manifest version), so
the first Release is `1.0.0` rather than a `0.1.x` patch.

## Risks / Trade-offs

- **`GITHUB_TOKEN`-authored PRs do not trigger other workflows.** GitHub suppresses
  workflow runs for events created by the default token (recursion guard). So the release
  PR will not auto-run `skill-ci` or the drift check, even though it edits `.claude-plugin/**`
  (a `skill-ci` path). → **Mitigation:** the release PR contains only mechanically generated
  version/changelog edits whose underlying source changes already passed CI on their own
  feature PRs; required-status-check configuration must therefore NOT demand a
  workflow-triggered check on the bot release PR, or that PR deadlocks (required-but-never-run).
  Keep required checks scoped to the reviewed feature PRs; the release PR is gated by review
  + the signing ruleset. If required checks on the release PR become desirable, switch the
  token to a GitHub App (the deferred option) — that re-enables triggering.
- **Tag push does not trigger tag-based workflows** for the same reason. → No release-time
  workflow may depend on the tag-push event; the release job itself does the publishing.
- **`extra-files` jsonpath drift with `marketplace.json` shape changes** (e.g. reordering
  `plugins`). → The independent drift guard catches a mismatch; `plugins[0]` is asserted by
  position, so document that the plugin stays first.
- **Wrong bump from a mislabeled squash subject.** → Conventional-commit enforcement (#11)
  already validates PR titles; the squash subject is that title.

## Migration Plan

1. Land release-please config + workflow and the drift guard (this change), with the
   manifest seeded so the first release computes to `1.0.0`.
2. Merge to `main`; release-please opens the first release PR (version → `1.0.0`, changelog).
3. Review and merge the release PR → tag `v1.0.0` + GitHub Release published, all three
   fields at `1.0.0`, signed/verified.
4. Rollback: the pipeline only ever acts through PRs and tags; reverting the workflow files
   disables it, and an erroneous Release/tag can be deleted without touching `main` history.

## Open Questions

- Exact required-status-check configuration on the release PR (settings-level choice) so it
  stays mergeable under the `GITHUB_TOKEN` constraint — confirm during rollout.
- Whether to keep `marketplace.json` `plugins[0]` positional or switch the updater to match
  the plugin by `name` if release-please supports it for this file type.
