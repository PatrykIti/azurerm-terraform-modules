provider "azuredevops" {}

module "azuredevops_artifacts_feed" {
  source = "../../"

  name       = var.feed_name
  project_id = var.project_id
}
