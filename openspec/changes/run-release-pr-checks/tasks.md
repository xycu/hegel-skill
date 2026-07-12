## 1. Switch release-please authentication to the existing PAT

- [x] 1.1 In `.github/workflows/release.yml`, change the `token:` input of
      `googleapis/release-please-action@v5` from `${{ secrets.GITHUB_TOKEN }}` to
      `${{ secrets.GH_ADMIN_TOKEN }}`.
- [x] 1.2 Update the `release.yml` header comment block, which currently explains the
      `GITHUB_TOKEN` choice and the "events authored by GITHUB_TOKEN do not trigger other
      workflows" caveat, to describe the PAT-authored flow: the release PR's checks run
      normally, and API-created commits/tags are still web-flow-signed as "Verified".

## 2. Documentation

- [x] 2.1 Update `AGENTS.md` "Releases → Signing" bullet to state the automation uses the
      `GH_ADMIN_TOKEN` PAT, that its API-created commits/tags remain "Verified", and that
      the release PR's `skill-ci`/drift/OpenSpec/signed-commits checks now run (removing
      the "won't auto-run" caveat and the "required status checks must not be configured"
      rationale that was specific to the GITHUB_TOKEN limitation, since that limitation no
      longer applies to the release PR).

## 3. Verification on the live release PR (post-merge)

- [ ] 3.1 Merge this change to `main`; confirm the push triggers `release.yml` and it
      completes without a `403`/permission error from `GH_ADMIN_TOKEN` (if it 403s, the PAT
      lacks `contents: write` / `pull_requests: write` scope — record it and revert 1.1).
- [ ] 3.2 On the refreshed release PR, confirm its check workflows (`Skill CI`, `OpenSpec`,
      `Conventional Commits`, `Signed commits`) **execute** rather than showing
      `action_required`.
- [ ] 3.3 On the release-please commit in that PR, confirm GitHub shows the **"Verified"**
      badge (signed-commits ruleset #12 still satisfied). If not verified, revert 1.1 —
      the PAT path is abandoned in favour of a GitHub App.
- [ ] 3.4 Confirm the release PR is still `MERGEABLE` and that merging it produces the
      version bump, tag, and GitHub Release as before (no regression to the release itself).
