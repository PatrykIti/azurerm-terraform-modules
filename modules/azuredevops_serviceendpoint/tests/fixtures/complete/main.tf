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
    generic = {
      service_endpoint_name = "${var.generic_endpoint_name_prefix}-primary"
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
    secondary = {
      service_endpoint_name = "${var.generic_endpoint_name_prefix}-secondary"
      permissions           = []
    }
  }
}

module "azuredevops_serviceendpoint" {
  source   = "../../.."
  for_each = local.serviceendpoints

  project_id = var.project_id

  serviceendpoint_generic = {
    service_endpoint_name = each.value.service_endpoint_name
    server_url            = var.generic_endpoint_url
    username              = var.generic_endpoint_username
    password              = var.generic_endpoint_password
    description           = "Managed by Terraform"
  }

  serviceendpoint_permissions = each.value.permissions
}
