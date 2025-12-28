provider "azuredevops" {}

module "azuredevops_artifacts_feed" {
  source = "../../"

  name        = var.feed_name
  project_id  = var.project_id
  description = "Complete artifacts feed example"
  features = {
    permanent_delete = false
    restore          = false
  }

  feed_permissions = [
    {
      key                 = "project-contributor"
      identity_descriptor = var.principal_descriptor
      role                = "contributor"
    }
  ]

  feed_retention_policies = [
    {
      key                                       = "project-retention"
      count_limit                               = 20
      days_to_keep_recently_downloaded_packages = 30
    }
  ]
}
