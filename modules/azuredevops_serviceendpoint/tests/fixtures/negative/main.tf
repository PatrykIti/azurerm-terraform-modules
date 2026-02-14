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

module "azuredevops_serviceendpoint" {
  source = "../../.."

  project_id = var.project_id

  serviceendpoint_generic = {
    service_endpoint_name = "negative-endpoint"
    server_url            = "https://example.endpoint.local"
  }

  serviceendpoint_permissions = [
    {
      principal = "vssgp.duplicate"
      permissions = {
        Use = "Allow"
      }
    },
    {
      principal = "vssgp.duplicate"
      permissions = {
        Use = "Allow"
      }
    }
  ]
}
