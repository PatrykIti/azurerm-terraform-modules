# Basic Application Insights Example

This example demonstrates a basic Application Insights configuration using secure defaults and minimal setup.

## Features

- Creates a basic application_insights with standard configuration
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
| <a name="module_application_insights"></a> [application\_insights](#module\_application\_insights) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_resource_group.example](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/resource_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_application_insights_name"></a> [application\_insights\_name](#input\_application\_insights\_name) | Name of the Application Insights component. | `string` | `"appi-basic-example"` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region for resources. | `string` | `"westeurope"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group for the example. | `string` | `"rg-appins-basic-example"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_application_insights_id"></a> [application\_insights\_id](#output\_application\_insights\_id) | The ID of the created Application Insights |
| <a name="output_application_insights_name"></a> [application\_insights\_name](#output\_application\_insights\_name) | The name of the created Application Insights |
<!-- END_TF_DOCS -->
