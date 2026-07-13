## 1. Command files

- [x] 1.1 Create `commands/brandt.md` — frontmatter + thin summon directive; `$ARGUMENTS` passed as the question, bare invocation engages Brandt awaiting the matter
- [x] 1.2 Create the dismiss command. The preferred nested `commands/brandt/dismiss.md` (`/brandt:dismiss`) does NOT load — a `commands/brandt.md` file and a `commands/brandt/` directory cannot coexist, so the file shadows the directory and the nested command never registers. Fell back to the flat `commands/brandt-dismiss.md` (`/brandt-dismiss`).
- [x] 1.3 Verified in Claude Code: `/brandt` appears and routes; the nested `/brandt:dismiss` did not register (confirmed the coexistence problem); after flattening, `/brandt-dismiss` appears and routes (dismiss during and outside a summon)

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
