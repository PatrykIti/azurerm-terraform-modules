provider "azuredevops" {}

module "azuredevops_artifacts_feed" {
  source = "../../"

  feeds = {
    invalid = {
      name       = "${var.feed_name_prefix}-invalid"
      project_id = var.project_id
    }
  }

  feed_permissions = [
    {
      feed_id            = "00000000-0000-0000-0000-000000000000"
      feed_key           = "invalid"
      identity_descriptor = "vssgp.Uy0xLTktMTIzNDU2"
      role               = "reader"
      project_id         = var.project_id
    }
  ]
}
