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

module "azuredevops_repository" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_postgresql_flexible_server?ref=PGFSv1.1.0"

  project_id = var.project_id
  name       = "${var.repo_name_prefix}-basic"

  initialization = {
    init_type = "Clean"
  }

  files = [
    {
      file                = "README.md"
      content             = "# Repository\n\nManaged by Terraform."
      commit_message      = "Add README"
      overwrite_on_create = true
    }
  ]
}
