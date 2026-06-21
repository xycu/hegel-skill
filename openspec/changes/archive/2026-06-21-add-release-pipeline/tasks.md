## 1. Version-drift guard (independent of release-please)

- [x] 1.1 Add a deterministic check (`tools/version_check.py`) that reads the three fields
  and fails non-zero (naming the divergent field) if they are not all equal
- [x] 1.2 Wire it into the `skill-ci` lint job (runs on PRs and push to `main`)
- [x] 1.3 Run it locally against current `main` (all three at `0.1.0`) → passes; mutate one
  field → fails

## 2. release-please configuration

- [x] 2.1 Add `release-please-config.json`: `release-type: simple`, `extra-files` for
  `$.version` (plugin.json) and `$..version` (marketplace.json — covers both fields in one
  entry, avoiding duplicate-path clobbering), changelog grouping by commit type
- [x] 2.2 Add `.release-please-manifest.json` seeded at `0.1.0`; config carries
  `release-as: 1.0.0` so the first computed release is `1.0.0` (remove the key after v1.0.0)
- [x] 2.3 JSON-validate config + manifest and confirm the `$..version` jsonpath matches
  exactly the two intended marketplace nodes (full release-please dry-run needs the live
  repo + token; deferred to the first real run)

## 3. Release workflow

- [x] 3.1 Add `.github/workflows/release.yml` running `googleapis/release-please-action@v5`
  (Node 24) on push to `main`, using the default `GITHUB_TOKEN`
- [x] 3.2 Grant least-privilege permissions (`contents: write`, `pull-requests: write`) and
  set `concurrency: release-please` so overlapping runs don't race the release PR
- [x] 3.3 No follow-on job depends on the tag-push event; the release-please job publishes
  tag + Release itself

## 4. Governance alignment

- [ ] 4.1 Verify release-please's API-created commits/merge/tag show "Verified" so the #12
  signed-commits ruleset is satisfied with no bypass and no GitHub App
- [ ] 4.2 Confirm the release PR can merge under branch protection (#13): ensure required
  status checks are not configured to demand a workflow-triggered check on the bot PR
  (which GITHUB_TOKEN suppresses) — document the required-checks expectation in the PR
- [x] 4.3 Confirm nothing in the flow pushes directly to `main` or uses a protection bypass
  (workflow only invokes release-please; no `git push`, no bypass actor)

## 5. First-release baseline

- [ ] 5.1 Ensure the first release PR proposes `1.0.0` and updates all three fields together
- [ ] 5.2 After the first release merges, confirm tag `v1.0.0`, a GitHub Release with a
  changelog, and all three fields at `1.0.0`

## 6. Documentation

- [x] 6.1 Add a "Releases" section to README and AGENTS.md: the release-PR flow, the
  three-fields-in-lockstep invariant + drift guard, conventional-commit → bump mapping, and
  the GITHUB_TOKEN signing/triggering caveat
- [x] 6.2 AGENTS.md "Releases" section documents the new capability and the one-time
  `release-as` bootstrap removal

## 7. Verification

- [ ] 7.1 Merge a `feat:`-typed change and confirm release-please opens/updates a release PR
  proposing the correct minor bump
- [ ] 7.2 Confirm the drift guard fails CI when a single version field is desynchronized
- [ ] 7.3 Confirm the produced tag + GitHub Release exist and the Release notes group changes
  by conventional-commit type
- [ ] 7.4 Confirm the release PR's commits and the tag are signed/verified
