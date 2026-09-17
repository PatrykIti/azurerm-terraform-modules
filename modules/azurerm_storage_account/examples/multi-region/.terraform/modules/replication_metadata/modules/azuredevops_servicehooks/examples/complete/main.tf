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

locals {
  servicehooks = {
    webhook = {
      webhook = {
        url = var.webhook_url
        build_completed = {
          definition_name = var.pipeline_name
          build_status    = "Succeeded"
        }
        http_headers = {
          "X-Test" = "true"
        }
      }
      storage_queue_hook = null
    }
    storage_queue = {
      webhook = null
      storage_queue_hook = {
        account_name = var.account_name
        account_key  = var.account_key
        queue_name   = var.queue_name
        visi_timeout = 30
        run_state_changed_event = {
          run_state_filter  = "Completed"
          run_result_filter = "Succeeded"
        }
      }
    }
  }
}

module "azuredevops_servicehooks" {
  for_each = local.servicehooks
  source   = "git::https://github.com/PatrykIti/azurerm-terraform-modules//modules/azuredevops_servicehooks?ref=ADOSHv1.0.0"

  project_id         = var.project_id
  webhook            = each.value.webhook
  storage_queue_hook = each.value.storage_queue_hook
}
