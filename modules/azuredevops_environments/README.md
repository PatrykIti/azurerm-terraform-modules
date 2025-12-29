# Terraform Azure DevOps Environments Module

## Module Version

<!-- BEGIN_VERSION -->
Current version: **vUnreleased**
<!-- END_VERSION -->

## Description

Azure DevOps environments module for managing environments, resources, and checks.

## Usage

```hcl
provider "azuredevops" {}

module "azuredevops_environments" {
  source = "path/to/azuredevops_environments"

  project_id  = "00000000-0000-0000-0000-000000000000"
  name        = "ado-env-basic-example"
  description = "Development environment"
}
```

## Notes

- This module manages a single environment; use module-level `for_each` to manage multiple environments.
- For checks without `display_name`, set `key` when targeting the module environment (omit `target_resource_id`).

## Examples

<!-- BEGIN_EXAMPLES -->
- [Basic](examples/basic) - This example demonstrates creating a basic Azure DevOps environment.
- [Complete](examples/complete) - This example demonstrates an environment with a Kubernetes resource, approval checks, and branch control.
- [Secure](examples/secure) - This example demonstrates environment approvals, exclusive locks, and business hours.
<!-- END_EXAMPLES -->

## Module Documentation

- [docs/README.md](docs/README.md) - Module-specific documentation overview
- [docs/IMPORT.md](docs/IMPORT.md) - Import existing Azure DevOps Environments into the module


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
| [azuredevops_check_approval.check_approval](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/check_approval) | resource |
| [azuredevops_check_branch_control.check_branch_control](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/check_branch_control) | resource |
| [azuredevops_check_business_hours.check_business_hours](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/check_business_hours) | resource |
| [azuredevops_check_exclusive_lock.check_exclusive_lock](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/check_exclusive_lock) | resource |
| [azuredevops_check_required_template.check_required_template](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/check_required_template) | resource |
| [azuredevops_check_rest_api.check_rest_api](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/check_rest_api) | resource |
| [azuredevops_environment.environment](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/environment) | resource |
| [azuredevops_environment_resource_kubernetes.kubernetes_resource](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/environment_resource_kubernetes) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_check_approvals"></a> [check\_approvals](#input\_check\_approvals) | List of approval checks to configure. | <pre>list(object({<br/>    key                        = optional(string)<br/>    target_resource_id         = optional(string)<br/>    target_resource_type       = optional(string)<br/>    approvers                  = list(string)<br/>    instructions               = optional(string)<br/>    minimum_required_approvers = optional(number)<br/>    requester_can_approve      = optional(bool)<br/>    timeout                    = optional(number)<br/>  }))</pre> | `[]` | no |
| <a name="input_check_branch_controls"></a> [check\_branch\_controls](#input\_check\_branch\_controls) | List of branch control checks to configure. | <pre>list(object({<br/>    key                              = optional(string)<br/>    display_name                     = string<br/>    target_resource_id               = optional(string)<br/>    target_resource_type             = optional(string)<br/>    allowed_branches                 = optional(string)<br/>    verify_branch_protection         = optional(bool)<br/>    ignore_unknown_protection_status = optional(bool)<br/>    timeout                          = optional(number)<br/>  }))</pre> | `[]` | no |
| <a name="input_check_business_hours"></a> [check\_business\_hours](#input\_check\_business\_hours) | List of business hours checks to configure. | <pre>list(object({<br/>    key                  = optional(string)<br/>    display_name         = string<br/>    target_resource_id   = optional(string)<br/>    target_resource_type = optional(string)<br/>    start_time           = string<br/>    end_time             = string<br/>    time_zone            = string<br/>    monday               = optional(bool)<br/>    tuesday              = optional(bool)<br/>    wednesday            = optional(bool)<br/>    thursday             = optional(bool)<br/>    friday               = optional(bool)<br/>    saturday             = optional(bool)<br/>    sunday               = optional(bool)<br/>    timeout              = optional(number)<br/>  }))</pre> | `[]` | no |
| <a name="input_check_exclusive_locks"></a> [check\_exclusive\_locks](#input\_check\_exclusive\_locks) | List of exclusive lock checks to configure. | <pre>list(object({<br/>    key                  = optional(string)<br/>    target_resource_id   = optional(string)<br/>    target_resource_type = optional(string)<br/>    timeout              = optional(number)<br/>  }))</pre> | `[]` | no |
| <a name="input_check_required_templates"></a> [check\_required\_templates](#input\_check\_required\_templates) | List of required template checks to configure. | <pre>list(object({<br/>    key                  = optional(string)<br/>    target_resource_id   = optional(string)<br/>    target_resource_type = optional(string)<br/>    required_templates = list(object({<br/>      template_path   = string<br/>      repository_name = string<br/>      repository_ref  = string<br/>      repository_type = optional(string)<br/>    }))<br/>  }))</pre> | `[]` | no |
| <a name="input_check_rest_apis"></a> [check\_rest\_apis](#input\_check\_rest\_apis) | List of REST API checks to configure. | <pre>list(object({<br/>    key                             = optional(string)<br/>    display_name                    = string<br/>    target_resource_id              = optional(string)<br/>    target_resource_type            = optional(string)<br/>    connected_service_name_selector = string<br/>    connected_service_name          = string<br/>    method                          = string<br/>    body                            = optional(string)<br/>    headers                         = optional(string)<br/>    retry_interval                  = optional(number)<br/>    success_criteria                = optional(string)<br/>    url_suffix                      = optional(string)<br/>    variable_group_name             = optional(string)<br/>    completion_event                = optional(string)<br/>    timeout                         = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_description"></a> [description](#input\_description) | Optional description for the Azure DevOps environment. | `string` | `null` | no |
| <a name="input_kubernetes_resources"></a> [kubernetes\_resources](#input\_kubernetes\_resources) | List of Kubernetes resources to attach to the environment. | <pre>list(object({<br/>    key                 = optional(string)<br/>    environment_id      = optional(string)<br/>    service_endpoint_id = string<br/>    name                = string<br/>    namespace           = string<br/>    cluster_name        = optional(string)<br/>    tags                = optional(list(string))<br/>  }))</pre> | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the Azure DevOps environment. | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Azure DevOps project ID. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_check_ids"></a> [check\_ids](#output\_check\_ids) | Map of check IDs grouped by check type and keyed by check key or display\_name. |
| <a name="output_environment_id"></a> [environment\_id](#output\_environment\_id) | ID of the Azure DevOps environment managed by this module. |
| <a name="output_kubernetes_resource_ids"></a> [kubernetes\_resource\_ids](#output\_kubernetes\_resource\_ids) | Map of Kubernetes resource IDs keyed by resource key or name. |
<!-- END_TF_DOCS -->

## Additional Documentation

- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
