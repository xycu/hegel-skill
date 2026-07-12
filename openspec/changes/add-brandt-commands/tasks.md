## 1. Command files

- [x] 1.1 Create `commands/brandt.md` — frontmatter + thin summon directive; `$ARGUMENTS` passed as the question, bare invocation engages Brandt awaiting the matter
- [x] 1.2 Create the dismiss command as `commands/brandt/dismiss.md` (preferred `/brandt:dismiss`); if the loader rejects the file/dir coexistence, fall back to `commands/brandt-dismiss.md`
- [ ] 1.3 Verify in Claude Code that both commands appear in the `/` menu and route correctly (summon with/without argument; dismiss during and outside a summon)

## 2. Lint

- [x] 2.1 Extend `tools/skill_lint.py` to require both command files and validate their frontmatter
- [x] 2.2 Exercise the failure modes: missing command file and malformed frontmatter each exit non-zero with the offending file named

## 3. Docs

- [x] 3.1 Add a "Summoning Brandt" section to `README.md` covering `/brandt`, `/brandt:dismiss`, and the plain-phrase summons that still work everywhere
- [x] 3.2 Note in the cross-tool install docs that commands are a Claude-plugin-only surface (other tools keep phrase summons)

## 4. Verification

- [x] 4.1 `python tools/skill_lint.py` passes on the final tree
- [x] 4.2 `./run-tests.sh` passes (suites unchanged — confirms no accidental package breakage)
- [x] 4.3 `openspec validate --all --strict` passes
