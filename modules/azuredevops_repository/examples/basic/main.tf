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
  source = "git::https://github.com/PatrykIti/azurerm-terraform-modules//modules/azuredevops_repository?ref=ADORv1.0.3"

  project_id = var.project_id
  name       = "ado-repo-basic"

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
