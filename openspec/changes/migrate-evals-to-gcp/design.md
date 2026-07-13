## Context

The promptfoo SLM evals run Ollama on GitHub `ubuntu-latest` (CPU) runners. The full graded
suite once exceeded the 90-minute PR envelope (#76), so it was split (#80): a fast judge-off
core subset per PR (`skill-ci.yml`) and the full graded suite nightly (`skill-ci-nightly.yml`).
Existing IaC (`ci-infrastructure` spec) already manages GitHub config as code, keyless WIF
(currently scoped to state-bucket access only), and a versioned GCS state bucket. The prior
attempt to move eval compute to GCP (#79) was a big-bang OpenTofu + L4-GPU + Artifact
Registry + Secret Manager epic that stalled `blocked` on NVIDIA L4 quota assumed up front.

## Goals / Non-Goals

**Goals:**
- Package the eval runtime as a reproducible container with models baked in.
- Prove it locally, then on GCP with one manual run, before touching any CI required check.
- Migrate CI eval steps to the GCP container runner one at a time, each independently
  revertible, with the `ubuntu-latest` path kept live until the GCP path is green.
- Discover the real hardware requirement (CPU vs GPU) from evidence, not assumption.
- Extend WIF minimally to cover Artifact Registry push + Cloud Run Job execution.

**Non-Goals:**
- Committing to NVIDIA L4 GPU up front (reintroduced only if the discovery run proves CPU
  can't meet budget).
- Secret Manager model-serving.
- Re-doing GitHub-config-as-code (already covered by `ci-infrastructure`); this change only
  touches WIF grants and the eval execution path.

## Decisions

- **Strangler-fig over big-bang.** Migrate step-by-step (shortest CI step → full PR gate →
  nightly), each shippable and revertible. *Alternative:* the original all-at-once GPU epic —
  rejected because it front-loads an unverified L4-quota dependency and has no partial value.
- **Compute: Cloud Run Job, CPU first.** Run the container as a Cloud Run Job via
  `gcloud run jobs execute --wait`; exit code → pass/fail. *Alternative:* GCE VM (more ops
  surface) or self-hosted GitHub runner (persistent host to secure). Cloud Run Jobs are
  ephemeral, WIF-friendly, and per-run billed. GPU stays out until Phase 3 evidence demands it.
- **Models baked into the image.** Kills cold-start model pull (a known cost from #79).
  *Alternative:* pull at run time — rejected (slow, flaky, network-dependent).
- **Discovery before migration (Phase 3).** One manual single-behaviour run records runtime,
  CPU sufficiency, region, and cost. This is where the *real* blocker surfaces — deliberately
  not pre-declared, so `blocked` is removed from #79.
- **Migrate smallest blast radius first.** One language of `core-slm-smoke` before the whole
  PR gate before nightly. *Alternative considered:* migrate nightly first as a non-PR-blocking
  canary — left as an open question below.
- **Manual gcloud first, OpenTofu once the shape is known.** Phase 3 is hand-run; the GCP
  compute (Artifact Registry, Cloud Run Job, IAM, WIF grants) is codified in OpenTofu at
  Phase 5, after the manual run has fixed the resource shape.

## Risks / Trade-offs

- **CPU is too slow for the full suite** → discover early (Phase 3, single behaviour); if
  proven, reintroduce GPU as a scoped follow-up rather than a blocking prerequisite.
- **L4 GPU quota / GPU-on-Jobs GA in region** → no longer on the critical path; only requested
  if Phase 3 evidence demands GPU.
- **WIF scope creep** → grant only Artifact Registry push + Cloud Run Job execution; keep the
  explicit "no Secret Manager, no service-account impersonation" guardrails from the existing
  requirement.
- **Dual-path drift while both runners are live** → keep `run-tests.sh` / promptfoo configs as
  the single source of truth both paths call; the container just changes *where* they run.
- **Required-check wedging on `main`** → migrate `core-slm-smoke` such that each matrix leg
  still reports a terminal status context under the same required name (the existing
  fast-gate requirement's constraint).
- **Cloud cost** → per-run Cloud Run billing, single-behaviour discovery run first; record
  cost before scaling to the full nightly suite.

## Migration Plan

Phase 0 prereqs (WIF grants, Artifact Registry, GCS state already exists) → Phase 1 image →
Phase 2 local runner → Phase 3 manual single-behaviour GCP run (discovery) → Phase 4 shortest
CI step (one-language core smoke) on GCP → Phase 5 full PR gate + OpenTofu-codify → Phase 6
nightly on GCP. **Rollback:** each phase reverts to `ubuntu-latest` for that step without
touching un-migrated steps; fallback retired only after consecutive green GCP runs.

## Open Questions

- **Nightly-first canary?** Phase 6 (nightly) blocks no PR on failure, so it is arguably the
  safest *first* real migration — at the cost of jumping straight to the heaviest workload.
  Current plan builds confidence smallest-first (4→6); revisit if a non-PR-blocking canary is
  preferred.
- **Region + machine size** for the Cloud Run Job — to be fixed by the Phase 3 discovery run.
- **Does any behaviour actually need GPU within budget?** — answered by Phase 3 evidence.
