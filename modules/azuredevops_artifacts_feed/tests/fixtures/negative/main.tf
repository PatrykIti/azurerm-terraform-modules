provider "azuredevops" {}

module "azuredevops_artifacts_feed" {
  source = "../../"

  feeds = {
    valid = {
      name       = "${var.feed_name_prefix}-valid"
      project_id = var.project_id
    }
  }

  feed_permissions = [
    {
      feed_key            = "missing"
      identity_descriptor = "vssgp.Uy0xLTktMTIzNDU2"
      role                = "reader"
      project_id          = var.project_id
    }
  ]
}
