## 1. Keyword list fix

- [x] 1.1 In `promptfoo/tests/grief.pl.yaml`, add `żal` alongside the existing `żał` in the `icontains-any` list for all three cases (`pl-grief`, `pl-grief-breakup`, `pl-grief-terminal`).
- [x] 1.2 In `promptfoo/tests/activation.pl.yaml`, add `żal` alongside the existing `żał` in the `icontains-any` list for `pl-activation-grief-denylist`.

## 2. Verification

- [x] 2.1 Run the PL grief cases (`promptfoo/tests/grief.pl.yaml`) locally against a local Ollama model (per this repo's iterate-locally-first convention) and confirm `pl-grief-breakup` now passes.
- [x] 2.2 Run the PL activation case (`promptfoo/tests/activation.pl.yaml`) locally to confirm `pl-activation-grief-denylist` still passes.
- [x] 2.3 Run the full local PL suite, then the full local EN suite sequentially (not concurrently, per this repo's convention) to check for regressions.
- [ ] 2.4 Open a PR referencing GitHub issue #136; after merge, confirm the next nightly run passes and the sticky issue auto-closes.
