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

  serviceendpoint_permissions = [
    {
      principal = "vssgp.invalid"
      permissions = {
        Use = "Allow"
      }
    }
  ]
}
