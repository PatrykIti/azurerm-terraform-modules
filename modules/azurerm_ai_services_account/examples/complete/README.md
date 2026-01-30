# Complete AI Services Account Example

This example demonstrates a more complete AI Services Account configuration.

## Features

- Network ACLs with custom subdomain name
- VNet/subnet configuration with Cognitive Services service endpoint
- Diagnostic settings routed to Log Analytics
- System-assigned identity

## Key Configuration

This example focuses on core platform features commonly used in production environments.

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
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ai_services_account"></a> [ai\_services\_account](#module\_ai\_services\_account) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_log_analytics_workspace.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) | resource |
| [azurerm_resource_group.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_subnet.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_virtual_network.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ai_services_account_name"></a> [ai\_services\_account\_name](#input\_ai\_services\_account\_name) | The name of the AI Services Account. | `string` | `"aiservicescomplete001"` | no |
| <a name="input_allowed_ip_range"></a> [allowed\_ip\_range](#input\_allowed\_ip\_range) | IP range allowed to access the AI Services Account. | `string` | `"203.0.113.0/24"` | no |
| <a name="input_custom_subdomain_name"></a> [custom\_subdomain\_name](#input\_custom\_subdomain\_name) | Custom subdomain name required for network ACLs. | `string` | `"aiservicescomplete001"` | no |
| <a name="input_diagnostic_setting_name"></a> [diagnostic\_setting\_name](#input\_diagnostic\_setting\_name) | The name of the diagnostic setting. | `string` | `"ai-services-diagnostics"` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region for resources. | `string` | `"West Europe"` | no |
| <a name="input_log_analytics_workspace_name"></a> [log\_analytics\_workspace\_name](#input\_log\_analytics\_workspace\_name) | The name of the Log Analytics workspace. | `string` | `"law-ai-services-complete"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group. | `string` | `"rg-ai-services-complete-example"` | no |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | The SKU name for the AI Services Account. | `string` | `"S0"` | no |
| <a name="input_subnet_name"></a> [subnet\_name](#input\_subnet\_name) | The name of the subnet. | `string` | `"snet-ai-services-complete"` | no |
| <a name="input_virtual_network_name"></a> [virtual\_network\_name](#input\_virtual\_network\_name) | The name of the virtual network. | `string` | `"vnet-ai-services-complete"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ai_services_account_id"></a> [ai\_services\_account\_id](#output\_ai\_services\_account\_id) | The ID of the created AI Services Account |
| <a name="output_ai_services_account_name"></a> [ai\_services\_account\_name](#output\_ai\_services\_account\_name) | The name of the created AI Services Account |
<!-- END_TF_DOCS -->
