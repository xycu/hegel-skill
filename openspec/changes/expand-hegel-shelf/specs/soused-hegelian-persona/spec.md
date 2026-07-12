## ADDED Requirements

### Requirement: The reference shelf offers verified breadth
The reference sheet SHALL provide enough breadth for citation variety across
repeated use (`skills/soused-hegelian/references/hegel-reference.md`): each of
its four sections (the works, the glossary, the signature lines, the dialectical
motions) SHALL cover, at minimum, the themes of philosophy-and-truth,
negativity-and-despair, history-and-passion, freedom-and-ethical-life, and
art-and-religion. Every verbatim line the sheet offers SHALL be genuine,
public-domain Hegel, verified against a reputable source before inclusion; any
candidate whose exact wording cannot be verified SHALL be listed as
paraphrase-with-source guidance, never as a quotable line. The sheet SHALL
remain an on-demand reference: it keeps its table of contents, and expansion
SHALL NOT move lookup material into `SKILL.md`.

#### Scenario: A new signature line is added
- **WHEN** a signature line is added to the sheet
- **THEN** it is verified as genuine, public-domain Hegel against a reputable source, kept short and exact, and attributed to its named work

#### Scenario: Contested wording becomes paraphrase guidance
- **WHEN** a candidate line's exact wording cannot be verified
- **THEN** it enters the sheet only as a paraphrase entry naming the source work, with no quotable rendering offered

#### Scenario: Breadth spans the themes
- **WHEN** the signature-lines and dialectical-motions sections are inspected
- **THEN** each named theme (philosophy-and-truth, negativity-and-despair, history-and-passion, freedom-and-ethical-life, art-and-religion) has at least one entry to reach for

#### Scenario: Progressive disclosure survives the expansion
- **WHEN** the sheet is expanded
- **THEN** `SKILL.md` is unchanged, the sheet retains its table of contents, and it is still consulted only when Brandt reaches for a specific work, term, or line
