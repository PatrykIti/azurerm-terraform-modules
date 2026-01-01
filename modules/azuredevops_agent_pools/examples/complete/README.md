# Complete Azure DevOps Agent Pools Example

This example demonstrates a fuller Azure DevOps Agent Pools configuration with an optional elastic pool.

## Features

- Single module-managed agent pool with custom settings
- Optional elastic pool configuration (requires service endpoint, scope, and Azure resource ID)
- Fixed, deterministic naming with override variables

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

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_azuredevops_agent_pools"></a> [azuredevops\_agent\_pools](#module\_azuredevops\_agent\_pools) | git::https://github.com/PatrykIti/azurerm-terraform-modules//modules/azuredevops_agent_pools | ADOAPv1.0.0 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_azure_resource_id"></a> [azure\_resource\_id](#input\_azure\_resource\_id) | Azure resource ID for the elastic pool (required when enable\_elastic\_pool is true). | `string` | `""` | no |
| <a name="input_desired_idle"></a> [desired\_idle](#input\_desired\_idle) | Desired number of idle agents in the elastic pool. | `number` | `1` | no |
| <a name="input_elastic_pool_name"></a> [elastic\_pool\_name](#input\_elastic\_pool\_name) | Name of the elastic pool. | `string` | `"ado-elastic-pool-complete-example"` | no |
| <a name="input_enable_elastic_pool"></a> [enable\_elastic\_pool](#input\_enable\_elastic\_pool) | Whether to create an elastic pool in this example. | `bool` | `false` | no |
| <a name="input_max_capacity"></a> [max\_capacity](#input\_max\_capacity) | Maximum number of agents in the elastic pool. | `number` | `5` | no |
| <a name="input_pool_name"></a> [pool\_name](#input\_pool\_name) | Name of the agent pool. | `string` | `"ado-agent-pools-complete-example"` | no |
| <a name="input_service_endpoint_id"></a> [service\_endpoint\_id](#input\_service\_endpoint\_id) | Service endpoint ID for the elastic pool (required when enable\_elastic\_pool is true). | `string` | `""` | no |
| <a name="input_service_endpoint_scope"></a> [service\_endpoint\_scope](#input\_service\_endpoint\_scope) | Project ID that owns the service endpoint (required when enable\_elastic\_pool is true). | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_agent_pool_id"></a> [agent\_pool\_id](#output\_agent\_pool\_id) | Agent pool ID. |
| <a name="output_elastic_pool_id"></a> [elastic\_pool\_id](#output\_elastic\_pool\_id) | Elastic pool ID when configured. |
<!-- END_TF_DOCS -->
