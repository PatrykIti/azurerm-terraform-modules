provider "azuredevops" {}

module "azuredevops_artifacts_feed" {
  source = "../../"

  feeds = {
    project = {
      name       = var.feed_name
      project_id = var.project_id
    }
  }
}
