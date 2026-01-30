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

data "azuredevops_group" "project_readers" {
  project_id = var.project_id
  name       = "Readers"
}

module "azuredevops_team" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_storage_account?ref=SAv2.1.0"

  project_id  = var.project_id
  name        = "ado-team-cmp-${var.random_suffix}"
  description = "Platform engineering team"

  team_members = [
    {
      key                = "team-members"
      member_descriptors = [data.azuredevops_group.project_readers.descriptor]
    }
  ]

  team_administrators = [
    {
      key               = "team-admins"
      admin_descriptors = [data.azuredevops_group.project_collection_admins.descriptor]
    }
  ]
}
