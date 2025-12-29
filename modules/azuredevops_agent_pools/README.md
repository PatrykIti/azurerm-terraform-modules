# Terraform Azure DevOps Agent Pools Module

## Module Version

<!-- BEGIN_VERSION -->
Current version: **vUnreleased**
<!-- END_VERSION -->

## Description

Azure DevOps agent pools module for managing pools, queues, and elastic pools.

## Usage

```hcl
provider "azuredevops" {}

module "azuredevops_agent_pools" {
  source = "path/to/azuredevops_agent_pools"

  name = "ado-agent-pool"

  agent_queues = [
    {
      key        = "default"
      project_id = "00000000-0000-0000-0000-000000000000"
    }
  ]

  # Optional: elastic_pool = { ... }
}
```

## Examples

<!-- BEGIN_EXAMPLES -->
- [Basic](examples/basic) - This example demonstrates a basic Azure DevOps Agent Pools configuration with one pool and one queue.
- [Complete](examples/complete) - This example demonstrates a fuller Azure DevOps Agent Pools configuration with queues and an optional elastic pool.
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
| [azuredevops_agent_queue.agent_queue](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/agent_queue) | resource |
| [azuredevops_elastic_pool.elastic_pool](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/elastic_pool) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_agent_queues"></a> [agent\_queues](#input\_agent\_queues) | List of Azure DevOps agent queues to manage.<br/>- When name is provided, agent\_pool\_id must be null (queue resolved by name).<br/>- When agent\_pool\_id is provided, name must be null (queue name derived from the pool).<br/>- When both are null, the module uses the created agent pool ID.<br/>- When auto\_provision is true, do not omit both name and agent\_pool\_id. | <pre>list(object({<br/>    key           = optional(string)<br/>    project_id    = string<br/>    name          = optional(string)<br/>    agent_pool_id = optional(number)<br/>  }))</pre> | `[]` | no |
| <a name="input_auto_provision"></a> [auto\_provision](#input\_auto\_provision) | Specifies whether a queue should be automatically provisioned for each project collection. | `bool` | `false` | no |
| <a name="input_auto_update"></a> [auto\_update](#input\_auto\_update) | Specifies whether agents within the pool should be automatically updated. | `bool` | `true` | no |
| <a name="input_elastic_pool"></a> [elastic\_pool](#input\_elastic\_pool) | Elastic pool configuration. When null, elastic pool is not managed. | <pre>object({<br/>    name                   = string<br/>    service_endpoint_id    = string<br/>    service_endpoint_scope = string<br/>    azure_resource_id      = string<br/>    desired_idle           = number<br/>    max_capacity           = number<br/>    recycle_after_each_use = optional(bool)<br/>    time_to_live_minutes   = optional(number)<br/>    agent_interactive_ui   = optional(bool)<br/>    auto_provision         = optional(bool)<br/>    auto_update            = optional(bool)<br/>    project_id             = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the Azure DevOps agent pool. | `string` | n/a | yes |
| <a name="input_pool_type"></a> [pool\_type](#input\_pool\_type) | Type of agent pool. Allowed values: automation, deployment. | `string` | `"automation"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_agent_pool_id"></a> [agent\_pool\_id](#output\_agent\_pool\_id) | ID of the agent pool created by the module. |
| <a name="output_agent_queue_ids"></a> [agent\_queue\_ids](#output\_agent\_queue\_ids) | Map of agent queue IDs keyed by queue key/name. |
| <a name="output_elastic_pool_id"></a> [elastic\_pool\_id](#output\_elastic\_pool\_id) | ID of the elastic pool when configured. |
<!-- END_TF_DOCS -->

## Additional Documentation

- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
