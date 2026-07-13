## 1. Release identity (workflow)

- [x] 1.1 `release.yml` mints a GitHub App token via `actions/create-github-app-token` from `RELEASE_APP_ID` / `RELEASE_APP_PRIVATE_KEY` and passes it to release-please (shipped in PR #162)
- [x] 1.2 Repo secrets `RELEASE_APP_ID` and `RELEASE_APP_PRIVATE_KEY` exist; the App is installed on the repo with Contents + Pull requests read/write
- [x] 1.3 Confirmed the App-token release run authenticates and runs release-please with no permission error (v1.11.1 release PR #164 built and published successfully)

## 2. Narrative corrections

- [x] 2.1 Rewrite the `release.yml` header comment that claimed the API web-flow-signs "regardless of the token" (done in PR #162)
- [x] 2.2 Correct the `AGENTS.md` "Releases" narrative to state the identity must be `GITHUB_TOKEN` or a GitHub App (classic PAT API commits are unsigned)

## 3. Prove signing, then restore no-bypass

- [x] 3.1 App-authored release commit verified: `v1.11.1` (sha 037e6c7) shows `verified: true`, `reason: valid`, committer `GitHub`
- [x] 3.2 Removed the temporary admin bypass from the `require-signed-commits` ruleset (`17943629`); confirmed `bypass_actors: []`, `current_user_can_bypass: never`
- [ ] 3.3 Confirm the NEXT release (a `fix:`/`feat:` after the bypass removal) still passes the "Verify every commit is signed" check with no bypass

## 4. Verification

- [x] 4.1 `openspec validate --all --strict` passes
- [x] 4.2 `python tools/skill_lint.py` passes (docs/spec-only change; no persona/eval files touched, so the promptfoo suites are unchanged)
