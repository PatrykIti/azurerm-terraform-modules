provider "azuredevops" {}

module "azuredevops_serviceendpoint" {
  source = "../.."

  project_id = var.project_id

  serviceendpoint_permissions = [
    {
      principal = ""
      permissions = {
        Use = "Allow"
      }
    }
  ]
}
