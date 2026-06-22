## Why

The promptfoo suite uses only string-presence assertions. Some quality checks are
deterministic and need no judge model — e.g. structural checks on the dialectical move
or parsing the `slop:` footer score. Landing these first establishes the custom-assert
plumbing (promptfoo `javascript` / `python` asserts) with no judge, no secrets, and no
network, de-risking the llm-rubric work that follows.

Sub-issue #29 of epic #5. _Tier: Low, no deps_ — do first.

## What Changes

- Add promptfoo `javascript` (or `python`) custom assertions for deterministic quality
  checks: footer-score parsing as a real metric, and a structural check that the answer
  performs a determinate negation / sublation rather than merely naming Hegel.
- Wire them into the EN/PL configs alongside the existing keyword asserts.
- No judge model, no secrets, no network.

## Capabilities

### Modified Capabilities
- `skill-evaluation`: gains deterministic custom (code) assertions in addition to the
  keyword contracts; no model-graded behaviour yet.

## Impact

- **New files:** custom assert scripts under `promptfoo/`.
- **No new infra:** runs in the existing CI envelope. Establishes plumbing reused by #31/#32.
