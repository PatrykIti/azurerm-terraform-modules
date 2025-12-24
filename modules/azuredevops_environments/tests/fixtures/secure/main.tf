provider "azuredevops" {}

provider "random" {}

resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

data "azuredevops_group" "project_collection_admins" {
  name = "Project Collection Administrators"
}

module "azuredevops_environments" {
  source = "../.."

  project_id = var.project_id

  environments = {
    secure = {
      name        = "${var.environment_name_prefix}-${random_string.suffix.result}"
      description = "Secure environment"
    }
  }

  check_approvals = [
    {
      target_environment_key = "secure"
      target_resource_type   = "environment"
      approvers              = [data.azuredevops_group.project_collection_admins.id]
      requester_can_approve  = false
    }
  ]

  check_exclusive_locks = [
    {
      target_environment_key = "secure"
      target_resource_type   = "environment"
      timeout                = 43200
    }
  ]
}
