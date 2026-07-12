## ADDED Requirements

### Requirement: A summon command engages Brandt deterministically
The plugin SHALL ship a `/brandt` command that performs a manual summon with the
exact semantics of the existing rung-1 activation in `soused-hegelian-persona`:
deterministic engagement, stickiness for the rest of the conversation until a
sincere dismissal, deny-list override, full Brandt voice, and the `slop:` footer.
The command SHALL accept an optional question argument.

#### Scenario: Summon with a question
- **WHEN** the user runs `/brandt <question>`
- **THEN** the reply is a full manually-summoned Brandt answer to that question — engine, voice, citations, and `slop:` footer — and the persona is sticky for subsequent turns

#### Scenario: Summon without a question
- **WHEN** the user runs `/brandt` with no argument
- **THEN** Brandt engages in character, awaiting the matter to be brought to him, and the persona is sticky for subsequent turns

#### Scenario: Command summon overrides the deny-list
- **WHEN** the user runs `/brandt` on a turn that would otherwise fall on the deny-list (e.g. genuine grief)
- **THEN** the persona engages as a manual summon does — grief routes to grave tenderness, in character — rather than being suppressed

### Requirement: A dismiss command releases the persona sincerely
The plugin SHALL ship a dismiss command (preferred form `/brandt:dismiss`) that
counts as the sincere, good-faith request to drop the persona. It SHALL end the
sticky summoned session and return subsequent turns to plain answers. It SHALL
NOT alter spontaneous eligibility: after dismissal, the d20 takeover and wit
aside operate exactly as before the summon.

#### Scenario: Dismiss after a summon
- **WHEN** the user runs the dismiss command during a sticky summoned session
- **THEN** the persona is dropped as on a sincere request, and subsequent turns are plain answers

#### Scenario: Dismiss with no active summon
- **WHEN** the user runs the dismiss command while no summon is in force
- **THEN** the reply is a brief plain acknowledgment with no persona markers and no error

#### Scenario: Dismissal leaves spontaneous eligibility untouched
- **WHEN** a summoned session has been ended via the dismiss command
- **THEN** later turns remain eligible for the d20 takeover and wit aside exactly as if the summon had never occurred

### Requirement: Commands are thin vehicles over the activation ladder
The command files SHALL NOT duplicate or restate the persona engine, voice
rules, or reference material; each SHALL only direct the assistant onto the
existing activation ladder (summon or sincere dismissal) so the single canonical
persona source is preserved. The deterministic lint SHALL validate that both
command files exist and carry well-formed frontmatter.

#### Scenario: Persona rules live only in the skill
- **WHEN** a command file is inspected
- **THEN** it contains the summon or dismissal directive and argument handling only, not a copy of engine, voice, or citation rules

#### Scenario: Lint validates the command files
- **WHEN** `python tools/skill_lint.py` runs against a package missing a command file or with malformed command frontmatter
- **THEN** the lint exits non-zero and reports the offending file
