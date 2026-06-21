## Why

The plugin version is frozen at `0.1.0` and duplicated across three fields
(`.claude-plugin/plugin.json` and two locations in `.claude-plugin/marketplace.json`).
It has never moved through any merged feature, so it no longer reflects `main`. For a
marketplace-installed plugin the version string is how a client detects a newer
release — a static version means an installed `hegel-skill` never sees that an update
exists, so auto-update never fires. The repo now has the prerequisites in place
(Conventional Commits #11, branch protection #13, signed commits #12, Node 24 #10), so
an automated, protection-respecting release pipeline can finally be built on top of them.

## What Changes

- Add a **release pipeline** driven by [release-please](https://github.com/googleapis/release-please)
  in its release-PR model: on merges to `main` it maintains a standing "release PR" that
  accumulates changes; merging that PR performs the version bump, the git tag, and a
  GitHub Release with a generated changelog — all through the normal reviewed flow, never
  bypassing protected `main`.
- The next version is **derived from Conventional Commit types** on the merged squash
  subjects (`fix:` → patch, `feat:` → minor, `!` / `BREAKING CHANGE` → major).
- release-please updates **all three version fields in lockstep** via its generic/extra-files
  JSON updaters: `plugin.json` `version`, `marketplace.json` `metadata.version`, and
  `marketplace.json` `plugins[0].version`.
- Add a **version-drift CI check** that fails if the three fields ever disagree — a
  deterministic guard independent of release-please.
- The **first pipeline-produced release sets the baseline to `1.0.0`**, reconciling the
  stale `0.1.0` and declaring the plugin stable, so existing installs detect an update.
- The automation runs as the default **`GITHUB_TOKEN` github-actions bot**. release-please
  creates its commits through the GitHub API, which GitHub auto-signs with its web-flow
  key (shows "Verified"), so the all-branches signed-commits ruleset (#12) is satisfied
  with **no GitHub App and no bypass**. The known caveat — `GITHUB_TOKEN`-authored PRs do
  not auto-trigger other workflows — is handled explicitly (see design).
- All release-workflow actions are pinned to **Node-24 versions** so the pipeline does not
  reintroduce the deprecation warning addressed in #10/#16.

## Capabilities

### New Capabilities
- `release-pipeline`: automated, branch-protection-respecting versioning, tagging, and
  GitHub Release publication for the plugin, with the three version fields kept in lockstep
  and guarded against drift.

### Modified Capabilities
<!-- None. The persona, evals, and local test runner are unaffected; this adds release
     engineering around the existing package. -->

## Impact

- New workflow: `.github/workflows/release.yml` (release-please) and release-please config
  (`release-please-config.json` + `.release-please-manifest.json`, or equivalent inputs).
- New CI guard: a version-drift check (added to `skill-ci.yml` or a small standalone job).
- Edited data files: the three version fields reconciled to `1.0.0` for the baseline.
- Governance interaction: relies on #11 (Conventional Commits), and must respect #12
  (signed commits) and #13 (branch protection) without bypass.
- Documentation: README / AGENTS.md gain a "Releases" section describing the flow and how
  the version fields stay in sync.
- No change to the skill prose or the persona behaviour.
