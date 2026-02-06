# Secure AI Services Account Example

This example demonstrates a security-focused AI Services Account configuration.

## Features

- User-assigned identity with customer-managed key encryption
- Public network access disabled
- Private endpoint for private connectivity
- Diagnostic settings routed to Log Analytics

## Key Configuration

This example implements defense-in-depth principles using CMK, private connectivity, and diagnostics.

## Security Considerations

- Public access is disabled
- CMK encryption is enabled via Key Vault
- Diagnostic settings are configured for monitoring

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
| [azurerm_key_vault.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault) | resource |
| [azurerm_key_vault_access_policy.ai](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_access_policy) | resource |
| [azurerm_key_vault_access_policy.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_access_policy) | resource |
| [azurerm_key_vault_key.ai](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_key) | resource |
| [azurerm_log_analytics_workspace.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) | resource |
| [azurerm_private_endpoint.ai_services](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_resource_group.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_subnet.private_endpoints](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_user_assigned_identity.ai](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [azurerm_virtual_network.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ai_services_name"></a> [ai\_services\_name](#input\_ai\_services\_name) | The name of the AI Services Account. | `string` | `"aiservicessecure001"` | no |
| <a name="input_diagnostic_setting_name"></a> [diagnostic\_setting\_name](#input\_diagnostic\_setting\_name) | The name of the diagnostic setting. | `string` | `"ai-services-secure-diagnostics"` | no |
| <a name="input_key_vault_key_name"></a> [key\_vault\_key\_name](#input\_key\_vault\_key\_name) | The name of the Key Vault key. | `string` | `"ai-services-key"` | no |
| <a name="input_key_vault_name"></a> [key\_vault\_name](#input\_key\_vault\_name) | The name of the Key Vault. | `string` | `"kv-aisecure-001"` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region for resources. | `string` | `"West Europe"` | no |
| <a name="input_log_analytics_workspace_name"></a> [log\_analytics\_workspace\_name](#input\_log\_analytics\_workspace\_name) | The name of the Log Analytics workspace. | `string` | `"law-ai-services-secure"` | no |
| <a name="input_private_endpoint_name"></a> [private\_endpoint\_name](#input\_private\_endpoint\_name) | The name of the private endpoint. | `string` | `"pe-ai-services-secure"` | no |
| <a name="input_private_endpoint_subnet_name"></a> [private\_endpoint\_subnet\_name](#input\_private\_endpoint\_subnet\_name) | The name of the private endpoint subnet. | `string` | `"snet-ai-services-private-endpoints"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group. | `string` | `"rg-ai-services-secure-example"` | no |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | The SKU name for the AI Services Account. | `string` | `"S0"` | no |
| <a name="input_user_assigned_identity_name"></a> [user\_assigned\_identity\_name](#input\_user\_assigned\_identity\_name) | The name of the user-assigned identity. | `string` | `"id-ai-services-secure"` | no |
| <a name="input_virtual_network_name"></a> [virtual\_network\_name](#input\_virtual\_network\_name) | The name of the virtual network. | `string` | `"vnet-ai-services-secure"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ai_services_id"></a> [ai\_services\_id](#output\_ai\_services\_id) | The ID of the created AI Services Account |
| <a name="output_ai_services_name"></a> [ai\_services\_name](#output\_ai\_services\_name) | The name of the created AI Services Account |
<!-- END_TF_DOCS -->
