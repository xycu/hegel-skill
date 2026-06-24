# Proposal: Auto-remove the "in progress" label when an issue closes

## What

Add a small GitHub Actions workflow that removes the `in progress` label from an
issue whenever the issue is closed, so the label reflects live state instead of
accumulating on closed issues.

## Why

`in progress` is applied when work starts but nothing strips it on close, so closed
issues keep the label and the board misrepresents what is actually being worked on.
Two closed issues (#83, #36) had already drifted this way and were cleaned up by
hand. A close-triggered workflow removes the toil and keeps the label honest.

## Scope

- **In:** a new `.github/workflows/issue-label-hygiene.yml` triggered on issue close,
  least-privilege `issues: write`, that removes `in progress` only when present.
- **Out of scope:** other labels; re-adding the label on reopen; the IaC-managed
  label *definitions* (the label itself stays defined in OpenTofu — this only manages
  its removal on close).
- **Constraint:** the workflow MUST be a no-op (no failure) for issues that do not
  carry the label.
