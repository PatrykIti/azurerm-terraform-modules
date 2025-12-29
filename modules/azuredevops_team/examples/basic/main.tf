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

module "azuredevops_team" {
  source = "../../"

  project_id  = var.project_id
  name        = var.team_name
  description = "Core delivery team"

  team_members = length(var.member_descriptors) > 0 ? [
    {
      key                = "core-members"
      member_descriptors = var.member_descriptors
    }
  ] : []
}
