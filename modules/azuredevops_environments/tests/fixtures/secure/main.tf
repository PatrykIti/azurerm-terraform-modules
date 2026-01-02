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

module "azuredevops_environments" {
  source = "../../../"

  project_id  = var.project_id
  name        = var.environment_name
  description = "Secure fixture environment"

  check_approvals = [
    {
      name                  = "secure-approval"
      approvers             = [data.azuredevops_group.project_collection_admins.origin_id]
      requester_can_approve = false
    }
  ]

  check_exclusive_locks = [
    {
      name    = "secure-lock"
      timeout = 43200
    }
  ]
}
