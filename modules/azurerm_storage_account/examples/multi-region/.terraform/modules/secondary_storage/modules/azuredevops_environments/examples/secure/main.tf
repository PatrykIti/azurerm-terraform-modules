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
  source = "git::https://github.com/PatrykIti/azurerm-terraform-modules//modules/azuredevops_environments?ref=ADOEv1.0.0"

  project_id  = var.project_id
  name        = "ado-env-secure-example"
  description = "Secure environment"

  check_approvals = [
    {
      name                  = "security-approval"
      approvers             = [data.azuredevops_group.project_collection_admins.origin_id]
      requester_can_approve = false
    }
  ]

  check_exclusive_locks = [
    {
      name    = "exclusive-lock"
      timeout = 43200
    }
  ]

  check_business_hours = [
    {
      name       = "Business hours gate"
      start_time = "08:00"
      end_time   = "18:00"
      time_zone  = "UTC"
      monday     = true
      tuesday    = true
      wednesday  = true
      thursday   = true
      friday     = true
      saturday   = false
      sunday     = false
    }
  ]
}
