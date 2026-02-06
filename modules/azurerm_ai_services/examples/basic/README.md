# Basic AI Services Account Example

This example demonstrates a minimal AI Services Account configuration.

## Features

- Creates a basic AI Services Account with required settings
- Creates a dedicated resource group
- Demonstrates minimal module usage

## Key Configuration

This example demonstrates:
- Required inputs (name, location, resource group, SKU)
- Using variables for easy configuration

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

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.57.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ai_services"></a> [ai\_services](#module\_ai\_services) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_resource_group.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ai_services_name"></a> [ai\_services\_name](#input\_ai\_services\_name) | The name of the AI Services Account. | `string` | `"aiservicesbasic001"` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region for resources. | `string` | `"West Europe"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group. | `string` | `"rg-ai-services-basic-example"` | no |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | The SKU name for the AI Services Account. | `string` | `"S0"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ai_services_id"></a> [ai\_services\_id](#output\_ai\_services\_id) | The ID of the created AI Services Account |
| <a name="output_ai_services_name"></a> [ai\_services\_name](#output\_ai\_services\_name) | The name of the created AI Services Account |
<!-- END_TF_DOCS -->
