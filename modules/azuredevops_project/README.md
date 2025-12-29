# Terraform Azure DevOps Project Module

## Module Version

<!-- BEGIN_VERSION -->
Current version: **vUnreleased**
<!-- END_VERSION -->

## Description

Manages Azure DevOps projects, settings, tags, and dashboards. Project permissions are handled by the `azuredevops_project_permissions` module.

## Usage

```hcl
provider "azuredevops" {}

module "azuredevops_project" {
  source = "path/to/azuredevops_project"

  name               = "ado-project-basic-example"
  description        = "Managed by Terraform"
  visibility         = "private"
  version_control    = "Git"
  work_item_template = "Agile"

  project_tags = ["terraform", "example"]
}
```

## Examples

<!-- BEGIN_EXAMPLES -->
- [Basic](examples/basic) - This example demonstrates a basic Azure DevOps project configuration with minimal settings.
- [Complete](examples/complete) - This example demonstrates a complete Azure DevOps project configuration with features, pipeline settings, tags, and dashboards.
- [Secure](examples/secure) - This example demonstrates a security-focused Azure DevOps project configuration with restrictive pipeline settings and limited features.
<!-- END_EXAMPLES -->

## Module Documentation

- [docs/README.md](docs/README.md) - Module-specific documentation overview
- [docs/IMPORT.md](docs/IMPORT.md) - Import existing Azure DevOps projects into the module

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
| [azuredevops_dashboard.dashboard](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/dashboard) | resource |
| [azuredevops_project.project](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/project) | resource |
| [azuredevops_project_pipeline_settings.project_pipeline_settings](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/project_pipeline_settings) | resource |
| [azuredevops_project_tags.project_tags](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/project_tags) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_dashboards"></a> [dashboards](#input\_dashboards) | List of dashboards to create in the project. | <pre>list(object({<br/>    name             = string<br/>    description      = optional(string)<br/>    team_id          = optional(string)<br/>    refresh_interval = optional(number, 0)<br/>  }))</pre> | `[]` | no |
| <a name="input_description"></a> [description](#input\_description) | The description of the Azure DevOps project. | `string` | `null` | no |
| <a name="input_features"></a> [features](#input\_features) | Project feature flags for azuredevops\_project.features. Set to null to leave unmanaged. | `map(string)` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the Azure DevOps project. | `string` | n/a | yes |
| <a name="input_pipeline_settings"></a> [pipeline\_settings](#input\_pipeline\_settings) | Pipeline settings for the project. When null, settings are not managed. | <pre>object({<br/>    enforce_job_scope                    = optional(bool)<br/>    enforce_referenced_repo_scoped_token = optional(bool)<br/>    enforce_settable_var                 = optional(bool)<br/>    publish_pipeline_metadata            = optional(bool)<br/>    status_badges_are_private            = optional(bool)<br/>    enforce_job_scope_for_release        = optional(bool)<br/>  })</pre> | `null` | no |
| <a name="input_project_tags"></a> [project\_tags](#input\_project\_tags) | List of tags to assign to the project. | `list(string)` | `[]` | no |
| <a name="input_version_control"></a> [version\_control](#input\_version\_control) | Specifies the version control system. Possible values are: Git, Tfvc. | `string` | `"Git"` | no |
| <a name="input_visibility"></a> [visibility](#input\_visibility) | Specifies the project visibility. Possible values are: private, public. | `string` | `"private"` | no |
| <a name="input_work_item_template"></a> [work\_item\_template](#input\_work\_item\_template) | Specifies the work item template. Defaults to Agile. | `string` | `"Agile"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dashboard_ids"></a> [dashboard\_ids](#output\_dashboard\_ids) | Map of dashboard IDs keyed by dashboard name. |
| <a name="output_dashboard_owner_ids"></a> [dashboard\_owner\_ids](#output\_dashboard\_owner\_ids) | Map of dashboard owner IDs keyed by dashboard name. |
| <a name="output_project_description"></a> [project\_description](#output\_project\_description) | The description of the Azure DevOps project. |
| <a name="output_project_id"></a> [project\_id](#output\_project\_id) | The ID of the Azure DevOps project. |
| <a name="output_project_name"></a> [project\_name](#output\_project\_name) | The name of the Azure DevOps project. |
| <a name="output_project_pipeline_settings_id"></a> [project\_pipeline\_settings\_id](#output\_project\_pipeline\_settings\_id) | The ID returned by azuredevops\_project\_pipeline\_settings when managed. |
| <a name="output_project_process_template_id"></a> [project\_process\_template\_id](#output\_project\_process\_template\_id) | The process template ID used by the project. |
| <a name="output_project_tags"></a> [project\_tags](#output\_project\_tags) | Tags assigned to the project (when managed). |
| <a name="output_project_version_control"></a> [project\_version\_control](#output\_project\_version\_control) | The version control system used by the project. |
| <a name="output_project_visibility"></a> [project\_visibility](#output\_project\_visibility) | The visibility of the Azure DevOps project. |
| <a name="output_project_work_item_template"></a> [project\_work\_item\_template](#output\_project\_work\_item\_template) | The work item template used by the project. |
<!-- END_TF_DOCS -->

## Additional Documentation

- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
