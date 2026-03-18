# Terraform Azure DevOps Elastic Pool Module

## Module Version

<!-- BEGIN_VERSION -->
Current version: **1.0.0**
<!-- END_VERSION -->

## Description

Azure DevOps elastic pool module for managing a single elastic pool.

## Usage

```hcl
provider "azuredevops" {}

module "azuredevops_elastic_pool" {
  source = "path/to/azuredevops_elastic_pool"

  name                   = "ado-elastic-pool"
  service_endpoint_id    = "00000000-0000-0000-0000-000000000001"
  service_endpoint_scope = "00000000-0000-0000-0000-000000000000"
  azure_resource_id      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg/providers/Microsoft.Compute/virtualMachineScaleSets/vmss"
}
```

## Examples

<!-- BEGIN_EXAMPLES -->
- [Basic](examples/basic) - This example demonstrates a basic Azure DevOps Elastic Pool configuration.
- [Complete](examples/complete) - This example demonstrates an Azure DevOps Elastic Pool configuration with optional settings.
- [Secure](examples/secure) - This example demonstrates an Azure DevOps Elastic Pool configuration with stricter automation settings.
<!-- END_EXAMPLES -->

## Module Documentation

- [docs/README.md](docs/README.md) - Module-specific documentation overview
- [docs/IMPORT.md](docs/IMPORT.md) - Import existing Azure DevOps Elastic Pool into the module

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
| [azuredevops_elastic_pool.elastic_pool](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/elastic_pool) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_agent_interactive_ui"></a> [agent\_interactive\_ui](#input\_agent\_interactive\_ui) | Whether interactive UI is enabled for agents. | `bool` | `null` | no |
| <a name="input_auto_provision"></a> [auto\_provision](#input\_auto\_provision) | Whether the elastic pool is automatically provisioned. | `bool` | `null` | no |
| <a name="input_auto_update"></a> [auto\_update](#input\_auto\_update) | Whether agents in the elastic pool are automatically updated. | `bool` | `null` | no |
| <a name="input_azure_resource_id"></a> [azure\_resource\_id](#input\_azure\_resource\_id) | Azure resource ID of the backing VMSS. | `string` | n/a | yes |
| <a name="input_desired_idle"></a> [desired\_idle](#input\_desired\_idle) | Desired number of idle agents in the elastic pool. | `number` | `1` | no |
| <a name="input_max_capacity"></a> [max\_capacity](#input\_max\_capacity) | Maximum number of agents in the elastic pool. | `number` | `2` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the Azure DevOps elastic pool. | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Optional project ID for project-scoped elastic pool behavior. | `string` | `null` | no |
| <a name="input_recycle_after_each_use"></a> [recycle\_after\_each\_use](#input\_recycle\_after\_each\_use) | Whether agents are recycled after each job. | `bool` | `null` | no |
| <a name="input_service_endpoint_id"></a> [service\_endpoint\_id](#input\_service\_endpoint\_id) | ID of the service endpoint used by the elastic pool. | `string` | n/a | yes |
| <a name="input_service_endpoint_scope"></a> [service\_endpoint\_scope](#input\_service\_endpoint\_scope) | Project ID that owns the service endpoint. | `string` | n/a | yes |
| <a name="input_time_to_live_minutes"></a> [time\_to\_live\_minutes](#input\_time\_to\_live\_minutes) | Time-to-live for agents in minutes. | `number` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_elastic_pool_id"></a> [elastic\_pool\_id](#output\_elastic\_pool\_id) | ID of the elastic pool created by the module. |
<!-- END_TF_DOCS -->

## Additional Documentation

- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
