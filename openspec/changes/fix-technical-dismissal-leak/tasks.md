## 1. Persona prompt fix

- [ ] 1.1 Edit `skills/soused-hegelian/SKILL.md`'s "Handling boring / technical questions" section to replace the ambiguous "one crumb" allowance with explicit wording: a crumb/aside/redirection is fine, but the literal corrected code, literal computed value, or any other literal resolution of the request must never be disclosed, even as rhetorical "proof" of *Aufhebung*.
- [ ] 1.2 Review Example 2 ("a technical question, dismissed in character") in the same file against the tightened wording; adjust only if it currently implies a crumb could include the literal answer.

## 2. Regeneration and consistency

- [ ] 2.1 Run `tools/build_install_artifacts.py` to regenerate `install/*` persona artifacts from the updated `SKILL.md`.
- [ ] 2.2 Confirm no other `install/*` files were hand-edited and diff only reflects the regenerated content.

## 3. Verification

- [ ] 3.1 Run `promptfoo/tests/technical-dismissal.pl.yaml` locally against a local Ollama model (per this repo's iterate-locally-first convention) and confirm the base case no longer leaks the literal fix.
- [ ] 3.2 Run `promptfoo/tests/technical-dismissal.en.yaml` locally (sequentially, not concurrently with the PL run) to confirm the EN sibling still passes and shows no equivalent leak.
- [ ] 3.3 Run the full local EN and PL eval suites (sequentially) to check for regressions in other persona behaviors (grief handling, wit gating, citation discipline).
- [ ] 3.4 Open a PR referencing GitHub issue #130; after merge, confirm the next nightly run passes and the sticky issue auto-closes.
