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
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_postgresql_flexible_server?ref=PGFSv1.1.0"

  project_id = var.project_id

  webhook = {
    url = var.webhook_url
    build_completed = {
      build_status = "Succeeded"
    }
    http_headers = {
      "X-Test" = "true"
    }
  }

  storage_queue_hook = {
    account_name            = var.account_name
    account_key             = var.account_key
    queue_name              = var.queue_name
    visi_timeout            = 30
    run_state_changed_event = {}
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
