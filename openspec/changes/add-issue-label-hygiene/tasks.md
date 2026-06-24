# Tasks: Auto-remove the "in progress" label when an issue closes

- [x] Add `.github/workflows/issue-label-hygiene.yml`: trigger on issue close, least-privilege `issues: write`, remove `in progress` only when present (guarded so it is a no-op otherwise)

- [x] `openspec validate add-issue-label-hygiene --strict` clean

- [x] Confirm the workflow YAML parses and the conditional guard references `github.event.issue.labels.*.name` correctly
