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

module "azuredevops_team" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_storage_account?ref=SAv2.1.0"

  project_id  = var.project_id
  name        = "ado-team-sec-${var.random_suffix}"
  description = "Security review team"

  team_administrators = [
    {
      key               = "security-admins"
      admin_descriptors = [data.azuredevops_group.project_collection_admins.descriptor]
      mode              = "overwrite"
    }
  ]
}
