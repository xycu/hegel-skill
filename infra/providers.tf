provider "google" {
  project = var.project_id
  region  = var.region
}

# Auth comes from a token in the environment (GITHUB_TOKEN / GH_TOKEN). In CI the
# token is minted by the workflow; locally use a fine-grained PAT with repo admin.
provider "github" {
  owner = var.github_owner
}
