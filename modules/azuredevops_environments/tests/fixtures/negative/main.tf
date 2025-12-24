provider "azuredevops" {}

module "azuredevops_environments" {
  source = "../.."

  project_id = var.project_id

  environments = {
    dev = {}
  }

  check_approvals = [
    {
      target_resource_type = "environment"
      approvers            = ["00000000-0000-0000-0000-000000000000"]
    }
  ]
}
