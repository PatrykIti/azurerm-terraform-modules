provider "azuredevops" {}

data "azuredevops_group" "project_collection_admins" {
  name = "Project Collection Administrators"
}

locals {
  serviceendpoints = {
    generic = {
      serviceendpoint_generic = {
        service_endpoint_name = var.generic_endpoint_name
        server_url            = var.generic_endpoint_url
        username              = var.generic_endpoint_username
        password              = var.generic_endpoint_password
        description           = "Managed by Terraform"
      }
      serviceendpoint_incomingwebhook = null
      permissions = [
        {
          principal = data.azuredevops_group.project_collection_admins.id
          permissions = {
            Use        = "Allow"
            Administer = "Deny"
          }
        }
      ]
    }
    incomingwebhook = {
      serviceendpoint_generic = null
      serviceendpoint_incomingwebhook = {
        service_endpoint_name = var.incoming_webhook_endpoint_name
        webhook_name          = "example_webhook"
        secret                = var.incoming_webhook_secret
        http_header           = "X-Hub-Signature"
        description           = "Managed by Terraform"
      }
      permissions = []
    }
  }
}

module "azuredevops_serviceendpoint" {
  source   = "../../"
  for_each = local.serviceendpoints

  project_id = var.project_id

  serviceendpoint_generic         = each.value.serviceendpoint_generic
  serviceendpoint_incomingwebhook = each.value.serviceendpoint_incomingwebhook

  serviceendpoint_permissions = each.value.permissions
}
