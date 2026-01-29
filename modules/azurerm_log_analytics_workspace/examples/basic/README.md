# Basic Log Analytics Workspace Example

This example demonstrates a basic Log Analytics Workspace configuration using secure defaults and minimal setup.

## Features

- Creates a basic log_analytics_workspace with standard configuration
- Uses secure defaults following Azure best practices
- Creates a dedicated resource group
- Demonstrates basic module usage patterns
- Uses variables for configuration flexibility

## Key Configuration

This example uses secure defaults and demonstrates:
- Basic resource creation with minimal configuration
- Using variables for easy configuration customization
- Following security best practices by default

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
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource group name for the example. | `string` | `"rg-law-basic-example"` | no |
| <a name="input_workspace_name"></a> [workspace\_name](#input\_workspace\_name) | Log Analytics Workspace name. | `string` | `"law-basic-example"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#output\_log\_analytics\_workspace\_id) | The Log Analytics Workspace ID. |
| <a name="output_log_analytics_workspace_name"></a> [log\_analytics\_workspace\_name](#output\_log\_analytics\_workspace\_name) | The Log Analytics Workspace name. |
<!-- END_TF_DOCS -->
