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

module "azuredevops_artifacts_feed" {
  source = "git::https://github.com/PatrykIti/azurerm-terraform-modules//modules/azuredevops_artifacts_feed?ref=ADOAF1.0.0"

  name       = var.feed_name
  project_id = var.project_id
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
