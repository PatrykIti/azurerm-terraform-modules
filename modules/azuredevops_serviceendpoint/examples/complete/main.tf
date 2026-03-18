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

locals {
  serviceendpoints = {
    shared = {
      service_endpoint_name = "${var.generic_endpoint_name}-shared"
      server_url            = var.generic_endpoint_url
      username              = var.generic_endpoint_username
      password              = var.generic_endpoint_password
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
    readonly = {
      service_endpoint_name = "${var.generic_endpoint_name}-readonly"
      server_url            = var.generic_endpoint_url
      username              = var.generic_endpoint_username
      password              = var.generic_endpoint_password
      permissions           = []
    }
  }
}

module "azuredevops_serviceendpoint" {
  source   = "../../"
  for_each = local.serviceendpoints

  project_id = var.project_id

  serviceendpoint_generic = {
    service_endpoint_name = each.value.service_endpoint_name
    server_url            = each.value.server_url
    username              = each.value.username
    password              = each.value.password
    description           = "Managed by Terraform"
  }

  serviceendpoint_permissions = each.value.permissions
}
