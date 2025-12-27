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
  source = "../../../"

  project_id = var.project_id

  teams = {
    security = {
      name        = "${var.team_name_prefix}-security"
      description = "Security review team"
    }
  }

  team_administrators = [
    {
      key               = "security-admins"
      team_key          = "security"
      admin_descriptors = [data.azuredevops_group.project_collection_admins.descriptor]
      mode              = "overwrite"
    }
  ]
}
