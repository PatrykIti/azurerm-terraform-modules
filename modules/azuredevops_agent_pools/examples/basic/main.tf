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

provider "random" {}

resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

module "azuredevops_agent_pools" {
  source = "git::https://github.com/PatrykIti/azurerm-terraform-modules//modules/azuredevops_agent_pools?ref=ADOAPv1.0.0"

  name = "${var.pool_name_prefix}-${random_string.suffix.result}"

  agent_queues = [
    {
      key        = "default"
      project_id = var.project_id
    }
  ]
}
