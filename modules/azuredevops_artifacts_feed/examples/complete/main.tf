provider "azuredevops" {}

module "azuredevops_artifacts_feed" {
  source = "../../"

  feeds = {
    project = {
      name       = var.feed_name
      project_id = var.project_id
      features = {
        permanent_delete = false
        restore          = false
      }
    }
  }

  feed_permissions = [
    {
      feed_key            = "project"
      identity_descriptor = var.principal_descriptor
      role                = "contributor"
      project_id          = var.project_id
    }
  ]

  feed_retention_policies = [
    {
      feed_key                                  = "project"
      project_id                                = var.project_id
      count_limit                               = 20
      days_to_keep_recently_downloaded_packages = 30
    }
  ]
}
