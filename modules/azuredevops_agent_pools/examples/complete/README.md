# Complete Azure DevOps Agent Pools Example

This example demonstrates a fuller Azure DevOps Agent Pools configuration with queues and an optional elastic pool.

## Features

- Single module-managed agent pool with custom settings
- Multiple queues (module pool + external pool)
- Optional elastic pool configuration (requires service endpoint, scope, and Azure resource ID)
- Random suffixes to avoid naming conflicts

## Key Configuration

Set `enable_elastic_pool` to `true` and provide `service_endpoint_id`, `service_endpoint_scope`, and `azure_resource_id`.

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## Cleanup

```bash
terraform destroy
```

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
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_azuredevops_agent_pools"></a> [azuredevops\_agent\_pools](#module\_azuredevops\_agent\_pools) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [azuredevops_agent_pool.external](https://registry.terraform.io/providers/microsoft/azuredevops/1.12.2/docs/resources/agent_pool) | resource |
| [random_string.suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_azure_resource_id"></a> [azure\_resource\_id](#input\_azure\_resource\_id) | Azure resource ID for the elastic pool (required when enable\_elastic\_pool is true). | `string` | `""` | no |
| <a name="input_desired_idle"></a> [desired\_idle](#input\_desired\_idle) | Desired number of idle agents in the elastic pool. | `number` | `1` | no |
| <a name="input_elastic_pool_name_prefix"></a> [elastic\_pool\_name\_prefix](#input\_elastic\_pool\_name\_prefix) | Prefix for the elastic pool name. | `string` | `"ado-elastic-pool"` | no |
| <a name="input_enable_elastic_pool"></a> [enable\_elastic\_pool](#input\_enable\_elastic\_pool) | Whether to create an elastic pool in this example. | `bool` | `false` | no |
| <a name="input_max_capacity"></a> [max\_capacity](#input\_max\_capacity) | Maximum number of agents in the elastic pool. | `number` | `5` | no |
| <a name="input_pool_name_prefix"></a> [pool\_name\_prefix](#input\_pool\_name\_prefix) | Prefix for the agent pool name. | `string` | `"ado-agent-pool-complete"` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Azure DevOps project ID. | `string` | n/a | yes |
| <a name="input_service_endpoint_id"></a> [service\_endpoint\_id](#input\_service\_endpoint\_id) | Service endpoint ID for the elastic pool (required when enable\_elastic\_pool is true). | `string` | `""` | no |
| <a name="input_service_endpoint_scope"></a> [service\_endpoint\_scope](#input\_service\_endpoint\_scope) | Project ID that owns the service endpoint (required when enable\_elastic\_pool is true). | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_agent_pool_id"></a> [agent\_pool\_id](#output\_agent\_pool\_id) | Agent pool ID. |
| <a name="output_agent_queue_ids"></a> [agent\_queue\_ids](#output\_agent\_queue\_ids) | Map of agent queue IDs keyed by queue key/name. |
| <a name="output_elastic_pool_id"></a> [elastic\_pool\_id](#output\_elastic\_pool\_id) | Elastic pool ID when configured. |
<!-- END_TF_DOCS -->
