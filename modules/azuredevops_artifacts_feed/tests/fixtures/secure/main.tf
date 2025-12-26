provider "azuredevops" {}

data "azuredevops_group" "readers" {
  project_id = var.project_id
  name       = "Readers"
}

module "azuredevops_artifacts_feed" {
  source = "../../"

  feeds = {
    secure = {
      name        = "${var.feed_name_prefix}-secure"
      project_id  = var.project_id
      description = "Secure fixture feed."
    }
  }

  feed_permissions = [
    {
      key                 = "secure-reader"
      feed_key            = "secure"
      identity_descriptor = data.azuredevops_group.readers.descriptor
      role                = "reader"
    }
  ]

  feed_retention_policies = [
    {
      key                                       = "secure-retention"
      feed_key                                  = "secure"
      count_limit                               = 10
      days_to_keep_recently_downloaded_packages = 14
    }
  ]
}
