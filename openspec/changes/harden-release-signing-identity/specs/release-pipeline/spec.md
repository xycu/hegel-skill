## MODIFIED Requirements

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
