# Terraform Azure DevOps Agent Pools Module

## Module Version

<!-- BEGIN_VERSION -->
Current version: **1.0.0**
<!-- END_VERSION -->

## Description

Azure DevOps agent pools module for managing a single agent pool.
For elastic pools, use `modules/azuredevops_elastic_pool`.

## Usage

```hcl
provider "azuredevops" {}

module "azuredevops_agent_pools" {
  source = "path/to/azuredevops_agent_pools"

  name = "ado-agent-pool"
}
```

## Examples

<!-- BEGIN_EXAMPLES -->
- [Basic](examples/basic) - This example demonstrates a basic Azure DevOps Agent Pools configuration with a single pool.
- [Complete](examples/complete) - This example demonstrates a fuller Azure DevOps Agent Pools configuration with non-default pool settings.
- [Secure](examples/secure) - This example demonstrates a security-focused Azure DevOps Agent Pools configuration with minimal automation.
<!-- END_EXAMPLES -->

## Module Documentation

- [docs/README.md](docs/README.md) - Module-specific documentation overview
- [docs/IMPORT.md](docs/IMPORT.md) - Import existing Azure DevOps Agent Pools into the module


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
| [azuredevops_agent_pool.agent_pool](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/agent_pool) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_auto_provision"></a> [auto\_provision](#input\_auto\_provision) | Specifies whether a queue should be automatically provisioned for each project collection. | `bool` | `false` | no |
| <a name="input_auto_update"></a> [auto\_update](#input\_auto\_update) | Specifies whether agents within the pool should be automatically updated. | `bool` | `true` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the Azure DevOps agent pool. | `string` | n/a | yes |
| <a name="input_pool_type"></a> [pool\_type](#input\_pool\_type) | Type of agent pool. Allowed values: automation, deployment. | `string` | `"automation"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_agent_pool_id"></a> [agent\_pool\_id](#output\_agent\_pool\_id) | ID of the agent pool created by the module. |
<!-- END_TF_DOCS -->

## Additional Documentation

- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
