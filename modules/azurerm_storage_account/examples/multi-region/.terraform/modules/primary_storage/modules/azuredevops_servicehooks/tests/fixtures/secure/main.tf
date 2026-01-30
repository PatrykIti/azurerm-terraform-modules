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

data "azuredevops_group" "readers" {
  project_id = var.project_id
  name       = "Readers"
}

module "azuredevops_servicehooks" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_storage_account?ref=SAv2.1.0"

  project_id = var.project_id

  webhook = {
    url = var.webhook_url
    work_item_updated = {
      work_item_type = "Bug"
    }
  }

  servicehook_permissions = [
    {
      key       = "readers-permissions"
      principal = data.azuredevops_group.readers.id
      permissions = {
        ViewSubscriptions   = "Allow"
        EditSubscriptions   = "Deny"
        DeleteSubscriptions = "Deny"
        PublishEvents       = "Deny"
      }
    }
  ]
}
