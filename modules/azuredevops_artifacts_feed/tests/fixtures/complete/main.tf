terraform {
  required_version = ">= 1.12.2"
  required_providers {
  
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = "1.12.2"
    }
  }
}

provider "azuredevops" {}

data "azuredevops_group" "readers" {
  project_id = var.project_id
  name       = "Readers"
}

module "azuredevops_artifacts_feed" {
  source = "../../../"

  feeds = {
    project = {
      name        = "${var.feed_name_prefix}-complete"
      project_id  = var.project_id
      features = {
        permanent_delete = false
        restore          = false
      }
    }
  }

  feed_permissions = [
    {
      key                 = "project-contributor"
      feed_key            = "project"
      identity_descriptor = data.azuredevops_group.readers.descriptor
      role                = "contributor"
    }
  ]

  feed_retention_policies = [
    {
      key                                       = "project-retention"
      feed_key                                  = "project"
      count_limit                               = 20
      days_to_keep_recently_downloaded_packages = 30
    }
  ]
}
