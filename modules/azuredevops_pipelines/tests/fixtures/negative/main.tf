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

module "azuredevops_pipelines" {
  source = "../../.."

  project_id = var.project_id
  name       = "pip-ado-neg-${var.random_suffix}"

  repository = {
    repo_id   = "00000000-0000-0000-0000-000000000000"
    repo_type = "TfsGit"
    yml_path  = "azure-pipelines.yml"
  }

  pipeline_authorizations = [
    {
      resource_id = "00000000-0000-0000-0000-000000000000"
      type        = "endpoint"
      pipeline_id = ""
    }
  ]
}
