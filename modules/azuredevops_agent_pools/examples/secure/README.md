# Secure Azure DevOps Agent Pools Example

This example demonstrates a security-focused Azure DevOps Agent Pools configuration with minimal automation.

## Features

- Agent pool with `auto_provision` and `auto_update` disabled
- Fixed, deterministic naming with override variables

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
| <a name="input_pool_name"></a> [pool\_name](#input\_pool\_name) | Name of the agent pool. | `string` | `"ado-agent-pools-secure-example"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_agent_pool_id"></a> [agent\_pool\_id](#output\_agent\_pool\_id) | Agent pool ID. |
| <a name="output_elastic_pool_id"></a> [elastic\_pool\_id](#output\_elastic\_pool\_id) | Elastic pool ID when configured. |
<!-- END_TF_DOCS -->
