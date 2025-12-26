provider "azuredevops" {}

data "azuredevops_group" "project_collection_admins" {
  name = "Project Collection Administrators"
}

module "azuredevops_environments" {
  source = "../.."

  project_id  = var.project_id
  name        = var.environment_name
  description = "Secure fixture environment"

  check_approvals = [
    {
      key                  = "secure-approval"
      target_resource_type = "environment"
      approvers            = [data.azuredevops_group.project_collection_admins.id]
      requester_can_approve = false
    }
  ]

  check_exclusive_locks = [
    {
      key                  = "secure-lock"
      target_resource_type = "environment"
      timeout              = 43200
    }
  ]
}
