## 1. Design note + capability spec (this change, #39)

- [x] 1.1 Record the single-source → per-tool map, modality split, reference handling, and
      derivation method in `proposal.md`.
- [x] 1.2 Recommend generated + committed + drift-guarded; reject the two alternatives.
- [x] 1.3 Add the `cross-tool-install` capability spec the sub-issues implement against.
- [x] 1.4 `openspec validate add-cross-tool-install --strict` clean.

## 2. Handoff to the implementing sub-issues (built on their own branches)

- [x] 2.1 **#40** — generator + copy-a-rules-file artifacts for Cursor / Windsurf / Cline /
      Zed / Aider / Copilot under `install/<tool>/`.
- [ ] 2.2 **#41** — Gemini CLI native install (`gemini-extension.json` + `GEMINI.md`).
- [ ] 2.3 **#42** — Codex + OpenCode native install manifests.
- [ ] 2.4 **#43** — CI guard: generator regenerate-and-diff drift check + version parity across
      versioned artifacts (extend `tools/version_check.py`).
- [ ] 2.5 **#44** — README per-tool install matrix documenting one path per supported tool.
