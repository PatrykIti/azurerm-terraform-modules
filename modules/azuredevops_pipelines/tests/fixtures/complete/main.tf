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

resource "azuredevops_git_repository" "example" {
  project_id = var.project_id
  name       = "repo-ado-cmp-${var.random_suffix}"

  initialization {
    init_type = "Clean"
  }
}

resource "azuredevops_serviceendpoint_generic" "example" {
  project_id            = var.project_id
  service_endpoint_name = "se-ado-cmp-${var.random_suffix}"
  server_url            = var.service_endpoint_url
  username              = var.service_endpoint_username
  password              = var.service_endpoint_password
  description           = "Managed by Terraform"
}

module "azuredevops_pipelines" {
  source = "../../.."

  project_id = var.project_id

  build_folders = [
    {
      path        = "\\Pipelines-${var.random_suffix}"
      description = "Pipeline folder"
      key         = "pipelines"
    }
  ]

  build_definitions = {
    app = {
      name = "pip-ado-cmp-app-${var.random_suffix}"
      path = "\\Pipelines-${var.random_suffix}"
      repository = {
        repo_type = "TfsGit"
        repo_id   = azuredevops_git_repository.example.id
        yml_path  = var.yaml_path
      }
      ci_trigger = {
        use_yaml = true
      }
    }
    release = {
      name = "pip-ado-cmp-rel-${var.random_suffix}"
      repository = {
        repo_type = "TfsGit"
        repo_id   = azuredevops_git_repository.example.id
        yml_path  = "azure-pipelines-release.yml"
      }
    }
  }

  pipeline_authorizations = [
    {
      key          = "app-endpoint"
      resource_id  = azuredevops_serviceendpoint_generic.example.id
      type         = "endpoint"
      pipeline_key = "app"
    },
    {
      key          = "release-endpoint"
      resource_id  = azuredevops_serviceendpoint_generic.example.id
      type         = "endpoint"
      pipeline_key = "release"
    }
  ]
}
