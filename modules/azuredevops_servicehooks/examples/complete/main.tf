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
  webhooks = {
    builds = {
      url = var.webhook_url
      build_completed = {
        definition_name = var.pipeline_name
        build_status    = "Succeeded"
      }
      http_headers = {
        "X-Test" = "true"
      }
    }
    workitems = {
      url = var.webhook_url
      work_item_updated = {
        work_item_type = "Bug"
        changed_fields = "System.State"
      }
    }
  }
}

module "azuredevops_servicehooks" {
  for_each = local.webhooks
  source   = "../../"

  project_id = var.project_id
  webhook    = each.value
}
