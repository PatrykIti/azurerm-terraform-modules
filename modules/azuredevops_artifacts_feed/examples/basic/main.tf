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

module "azuredevops_artifacts_feed" {
  source = "../../"

  name       = var.feed_name
  project_id = var.project_id
}
