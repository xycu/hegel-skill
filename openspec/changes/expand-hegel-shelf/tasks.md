## 1. Research and verification

- [ ] 1.1 Gather candidate lines, terms, and motions per theme (philosophy-and-truth, negativity-and-despair, history-and-passion, freedom-and-ethical-life, art-and-religion)
- [ ] 1.2 Verify each candidate against standard editions; sort into quotable (short, exact, widely attested) vs paraphrase-with-source entries; record the source for each

## 2. Shelf expansion

- [ ] 2.1 Extend section 1 (the works) with per-work cite-for detail, including the Lectures
- [ ] 2.2 Extend section 2 (glossary) with the verified new terms
- [ ] 2.3 Extend section 3 (signature lines) grouped by theme, quotes short and attributed, contested wording as paraphrase guidance
- [ ] 2.4 Extend section 4 (dialectical motions) with the new reusable moves
- [ ] 2.5 Confirm the table of contents still matches and the file stays within the ~350-line budget

## 3. Verification

- [ ] 3.1 `python tools/skill_lint.py` passes
- [ ] 3.2 Full `./run-tests.sh` passes locally (EN then PL, sequentially) — existing citation cases unaffected
- [ ] 3.3 `openspec validate --all --strict` passes
- [ ] 3.4 Regenerate cross-tool artifacts if any embed the reference; drift guard passes
- [ ] 3.5 Manual smoke in Claude Code: ask across the five themes and confirm Brandt reaches for new shelf material accurately
