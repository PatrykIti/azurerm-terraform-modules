# Log Analytics Solutions Example

This example demonstrates deploying Log Analytics solutions in a workspace.

## Usage

Run the following commands from this directory:

```bash
terraform init
terraform apply
```

<!-- BEGIN_TF_DOCS -->


## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.12.2 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | 4.57.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.57.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_log_analytics_workspace"></a> [log\_analytics\_workspace](#module\_log\_analytics\_workspace) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_resource_group.example](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/resource_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_location"></a> [location](#input\_location) | Azure region for resources. | `string` | `"westeurope"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource group name for the example. | `string` | `"rg-law-solutions-example"` | no |
| <a name="input_workspace_name"></a> [workspace\_name](#input\_workspace\_name) | Log Analytics Workspace name. | `string` | `"law-solutions-example"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_solutions"></a> [solutions](#output\_solutions) | Log Analytics solutions created by the module. |
<!-- END_TF_DOCS -->