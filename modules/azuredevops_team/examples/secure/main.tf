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
  source = "git::https://github.com/PatrykIti/azurerm-terraform-modules//modules/azuredevops_team?ref=ADOTv1.0.0"

  project_id  = var.project_id
  name        = var.team_name
  description = "Security review team"

  team_administrators = [
    {
      key               = "security-admins"
      admin_descriptors = [data.azuredevops_group.project_collection_admins.descriptor]
      mode              = "overwrite"
    }
  ]
}
