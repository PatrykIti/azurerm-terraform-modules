provider "azuredevops" {}

module "azuredevops_environments" {
  source = "../.."

  project_id = var.project_id
  name       = var.environment_name

  check_approvals = [
    {
      key                  = "invalid-check"
      target_resource_type = "invalid"
      approvers            = ["00000000-0000-0000-0000-000000000000"]
    }
  ]
}
