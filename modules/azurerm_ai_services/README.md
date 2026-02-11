# Terraform Azure AI Services Module

## Module Version

<!-- BEGIN_VERSION -->
Current version: **1.0.0**
<!-- END_VERSION -->

## Description

Manages Azure AI Services using the `azurerm_ai_services` resource.

## Usage

```hcl
module "azurerm_ai_services" {
  source = "path/to/azurerm_ai_services"

  # Required variables
  name                = "example-azurerm_ai_services"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  sku_name            = "S0"

  # Optional configuration
  public_network_access        = "Enabled"
  local_authentication_enabled = true

  tags = {
    Environment = "Development"
    Project     = "Example"
  }
}
```

> Note: AzureRM exposes AI Services Accounts via the `azurerm_ai_services` resource.
> Deployments/models and RAI policies are not available for AI Services Accounts in azurerm 4.57.0.

## Examples

<!-- BEGIN_EXAMPLES -->
- [Basic](examples/basic) - This example demonstrates a minimal AI Services Account configuration.
- [Complete](examples/complete) - This example demonstrates a more complete AI Services Account configuration.
- [Secure](examples/secure) - This example demonstrates a security-focused AI Services Account configuration.
<!-- END_EXAMPLES -->

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

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_ai_services.ai_services](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/ai_services) | resource |
| [azurerm_monitor_diagnostic_setting.monitor_diagnostic_settings](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/monitor_diagnostic_setting) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_custom_subdomain_name"></a> [custom\_subdomain\_name](#input\_custom\_subdomain\_name) | Custom subdomain name used for token-based authentication. Required when network\_acls is specified. | `string` | `null` | no |
| <a name="input_customer_managed_key"></a> [customer\_managed\_key](#input\_customer\_managed\_key) | Customer-managed key configuration for encryption at rest. | <pre>object({<br/>    key_vault_key_id   = optional(string)<br/>    managed_hsm_key_id = optional(string)<br/>    identity_client_id = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_diagnostic_settings"></a> [diagnostic\_settings](#input\_diagnostic\_settings) | Diagnostic settings for the AI Services Account.<br/><br/>Supported categories for azurerm 4.57.0:<br/>- log\_categories: Audit<br/>- metric\_categories: AllMetrics | <pre>list(object({<br/>    name                           = string<br/>    log_categories                 = optional(list(string))<br/>    metric_categories              = optional(list(string))<br/>    log_analytics_workspace_id     = optional(string)<br/>    log_analytics_destination_type = optional(string)<br/>    storage_account_id             = optional(string)<br/>    eventhub_authorization_rule_id = optional(string)<br/>    eventhub_name                  = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_fqdns"></a> [fqdns](#input\_fqdns) | List of FQDNs allowed for the AI Services Account. | `list(string)` | `null` | no |
| <a name="input_identity"></a> [identity](#input\_identity) | Managed identity configuration for the AI Services Account. | <pre>object({<br/>    type         = string<br/>    identity_ids = optional(list(string))<br/>  })</pre> | `null` | no |
| <a name="input_local_authentication_enabled"></a> [local\_authentication\_enabled](#input\_local\_authentication\_enabled) | Whether local authentication is enabled for the AI Services Account. | `bool` | `true` | no |
| <a name="input_location"></a> [location](#input\_location) | The Azure region where the AI Services Account should exist. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the AI Services Account. | `string` | n/a | yes |
| <a name="input_network_acls"></a> [network\_acls](#input\_network\_acls) | Network ACL configuration for the AI Services Account. | <pre>object({<br/>    default_action = string<br/>    bypass         = optional(string, "AzureServices")<br/>    ip_rules       = optional(list(string))<br/>    virtual_network_rules = optional(list(object({<br/>      subnet_id                            = string<br/>      ignore_missing_vnet_service_endpoint = optional(bool, false)<br/>    })))<br/>  })</pre> | `null` | no |
| <a name="input_outbound_network_access_restricted"></a> [outbound\_network\_access\_restricted](#input\_outbound\_network\_access\_restricted) | Whether outbound network access is restricted for the AI Services Account. | `bool` | `false` | no |
| <a name="input_public_network_access"></a> [public\_network\_access](#input\_public\_network\_access) | Whether public network access is allowed for the AI Services Account. Possible values: Enabled, Disabled. | `string` | `"Enabled"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group in which to create the AI Services Account. | `string` | n/a | yes |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | The SKU name for the AI Services Account. | `string` | n/a | yes |
| <a name="input_storage"></a> [storage](#input\_storage) | Optional storage configuration blocks for the AI Services Account. | <pre>list(object({<br/>    storage_account_id = string<br/>    identity_client_id = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the AI Services Account. | `map(string)` | `{}` | no |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | Custom timeouts for the AI Services Account. | <pre>object({<br/>    create = optional(string)<br/>    read   = optional(string)<br/>    update = optional(string)<br/>    delete = optional(string)<br/>  })</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_diagnostic_settings_skipped"></a> [diagnostic\_settings\_skipped](#output\_diagnostic\_settings\_skipped) | Deprecated compatibility output. Diagnostic settings require explicit categories, so no entries are skipped. |
| <a name="output_endpoint"></a> [endpoint](#output\_endpoint) | The endpoint of the AI Services Account. |
| <a name="output_fqdns"></a> [fqdns](#output\_fqdns) | The allowed FQDNs for the AI Services Account. |
| <a name="output_id"></a> [id](#output\_id) | The ID of the AI Services Account. |
| <a name="output_identity"></a> [identity](#output\_identity) | The managed identity configuration for the AI Services Account. |
| <a name="output_location"></a> [location](#output\_location) | The location of the AI Services Account. |
| <a name="output_name"></a> [name](#output\_name) | The name of the AI Services Account. |
| <a name="output_primary_access_key"></a> [primary\_access\_key](#output\_primary\_access\_key) | The primary access key for the AI Services Account. |
| <a name="output_public_network_access"></a> [public\_network\_access](#output\_public\_network\_access) | The public network access setting for the AI Services Account. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The resource group name of the AI Services Account. |
| <a name="output_secondary_access_key"></a> [secondary\_access\_key](#output\_secondary\_access\_key) | The secondary access key for the AI Services Account. |
| <a name="output_sku_name"></a> [sku\_name](#output\_sku\_name) | The SKU name of the AI Services Account. |
<!-- END_TF_DOCS -->

## Additional Documentation

- [docs/README.md](docs/README.md) - Module overview and scope notes
- [docs/IMPORT.md](docs/IMPORT.md) - Import existing AI Services Account using Terraform import blocks
- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
