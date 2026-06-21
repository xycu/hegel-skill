## 1. Version-drift guard (independent of release-please)

- [ ] 1.1 Add a deterministic check that reads `.claude-plugin/plugin.json` `version`,
  `.claude-plugin/marketplace.json` `metadata.version`, and `plugins[0].version`, and
  fails non-zero (naming the divergent field) if they are not all equal
- [ ] 1.2 Wire it into CI on pull_request and push to `main` (extend `skill-ci.yml` or a
  small standalone job); pin any action to a Node-24 version
- [ ] 1.3 Run it locally against current `main` (all three at `0.1.0`) → passes; mutate one
  field → fails

## 2. release-please configuration

- [ ] 2.1 Add `release-please-config.json`: release-type that tracks the version generically,
  with `extra-files` JSON entries for `$.version` (plugin.json), `$.metadata.version` and
  `$.plugins[0].version` (marketplace.json), and changelog grouping by commit type
- [ ] 2.2 Add `.release-please-manifest.json` seeded so the first computed release is `1.0.0`
  (e.g. bootstrap version + `Release-As: 1.0.0`, or explicit initial version)
- [ ] 2.3 Confirm the config validates (dry-run / `--dry-run` if available) without contacting
  the live repo

## 3. Release workflow

- [ ] 3.1 Add `.github/workflows/release.yml` running `googleapis/release-please-action`
  (pinned to a Node-24 version) on push to `main`, using the default `GITHUB_TOKEN`
- [ ] 3.2 Grant least-privilege permissions (`contents: write`, `pull-requests: write`) and
  set `concurrency` so overlapping runs don't race the release PR
- [ ] 3.3 Do not depend on the tag-push event for any follow-on job (GITHUB_TOKEN tag pushes
  don't trigger workflows); the release-please job itself publishes tag + Release

## 4. Governance alignment

- [ ] 4.1 Verify release-please's API-created commits/merge/tag show "Verified" so the #12
  signed-commits ruleset is satisfied with no bypass and no GitHub App
- [ ] 4.2 Confirm the release PR can merge under branch protection (#13): ensure required
  status checks are not configured to demand a workflow-triggered check on the bot PR
  (which GITHUB_TOKEN suppresses) — document the required-checks expectation in the PR
- [ ] 4.3 Confirm nothing in the flow pushes directly to `main` or uses a protection bypass

## 5. First-release baseline

- [ ] 5.1 Ensure the first release PR proposes `1.0.0` and updates all three fields together
- [ ] 5.2 After the first release merges, confirm tag `v1.0.0`, a GitHub Release with a
  changelog, and all three fields at `1.0.0`

## 6. Documentation

- [ ] 6.1 Add a "Releases" section to README and AGENTS.md: the release-PR flow, the
  three-fields-in-lockstep invariant + drift guard, conventional-commit → bump mapping, and
  the GITHUB_TOKEN signing/triggering caveat
- [ ] 6.2 Update the OpenSpec mirror in AGENTS.md if the new capability needs a pointer

## 7. Verification

- [ ] 7.1 Merge a `feat:`-typed change and confirm release-please opens/updates a release PR
  proposing the correct minor bump
- [ ] 7.2 Confirm the drift guard fails CI when a single version field is desynchronized
- [ ] 7.3 Confirm the produced tag + GitHub Release exist and the Release notes group changes
  by conventional-commit type
- [ ] 7.4 Confirm the release PR's commits and the tag are signed/verified
