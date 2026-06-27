## ADDED Requirements

### Requirement: Single canonical persona source

Every per-tool install artifact SHALL be derived from the single canonical source —
`skills/soused-hegelian/SKILL.md` and `references/hegel-reference.md`. The system SHALL NOT
maintain a hand-forked copy of the persona text for any tool. The persona body SHALL be
transcluded, not paraphrased; only a tool's frontmatter/header and activation phrasing MAY be
adapted.

#### Scenario: A persona edit propagates to every artifact

- **GIVEN** the canonical `SKILL.md` is edited
- **WHEN** the per-tool artifacts are regenerated
- **THEN** every derived artifact SHALL reflect the edit
- **AND** no artifact SHALL retain the superseded persona text.

#### Scenario: Hand-forked persona text is rejected

- **GIVEN** a per-tool artifact whose persona body diverges from the canonical source
- **WHEN** the drift guard runs
- **THEN** it SHALL fail and name the divergent artifact.

### Requirement: Generated, committed, and drift-guarded artifacts

Per-tool artifacts SHALL be produced by a generator from the canonical source, SHALL be
committed to the repository, and SHALL be guarded against drift in CI by regenerating them and
failing if the working tree differs from the committed output.

#### Scenario: In-sync artifacts pass the drift guard

- **GIVEN** the committed artifacts match what the generator produces from the current source
- **WHEN** CI regenerates and diffs them
- **THEN** the check SHALL pass with no changes.

#### Scenario: A hand-edited artifact fails the drift guard

- **GIVEN** a committed artifact has been edited without re-running the generator
- **WHEN** CI regenerates and diffs the artifacts
- **THEN** the check SHALL fail and report the differing file.

### Requirement: Two documented install modalities

The system SHALL provide, for each supported tool, exactly one documented install path: a
**native install** manifest at the tool-expected location where the tool has a
plugin/extension/marketplace system, or a **copy-a-rules-file** artifact under `install/<tool>/`
where it does not. The README SHALL document one install path per supported tool.

#### Scenario: A tool with a native install system installs from the repo

- **GIVEN** a tool that supports extension/marketplace installation
- **WHEN** a user follows the documented native install path
- **THEN** the persona SHALL load from the repo-provided manifest without copying files by hand.

#### Scenario: A tool without an install system uses one rules file

- **GIVEN** a tool that only reads a project rules file
- **WHEN** a user copies the single generated file from `install/<tool>/` into the documented location
- **THEN** the persona SHALL be active for that tool's project.

### Requirement: Version parity across versioned artifacts

Any per-tool artifact that carries a version field SHALL hold the same version as
`.claude-plugin/plugin.json`. CI SHALL fail if a versioned artifact diverges from the canonical
plugin version.

#### Scenario: A drifted manifest version fails CI

- **GIVEN** a per-tool manifest whose version differs from `plugin.json`
- **WHEN** the version-parity check runs
- **THEN** it SHALL fail and name the divergent field.

### Requirement: Persona behaviour unchanged across tools

Cross-tool packaging SHALL be packaging only. The dialectical engine, voice register, citation
fidelity, and the two boundary cases SHALL be identical across every tool's artifact. Only
activation mechanics MAY be adapted for tools that have no skill-eligibility concept, and that
adaptation SHALL NOT alter the engine, voice, or boundary behaviour.

#### Scenario: The engine is identical across tools

- **GIVEN** the canonical persona and any per-tool artifact derived from it
- **WHEN** their dialectical engine, voice, citation rules, and boundary cases are compared
- **THEN** they SHALL be equivalent.

#### Scenario: A tool without eligibility gets an always-on persona without engine changes

- **GIVEN** a tool that has no skill-eligibility mechanism (no per-turn self-gating)
- **WHEN** its artifact is derived
- **THEN** the persona SHALL be always-on for that tool's project
- **AND** the dialectical engine, voice, and boundary cases SHALL remain unchanged.
