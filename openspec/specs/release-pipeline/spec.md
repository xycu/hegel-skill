# release-pipeline Specification

## Purpose
Automate versioning, tagging, and GitHub Release publication for the plugin: derive the
semver bump from Conventional Commit history, keep the three plugin version fields in
lockstep (guarded against drift), and publish through a reviewed release-PR flow that
respects branch protection and produces signed, verified commits and tags.
## Requirements
### Requirement: Conventional-commit-driven version bump

The release pipeline SHALL derive the next semantic version from the Conventional
Commit types of the changes merged to `main` since the last release: a `fix:` change
SHALL produce a patch bump, a `feat:` change SHALL produce a minor bump, and any change
marked breaking (`!` after the type or a `BREAKING CHANGE:` footer) SHALL produce a
major bump. When several changes accumulate, the highest-ranked bump SHALL win.

#### Scenario: A fix produces a patch bump

- **GIVEN** the last release was version `X.Y.Z`
- **AND** the only change merged since is a `fix:` commit
- **WHEN** the release pipeline computes the next version
- **THEN** it SHALL propose `X.Y.(Z+1)`.

#### Scenario: A feature produces a minor bump

- **GIVEN** the last release was version `X.Y.Z`
- **AND** a `feat:` change has merged since (with no breaking change)
- **WHEN** the release pipeline computes the next version
- **THEN** it SHALL propose `X.(Y+1).0`.

#### Scenario: A breaking change produces a major bump

- **GIVEN** the last release was version `X.Y.Z`
- **AND** a change marked breaking (`!` or `BREAKING CHANGE:`) has merged since
- **WHEN** the release pipeline computes the next version
- **THEN** it SHALL propose `(X+1).0.0`.

---

### Requirement: Three version fields updated in lockstep

The release SHALL update all three plugin version fields to the same value in a single
release: `version` in `.claude-plugin/plugin.json`, `metadata.version` in
`.claude-plugin/marketplace.json`, and `plugins[0].version` in
`.claude-plugin/marketplace.json`.

#### Scenario: A release bumps every version field

- **WHEN** a release of version `V` is produced
- **THEN** `.claude-plugin/plugin.json` `version` SHALL equal `V`
- **AND** `.claude-plugin/marketplace.json` `metadata.version` SHALL equal `V`
- **AND** `.claude-plugin/marketplace.json` `plugins[0].version` SHALL equal `V`.

---

### Requirement: Version-drift guard

CI SHALL fail any pull request or push in which the three version fields do not all hold
the identical value, independently of the release tool, so manual edits cannot silently
desynchronize them.

#### Scenario: Fields agree

- **GIVEN** all three version fields hold the same value
- **WHEN** the drift guard runs
- **THEN** it SHALL pass.

#### Scenario: Fields disagree

- **GIVEN** at least one of the three version fields differs from the others
- **WHEN** the drift guard runs
- **THEN** it SHALL fail with a non-zero status
- **AND** it SHALL report which field(s) diverge.

---

### Requirement: Tag and GitHub Release with changelog

Completing a release SHALL create an annotated git tag for the new version and publish a
GitHub Release for that tag whose notes are a changelog generated from the Conventional
Commit history included in the release.

#### Scenario: Release artifacts are published

- **WHEN** a release of version `V` completes
- **THEN** a git tag naming version `V` SHALL exist in the repository
- **AND** a GitHub Release SHALL exist for that tag
- **AND** the Release notes SHALL list the changes since the previous release grouped by
  Conventional Commit type.

---

### Requirement: Branch-protection-respecting release flow

The release pipeline SHALL perform the version bump, tag, and Release through the normal
reviewed pull-request flow and SHALL NOT bypass branch protection on `main`. It SHALL
maintain a standing release pull request that accumulates pending changes; the release is
performed only when that pull request is merged.

#### Scenario: Releasing goes through a merged PR, not a direct push

- **GIVEN** changes have merged to `main` since the last release
- **WHEN** the pipeline prepares the release
- **THEN** it SHALL open or update a release pull request targeting `main`
- **AND** the version bump, tag, and Release SHALL be produced only when that pull request
  is merged through the protected flow
- **AND** the pipeline SHALL NOT push the bump directly to `main` or use a protection bypass.

---

### Requirement: Signed and verified release commits and tags

Every commit and tag the automation creates SHALL be cryptographically signed and show as
verified, so the release flow satisfies the all-branches signed-commits ruleset without a
bypass. To guarantee this, the pipeline SHALL authenticate as an identity whose GitHub API
commits are web-flow-signed — the Actions `GITHUB_TOKEN` or a GitHub App installation token —
and SHALL NOT create release commits with a classic Personal Access Token, whose API commits
are attributed to a user and land unsigned. The chosen identity SHALL also allow the release
pull request's own check workflows to run.

#### Scenario: Automation commits are verified

- **WHEN** the automation creates the release-pull-request commits and the release tag
- **THEN** each SHALL carry a valid signature
- **AND** GitHub SHALL mark each as "Verified".

#### Scenario: Release identity produces signable commits

- **WHEN** the pipeline authenticates to create the release commit
- **THEN** it SHALL use the Actions `GITHUB_TOKEN` or a GitHub App installation token
- **AND** it SHALL NOT use a classic Personal Access Token for the release commit.

#### Scenario: Signing needs no protection bypass in steady state

- **GIVEN** the release identity produces web-flow-signed commits
- **WHEN** the release pull request is merged and the tag is created
- **THEN** the all-branches signed-commits ruleset SHALL be satisfied without any
  ruleset or branch-protection bypass.

---

### Requirement: Release pull request checks execute

The identity that authors the standing release pull request SHALL be chosen so that the
pull request's check workflows execute and report a terminal status, rather than being
parked awaiting approval (GitHub's `action_required` state). Authoring the release pull
request under the default `GITHUB_TOKEN` — whose events GitHub forbids from triggering
further workflow runs — does not satisfy this requirement. This requirement SHALL hold
together with the "Signed and verified release commits and tags" requirement: the chosen
identity must both run the checks and produce verified commits and tags.

#### Scenario: The release PR's checks run instead of parking

- **GIVEN** the automation maintains a standing release pull request
- **WHEN** that pull request is opened or updated
- **THEN** its check workflows SHALL start and report a terminal status (success, neutral,
  or failure)
- **AND** they SHALL NOT sit indefinitely in an `action_required` (parked) state solely
  because the pull request was authored by the default `GITHUB_TOKEN`.

#### Scenario: Running the checks does not sacrifice signing

- **WHEN** the identity that authors the release pull request creates its commits and the
  release tag
- **THEN** the release PR's check workflows SHALL execute (per the scenario above)
- **AND** each created commit and tag SHALL still be signed and marked "Verified", so the
  all-branches signed-commits ruleset remains satisfied without a bypass.

---

### Requirement: Marketplace update detection

The first pipeline-produced release SHALL set the baseline version to `1.0.0`, and every
subsequent release SHALL increase the version monotonically under semantic versioning, so
that a marketplace client installed at an older version detects that a newer release
exists.

#### Scenario: Baseline release is detectable as an update

- **GIVEN** a client has the plugin installed at the stale `0.1.0`
- **WHEN** the first pipeline release publishes version `1.0.0`
- **THEN** the published version SHALL be greater than the installed version under
  semantic versioning
- **AND** the client SHALL be able to detect and pull the update.

#### Scenario: Each later release supersedes the previous

- **GIVEN** the most recent release is version `V`
- **WHEN** a new release is produced
- **THEN** its version SHALL be strictly greater than `V` under semantic versioning.

