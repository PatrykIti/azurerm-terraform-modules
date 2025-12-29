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
  source = "../../../"

  project_id = var.project_id

  webhook = {
    url = var.webhook_url
  }
}
