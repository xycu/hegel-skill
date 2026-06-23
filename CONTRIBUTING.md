# Contributing

Thanks for wanting to help Doktor Brandt drink and dialecticize more coherently.

This is a Claude **plugin** with no code and no build system — a single persona skill
shipped as Markdown prose. "Correctness" means the prose keeps the persona coherent and
the Hegel citations accurate (two automated guards back that up; see below).

The full conventions live in **[`AGENTS.md`](AGENTS.md)** — it is the single source of
truth for how changes are made here, written for coding agents *and* humans. This file is
the short human-facing entry point; when something below is terse, follow the link for the
authoritative detail.

## The essentials

- **One concern per PR.** Branch off `main` as `feat/…`, `fix/…`, `chore/…`, `ci/…`, or
  `docs/…`. Out-of-scope ideas become issues, not scope creep.
  → [AGENTS.md → Way of working](AGENTS.md#way-of-working)
- **Conventional Commits.** Messages *and* PR titles follow
  [Conventional Commits](https://www.conventionalcommits.org/) — it's enforced, and it
  drives the release version bump (`fix:` → patch, `feat:` → minor, `!`/`BREAKING CHANGE:`
  → major). Add a `Co-Authored-By:` trailer for AI-assisted commits. PRs squash-merge.
- **Signed commits are mandatory on every branch.** Set up signing **before** your first
  push, or the push is rejected. SSH signing is the simplest path — see the step-by-step
  in → [AGENTS.md → Signed commits](AGENTS.md#signed-commits).
- **Test locally first.** Run `./run-tests.sh` green before relying on CI (lint + the EN/PL
  promptfoo SLM evals over Ollama) — the SLM evals are the expensive CI minutes. Say
  plainly what you verified locally vs. what you're trusting CI to confirm.
  → [AGENTS.md → Tests](AGENTS.md#tests)
- **Non-trivial changes are spec-driven.** Behavioural *and* tooling/CI/infra changes go
  through [OpenSpec](https://github.com/Fission-AI/OpenSpec) first; pure prose polish that
  changes no requirement is exempt.
  → [AGENTS.md → Spec-driven development](AGENTS.md#spec-driven-development-openspec)
- **Infrastructure is code.** The CI/eval environment and GitHub config live as OpenTofu in
  `infra/` — keyless WIF auth, GCS state, a GPU Cloud Run Job eval runner. Plan-on-PR is
  automatic; `apply` is the maintainer's. → [AGENTS.md → Infrastructure](AGENTS.md#infrastructure-iac)
  and [`infra/README.md`](infra/README.md)

## Before you open a PR

1. Signing is configured and your commits show GitHub's "Verified" badge.
2. The branch name and PR title follow the conventions above.
3. `./run-tests.sh` passes locally.
4. For a non-trivial change, the OpenSpec change validates
   (`openspec validate --all --strict`).
5. Open the PR early (a proposal commit is enough), let CI confirm, archive the OpenSpec
   change if any, then merge. The Skill-CI eval run sits *"Waiting for review"* until you
   approve it (PR → Checks → *Review deployments* → `evals` → *Approve and deploy*; self-
   approve is fine — this is the deployment gate, **not** the PR *Files changed → Approve*
   button, which GitHub never lets an author press and which isn't required here). Wait for
   it to go green, then merge by hand — don't blind-arm
   `--auto`, and don't cancel a still-waiting run (it shows up red but isn't a failure).

## Reporting honestly

Distinguish "verified" from "assumed". If a check was skipped, redundant, or
merged-while-pending, say so and why. Don't claim a green you didn't see.
