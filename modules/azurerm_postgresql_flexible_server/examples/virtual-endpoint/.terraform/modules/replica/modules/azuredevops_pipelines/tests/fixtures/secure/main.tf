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

data "azuredevops_group" "project_collection_admins" {
  name = "Project Collection Administrators"
}

resource "azuredevops_git_repository" "example" {
  project_id = var.project_id
  name       = "repo-ado-sec-${var.random_suffix}"

  initialization {
    init_type = "Clean"
  }
}

resource "azuredevops_serviceendpoint_generic" "example" {
  project_id            = var.project_id
  service_endpoint_name = "se-ado-sec-${var.random_suffix}"
  server_url            = var.service_endpoint_url
  username              = var.service_endpoint_username
  password              = var.service_endpoint_password
  description           = "Managed by Terraform"
}

module "azuredevops_pipelines" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_postgresql_flexible_server?ref=PGFSv1.1.0"

  project_id = var.project_id

  name = "pip-ado-sec-${var.random_suffix}"

  repository = {
    repo_type = "TfsGit"
    repo_id   = azuredevops_git_repository.example.id
    yml_path  = var.yaml_path
  }

  build_definition_permissions = [
    {
      key       = "secure-admins"
      principal = data.azuredevops_group.project_collection_admins.id
      permissions = {
        ViewBuildDefinition = "Allow"
        EditBuildDefinition = "Deny"
      }
      replace = false
    }
  ]

  pipeline_authorizations = [
    {
      key         = "secure-endpoint"
      resource_id = azuredevops_serviceendpoint_generic.example.id
      type        = "endpoint"
    }
  ]
}
