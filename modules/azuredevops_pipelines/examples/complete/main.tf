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
  name       = var.repo_name

  initialization {
    init_type = "Clean"
  }
}

resource "azuredevops_serviceendpoint_generic" "example" {
  project_id            = var.project_id
  service_endpoint_name = var.service_endpoint_name
  server_url            = var.service_endpoint_url
  username              = var.service_endpoint_username
  password              = var.service_endpoint_password
  description           = "Managed by Terraform"
}

locals {
  pipelines = {
    app = {
      name     = var.pipeline_app_name
      path     = "\\Pipelines"
      yml_path = var.yaml_path
      schedules = [
        {
          branch_filter = {
            include = ["main"]
            exclude = ["experimental"]
          }
          days_to_build              = ["Mon", "Wed", "Fri"]
          schedule_only_with_changes = true
          start_hours                = 8
          start_minutes              = 30
          time_zone                  = "(UTC) Coordinated Universal Time"
        }
      ]
      variables = [
        {
          name  = "ENV"
          value = "dev"
        }
      ]
      build_folders = [
        {
          key         = "pipelines"
          path        = "\\Pipelines"
          description = "Pipeline folder"
        }
      ]
      pipeline_authorizations = [
        {
          key         = "app-endpoint"
          resource_id = azuredevops_serviceendpoint_generic.example.id
          type        = "endpoint"
        }
      ]
    }
    release = {
      name     = var.pipeline_release_name
      path     = "\\Pipelines"
      yml_path = "azure-pipelines-release.yml"
      ci_trigger = {
        use_yaml = true
      }
      schedules     = []
      variables     = []
      build_folders = []
      pipeline_authorizations = [
        {
          key         = "release-endpoint"
          resource_id = azuredevops_serviceendpoint_generic.example.id
          type        = "endpoint"
        }
      ]
    }
  }
}

module "azuredevops_pipelines" {
  for_each = local.pipelines

  source = "git::https://github.com/PatrykIti/azurerm-terraform-modules//modules/azuredevops_pipelines?ref=ADOPIv1.0.0"

  project_id = var.project_id
  name       = each.value.name
  path       = each.value.path

  repository = {
    repo_type = "TfsGit"
    repo_id   = azuredevops_git_repository.example.id
    yml_path  = each.value.yml_path
  }

  ci_trigger = try(each.value.ci_trigger, null)

  schedules = each.value.schedules
  variables = each.value.variables

  build_folders           = each.value.build_folders
  pipeline_authorizations = each.value.pipeline_authorizations
}
