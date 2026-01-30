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
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_storage_account?ref=SAv2.1.0"

  name       = "${var.feed_name_prefix}-secure"
  project_id = var.project_id

  feed_permissions = [
    {
      key                 = "secure-reader"
      identity_descriptor = data.azuredevops_group.readers.descriptor
      role                = "reader"
    }
  ]

  feed_retention_policies = [
    {
      key                                       = "secure-retention"
      count_limit                               = 10
      days_to_keep_recently_downloaded_packages = 14
    }
  ]
}
