provider "azuredevops" {}

data "azuredevops_group" "project_collection_admins" {
  name = "Project Collection Administrators"
}

module "azuredevops_serviceendpoint" {
  source = "../../"

  project_id = var.project_id

  serviceendpoint_generic = {
    service_endpoint_name = var.generic_endpoint_name
    server_url            = var.generic_endpoint_url
    username              = var.generic_endpoint_username
    password              = var.generic_endpoint_password
    description           = "Managed by Terraform"
  }

  serviceendpoint_permissions = [
    {
      key       = "project-admins"
      principal = data.azuredevops_group.project_collection_admins.id
      permissions = {
        Use        = "Allow"
        Administer = "Deny"
      }
    }
  ]
}
