provider "azuredevops" {}

module "azuredevops_artifacts_feed" {
  source = "../../"

  feeds = {
    secure = {
      name        = var.feed_name
      project_id  = var.project_id
    }
  }

  feed_permissions = [
    {
      key                 = "secure-reader"
      feed_key            = "secure"
      identity_descriptor = var.principal_descriptor
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
