# Secure Azure DevOps Agent Pools Example

This example demonstrates a security-focused Azure DevOps Agent Pools configuration with minimal automation.

## Features

- Agent pool with `auto_provision` and `auto_update` disabled
- Single queue scoped to a project, using the module pool
- Random suffixes to avoid naming conflicts

## Key Configuration

Use this example when you want tighter control over pool provisioning and updates.

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
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_azuredevops_agent_pools"></a> [azuredevops\_agent\_pools](#module\_azuredevops\_agent\_pools) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [random_string.suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_pool_name_prefix"></a> [pool\_name\_prefix](#input\_pool\_name\_prefix) | Prefix for the agent pool name. | `string` | `"ado-agent-pool-secure"` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Azure DevOps project ID. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_agent_pool_id"></a> [agent\_pool\_id](#output\_agent\_pool\_id) | Agent pool ID. |
| <a name="output_agent_queue_ids"></a> [agent\_queue\_ids](#output\_agent\_queue\_ids) | Map of agent queue IDs keyed by queue key/name. |
| <a name="output_elastic_pool_id"></a> [elastic\_pool\_id](#output\_elastic\_pool\_id) | Elastic pool ID when configured. |
<!-- END_TF_DOCS -->
