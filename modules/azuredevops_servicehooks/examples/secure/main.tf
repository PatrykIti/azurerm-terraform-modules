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

module "azuredevops_servicehooks" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azuredevops_servicehooks?ref=ADOSH1.0.0"

  project_id = var.project_id

  webhook = {
    url = var.webhook_url
    work_item_updated = {
      work_item_type = "Bug"
      area_path      = var.area_path
      changed_fields = "System.State"
    }
  }

  servicehook_permissions = [
    {
      key       = "restricted-permissions"
      principal = var.principal_descriptor
      permissions = {
        ViewSubscriptions   = "Allow"
        EditSubscriptions   = "Deny"
        DeleteSubscriptions = "Deny"
        PublishEvents       = "Deny"
      }
    }
  ]
}
