## 0. Prereqs (no GPU)

- [ ] 0.1 Confirm/target GCP project and enable required APIs (Artifact Registry, Cloud Run, IAM).
- [ ] 0.2 Create the eval Artifact Registry repository.
- [ ] 0.3 Confirm the versioned GCS state bucket exists (from `ci-infrastructure`); reuse it.
- [ ] 0.4 Extend the WIF principal's IAM: Artifact Registry push + Cloud Run Job execution (`roles/run.invoker` + job-execution), keeping the no-Secret-Manager / no-impersonation guardrails.

## 1. Container image

- [ ] 1.1 Write a `Dockerfile` for the eval runtime: Ollama + promptfoo pinned to `PROMPTFOO_VERSION`, `run-tests.sh`, `promptfoo/` configs.
- [ ] 1.2 Bake the model(s) under test into the image so no model is pulled at run time.
- [ ] 1.3 Verify the image builds from a clean checkout and the installed promptfoo equals `PROMPTFOO_VERSION`.

## 2. Local containerised runner

- [ ] 2.1 Add a single script/make target that runs the promptfoo suite inside the container from repo root.
- [ ] 2.2 Ensure exit code mirrors CI semantics (0 on pass, non-zero on any failure).
- [ ] 2.3 Run it locally against the core subset and confirm pass and forced-fail both propagate correctly.

## 3. One manual test on GCP (discovery)

- [ ] 3.1 Push the image to Artifact Registry via WIF (no SA JSON key).
- [ ] 3.2 Configure a Cloud Run Job from the image; run a single behaviour (one language) via `gcloud run jobs execute --wait`.
- [ ] 3.3 Confirm the job exit code reflects pass/fail.
- [ ] 3.4 Record runtime, CPU-vs-GPU sufficiency, region availability, and cost — the discovery finding that decides whether GPU is needed.

## 4. Shortest CI step on GCP

- [ ] 4.1 Wire one language of `core-slm-smoke` in `skill-ci.yml` to trigger the Cloud Run Job over WIF; propagate exit code to the check.
- [ ] 4.2 Keep the sticky eval-results comment (#27/#28) posting for the migrated step.
- [ ] 4.3 Ensure the migrated matrix leg still reports a terminal status context under its required name (no `pending` wedge on `main`); leave all other steps on `ubuntu-latest`.
- [ ] 4.4 Confirm the step is independently revertible to `ubuntu-latest`.

## 5. Full PR gate on GCP

- [ ] 5.1 Migrate the remaining `skill-ci.yml` eval work (both languages, core subset) onto the container/job.
- [ ] 5.2 Codify the GCP compute (Artifact Registry, Cloud Run Job, IAM, WIF grants) in OpenTofu; plan visible on PR.
- [ ] 5.3 Verify `evals` environment approval gate and required checks still behave.
- [ ] 5.4 Retire the `ubuntu-latest` PR-gate path only after consecutive green GCP runs.

## 6. Nightly on GCP

- [ ] 6.1 Migrate the full graded suite (all behaviours EN+PL, `llm-rubric` + `similar` on) in `skill-ci-nightly.yml` to the Cloud Run Job.
- [ ] 6.2 Confirm the suite completes within budget and the nightly outcome is visible (summary and/or tracking issue).
- [ ] 6.3 Retire the `ubuntu-latest` nightly path after two consecutive green GCP runs.

## 7. Wrap-up

- [ ] 7.1 Update `ci-infrastructure` docs/spec references for the GCP execution path.
- [ ] 7.2 Confirm no long-lived SA keys and no secrets in plaintext state across the change.
- [ ] 7.3 Close out GH #79 acceptance checklist and its Phase sub-issues.
