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
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_storage_account?ref=SAv2.1.0"

  name       = "${var.feed_name_prefix}-basic"
  project_id = var.project_id
}
