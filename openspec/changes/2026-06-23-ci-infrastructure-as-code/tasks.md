## 1. IaC foundation

- [x] 1.1 Add an OpenTofu root with the `google` and `integrations/github` providers pinned.
- [x] 1.2 Configure a versioned GCS bucket as the remote state backend.
- [x] 1.3 Add tflint config and a plan-on-PR GHA workflow (auth via WIF). _(trivy/checkov: follow-up.)_

## 2. Keyless auth (WIF)

- [x] 2.1 Module `wif/`: a Workload Identity pool + provider trusting this repo's GHA OIDC.
- [x] 2.2 Grant the GHA principal least-privilege IAM to execute the eval job and read secrets.
- [x] 2.3 Confirm no long-lived service-account keys exist anywhere in the config.

## 3. GPU eval runner

- [ ] 3.1 Request the NVIDIA L4 quota and confirm Cloud Run GPU-on-Jobs is GA in the region. _(external prereq)_
- [ ] 3.2 Build + push the Artifact Registry image (Ollama + promptfoo + baked models). _(Dockerfile written; build needs GCP)_
- [x] 3.3 Module `cloud-run-eval/`: a Cloud Run Job on an L4, reading secrets from Secret Manager.
- [ ] 3.4 Point Skill CI at the job (`gcloud run jobs execute --wait`); propagate pass/fail; push artifacts to GCS; keep the sticky comment posting results. _(skill-ci cutover after apply)_

## 4. GitHub config as code

- [x] 4.1 Module `github-repo/`: repo settings, branch protection, the signed-commits ruleset, the `evals` environment + reviewers + prevent-self-review, labels, Actions secrets/vars.
- [ ] 4.2 Verify a destroy-then-reapply reproduces the live settings (drift check). _(needs apply)_

## 5. Restore coverage

- [ ] 5.1 Un-park the 5 disabled behaviours (EN+PL) and confirm they grade within the documented time budget on the L4 runner. _(needs working GPU runner)_

## 6. Document & finish

- [x] 6.1 Add an IaC section to `AGENTS.md` / `CONTRIBUTING.md` (how to plan/apply, state, WIF).
- [x] 6.2 `openspec validate 2026-06-23-ci-infrastructure-as-code --strict` clean.
- [ ] 6.3 Verify `./run-tests.sh` still green locally; confirm CI green on the L4 runner. _(after cutover)_
