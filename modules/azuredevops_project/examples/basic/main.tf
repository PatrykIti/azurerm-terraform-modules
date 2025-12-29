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

module "azuredevops_project" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azuredevops_project?ref=ADOP1.1.0"

  name               = var.project_name
  description        = "Basic Azure DevOps project managed by Terraform"
  visibility         = "private"
  version_control    = "Git"
  work_item_template = "Agile"

  project_tags = ["basic", "terraform"]
}
