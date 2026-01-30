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

data "azuredevops_group" "project_collection_admins" {
  name = "Project Collection Administrators"
}

module "azuredevops_artifacts_feed" {
  source = "git::https://github.com/PatrykIti/azurerm-terraform-modules//modules/azuredevops_artifacts_feed?ref=ADOAFv1.0.0"

  name       = var.feed_name
  project_id = var.project_id

  feed_permissions = [
    {
      key                 = "collection-admins-reader"
      identity_descriptor = data.azuredevops_group.project_collection_admins.descriptor
      role                = "reader"
    }
  ]
}
