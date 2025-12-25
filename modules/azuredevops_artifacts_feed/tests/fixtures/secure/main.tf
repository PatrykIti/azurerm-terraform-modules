provider "azuredevops" {}

data "azuredevops_group" "readers" {
  project_id = var.project_id
  name       = "Readers"
}

module "azuredevops_artifacts_feed" {
  source = "../../"

  feeds = {
    secure = {
      name       = "${var.feed_name_prefix}-secure"
      project_id = var.project_id
    }
  }

  feed_permissions = [
    {
      feed_key            = "secure"
      identity_descriptor = data.azuredevops_group.readers.descriptor
      role                = "reader"
      project_id          = var.project_id
    }
  ]

  feed_retention_policies = [
    {
      feed_key                                  = "secure"
      project_id                                = var.project_id
      count_limit                               = 10
      days_to_keep_recently_downloaded_packages = 14
    }
  ]
}
