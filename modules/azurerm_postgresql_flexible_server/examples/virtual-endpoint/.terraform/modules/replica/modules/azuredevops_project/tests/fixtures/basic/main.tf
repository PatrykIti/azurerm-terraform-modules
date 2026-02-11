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
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_postgresql_flexible_server?ref=PGFSv1.1.0"

  name               = var.project_name
  description        = "Test basic Azure DevOps project"
  visibility         = "private"
  version_control    = "Git"
  work_item_template = "Agile"

  project_tags = ["test", "basic"]
}
