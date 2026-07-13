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

- [x] 3.1 Merged in PR #148; the push triggered `release.yml` with no `403` from
      `GH_ADMIN_TOKEN`.
- [x] 3.2 Verified on the live release PR under the **successor identity**: release PR
      #164 (v1.11.1) shows all check workflows executed with terminal statuses (`Skill CI`
      smoke jobs, `OpenSpec`, `Conventional Commits`, `Signed commits` — all SUCCESS or
      SKIPPED, none `action_required`).
- [x] 3.3 Resolution per the fallback in this task: the PAT's API commits landed
      **unsigned** (attributed to the user, not web-flow-signed), so 1.1 was reverted and
      the PAT path abandoned in favour of a GitHub App installation token (PR #162, change
      `harden-release-signing-identity`). The requirement this change adds — release PR
      checks execute alongside verified commits — is satisfied by the App identity:
      release PR #164's commit is Verified and its checks ran.
- [x] 3.4 Release PR #164 merged cleanly and produced the v1.11.1 bump, tag, and GitHub
      Release with no regression.
