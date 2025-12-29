# Terraform Azure DevOps Pipelines Module

## Module Version

<!-- BEGIN_VERSION -->
Current version: **vUnreleased**
<!-- END_VERSION -->

## Description

Azure DevOps pipelines module for managing a single build definition (use module-level for_each for multiples), folders, permissions, and authorizations.

## Usage

```hcl
provider "azuredevops" {}

module "azuredevops_pipelines" {
  source = "path/to/azuredevops_pipelines"

  project_id = "00000000-0000-0000-0000-000000000000"

  name = "example-pipeline"

  repository = {
    repo_type = "TfsGit"
    repo_id   = "00000000-0000-0000-0000-000000000000"
    yml_path  = "azure-pipelines.yml"
  }
}
```

## Examples

<!-- BEGIN_EXAMPLES -->
- [Basic](examples/basic) - This example demonstrates creating a basic YAML pipeline backed by a Git repository.
- [Complete](examples/complete) - This example demonstrates creating multiple YAML pipelines with folders and authorizations.
- [Secure](examples/secure) - This example demonstrates a pipeline with restricted permissions and explicit authorizations.
<!-- END_EXAMPLES -->

<!-- BEGIN_TF_DOCS -->


## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.12.2 |
| <a name="requirement_azuredevops"></a> [azuredevops](#requirement\_azuredevops) | 1.12.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuredevops"></a> [azuredevops](#provider\_azuredevops) | 1.12.2 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azuredevops_build_definition.build_definition](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/build_definition) | resource |
| [azuredevops_build_definition_permissions.build_definition_permissions](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/build_definition_permissions) | resource |
| [azuredevops_build_folder.build_folder](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/build_folder) | resource |
| [azuredevops_build_folder_permissions.build_folder_permissions](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/build_folder_permissions) | resource |
| [azuredevops_pipeline_authorization.pipeline_authorization](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/pipeline_authorization) | resource |
| [azuredevops_pipeline_authorization.resource_authorization](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/pipeline_authorization) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_agent_pool_name"></a> [agent\_pool\_name](#input\_agent\_pool\_name) | Agent pool name for the build definition. | `string` | `null` | no |
| <a name="input_agent_specification"></a> [agent\_specification](#input\_agent\_specification) | Agent specification for the build definition. | `string` | `null` | no |
| <a name="input_build_completion_trigger"></a> [build\_completion\_trigger](#input\_build\_completion\_trigger) | Build completion trigger configuration. | <pre>object({<br/>    build_definition_id = string<br/>    branch_filter = object({<br/>      include = list(string)<br/>      exclude = optional(list(string), [])<br/>    })<br/>  })</pre> | `null` | no |
| <a name="input_build_definition_permissions"></a> [build\_definition\_permissions](#input\_build\_definition\_permissions) | List of build definition permissions to assign. | <pre>list(object({<br/>    key                 = optional(string)<br/>    build_definition_id = optional(string)<br/>    principal           = string<br/>    permissions         = map(string)<br/>    replace             = optional(bool, true)<br/>  }))</pre> | `[]` | no |
| <a name="input_build_folder_permissions"></a> [build\_folder\_permissions](#input\_build\_folder\_permissions) | List of build folder permissions to assign. | <pre>list(object({<br/>    key         = optional(string)<br/>    path        = string<br/>    principal   = string<br/>    permissions = map(string)<br/>    replace     = optional(bool, true)<br/>  }))</pre> | `[]` | no |
| <a name="input_build_folders"></a> [build\_folders](#input\_build\_folders) | List of build folders to manage. | <pre>list(object({<br/>    key         = optional(string)<br/>    path        = string<br/>    description = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_ci_trigger"></a> [ci\_trigger](#input\_ci\_trigger) | CI trigger configuration for the build definition. | <pre>object({<br/>    use_yaml = optional(bool)<br/>    override = optional(object({<br/>      branch_filter = object({<br/>        include = list(string)<br/>        exclude = optional(list(string), [])<br/>      })<br/>      batch = optional(bool)<br/>      path_filter = optional(object({<br/>        include = optional(list(string))<br/>        exclude = optional(list(string))<br/>      }))<br/>      max_concurrent_builds_per_branch = optional(number)<br/>      polling_interval                 = optional(number)<br/>    }))<br/>  })</pre> | `null` | no |
| <a name="input_features"></a> [features](#input\_features) | Feature flags for the build definition. | <pre>object({<br/>    skip_first_run = optional(bool)<br/>  })</pre> | `null` | no |
| <a name="input_job_authorization_scope"></a> [job\_authorization\_scope](#input\_job\_authorization\_scope) | Job authorization scope for the build definition. | `string` | `null` | no |
| <a name="input_jobs"></a> [jobs](#input\_jobs) | Job definitions for the build definition. | <pre>list(object({<br/>    name                             = string<br/>    ref_name                         = string<br/>    condition                        = string<br/>    job_timeout_in_minutes           = optional(number)<br/>    job_cancel_timeout_in_minutes    = optional(number)<br/>    job_authorization_scope          = optional(string)<br/>    allow_scripts_auth_access_option = optional(bool)<br/>    dependencies = optional(list(object({<br/>      scope = string<br/>    })))<br/>    target = object({<br/>      type    = string<br/>      demands = optional(list(string))<br/>      execution_options = object({<br/>        type              = string<br/>        multipliers       = optional(list(string))<br/>        max_concurrency   = optional(number)<br/>        continue_on_error = optional(bool)<br/>      })<br/>    })<br/>  }))</pre> | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the build definition (pipeline). | `string` | n/a | yes |
| <a name="input_path"></a> [path](#input\_path) | Optional folder path for the build definition. | `string` | `null` | no |
| <a name="input_pipeline_authorizations"></a> [pipeline\_authorizations](#input\_pipeline\_authorizations) | List of pipeline authorizations to manage. Set key when resource\_id is computed to keep for\_each stable. | <pre>list(object({<br/>    key                 = optional(string)<br/>    resource_id         = string<br/>    type                = string<br/>    pipeline_id         = optional(string)<br/>    pipeline_project_id = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Azure DevOps project ID. | `string` | n/a | yes |
| <a name="input_pull_request_trigger"></a> [pull\_request\_trigger](#input\_pull\_request\_trigger) | Pull request trigger configuration for the build definition. | <pre>object({<br/>    use_yaml       = optional(bool)<br/>    initial_branch = optional(string)<br/>    forks = optional(object({<br/>      enabled       = bool<br/>      share_secrets = bool<br/>    }))<br/>    override = optional(object({<br/>      branch_filter = object({<br/>        include = list(string)<br/>        exclude = optional(list(string), [])<br/>      })<br/>      auto_cancel = optional(bool)<br/>      path_filter = optional(object({<br/>        include = optional(list(string))<br/>        exclude = optional(list(string))<br/>      }))<br/>    }))<br/>  })</pre> | `null` | no |
| <a name="input_queue_status"></a> [queue\_status](#input\_queue\_status) | Queue status for the build definition (enabled, paused, disabled). | `string` | `null` | no |
| <a name="input_repository"></a> [repository](#input\_repository) | Repository settings for the build definition. | <pre>object({<br/>    repo_id               = string<br/>    repo_type             = string<br/>    branch_name           = optional(string)<br/>    service_connection_id = optional(string)<br/>    yml_path              = optional(string)<br/>    github_enterprise_url = optional(string)<br/>    url                   = optional(string)<br/>    report_build_status   = optional(bool)<br/>  })</pre> | n/a | yes |
| <a name="input_resource_authorizations"></a> [resource\_authorizations](#input\_resource\_authorizations) | Legacy list of resource authorizations to manage. Prefer pipeline\_authorizations; set key when resource\_id is computed to keep for\_each stable. | <pre>list(object({<br/>    key           = optional(string)<br/>    resource_id   = string<br/>    authorized    = bool<br/>    definition_id = optional(string)<br/>    type          = string<br/>  }))</pre> | `[]` | no |
| <a name="input_schedules"></a> [schedules](#input\_schedules) | List of scheduled triggers for the build definition. | <pre>list(object({<br/>    branch_filter = object({<br/>      include = list(string)<br/>      exclude = optional(list(string), [])<br/>    })<br/>    days_to_build              = list(string)<br/>    schedule_only_with_changes = optional(bool)<br/>    start_hours                = optional(number)<br/>    start_minutes              = optional(number)<br/>    time_zone                  = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_variable_groups"></a> [variable\_groups](#input\_variable\_groups) | Variable group IDs to link to the build definition. | `list(string)` | `null` | no |
| <a name="input_variables"></a> [variables](#input\_variables) | Variables to set for the build definition. | <pre>list(object({<br/>    name           = string<br/>    value          = optional(string)<br/>    secret_value   = optional(string)<br/>    is_secret      = optional(bool)<br/>    allow_override = optional(bool)<br/>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_build_definition_id"></a> [build\_definition\_id](#output\_build\_definition\_id) | ID of the build definition created by the module. |
| <a name="output_build_folder_ids"></a> [build\_folder\_ids](#output\_build\_folder\_ids) | Map of build folder IDs keyed by folder key or path. |
<!-- END_TF_DOCS -->

## Additional Documentation

- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
