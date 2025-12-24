provider "azuredevops" {}

module "azuredevops_artifacts_feed" {
  source = "../../"

  feeds = {
    network = {
      name       = "${var.feed_name_prefix}-network"
      project_id = var.project_id
    }
  }
}
