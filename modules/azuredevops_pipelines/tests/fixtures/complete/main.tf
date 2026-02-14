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

locals {
  folder_path = "\\Pipelines-${var.random_suffix}"

  pipelines = {
    app = {
      name     = "pip-ado-cmp-app-${var.random_suffix}"
      path     = local.folder_path
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
      pipeline_authorizations = [
        {
          key         = "app-endpoint"
          resource_id = azuredevops_serviceendpoint_generic.example.id
          type        = "endpoint"
        }
      ]
    }
    release = {
      name     = "pip-ado-cmp-rel-${var.random_suffix}"
      path     = local.folder_path
      yml_path = "azure-pipelines-release.yml"
      ci_trigger = {
        use_yaml = true
      }
      schedules = []
      variables = []
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

  source = "../../.."

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

  pipeline_authorizations = each.value.pipeline_authorizations
}
