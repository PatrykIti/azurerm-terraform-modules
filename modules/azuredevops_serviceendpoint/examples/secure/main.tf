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

module "azuredevops_serviceendpoint" {
  source = "../../"

  project_id = var.project_id

  serviceendpoint_generic = [
    {
      service_endpoint_name = "${var.generic_endpoint_name_prefix}-${random_string.suffix.result}"
      server_url            = var.generic_endpoint_url
      username              = var.generic_endpoint_username
      password              = var.generic_endpoint_password
      description           = "Managed by Terraform"
    }
  ]

  serviceendpoint_permissions = [
    {
      principal = data.azuredevops_group.project_collection_admins.id
      permissions = {
        Use        = "Allow"
        Administer = "Deny"
      }
    }
  ]
}
