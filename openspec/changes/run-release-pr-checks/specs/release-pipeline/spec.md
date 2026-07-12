## ADDED Requirements

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
