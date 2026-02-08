# Terraform Azure Cognitive Account Module

## Module Version

<!-- BEGIN_VERSION -->
Current version: **vUnreleased**
<!-- END_VERSION -->

## Description

Manages Azure Cognitive Services accounts for OpenAI, Language (TextAnalytics), and Speech services.

## Usage

```hcl
module "cognitive_account" {
  source = "path/to/azurerm_cognitive_account"

  name                = "example-openai"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  kind     = "OpenAI"
  sku_name = "S0"

  public_network_access_enabled = true
  local_auth_enabled            = true

  tags = {
    Environment = "Development"
    Service     = "OpenAI"
  }
}
```

## Examples

<!-- BEGIN_EXAMPLES -->
- [Basic](examples/basic) - This example provisions a minimal OpenAI Cognitive Account with public access enabled.
- [Complete](examples/complete) - This example demonstrates a more complete OpenAI configuration including network ACLs, identity, and diagnostic settings.
- [Customer Managed Key](examples/customer-managed-key) - This example provisions an OpenAI Cognitive Account configured with a customer-managed key.
- [Language Service](examples/language-service) - This example provisions a Language (TextAnalytics) Cognitive Account.
- [Openai Deployments](examples/openai-deployments) - This example provisions an OpenAI Cognitive Account and a sample deployment.
- [Openai Rai Policy](examples/openai-rai-policy) - This example provisions an OpenAI Cognitive Account and a sample RAI policy.
- [Private Endpoint](examples/private-endpoint) - This example provisions an OpenAI Cognitive Account and a private endpoint with a private DNS zone managed outside the module.
- [Secure](examples/secure) - This example provisions an OpenAI account with public access disabled, local auth disabled, customer-managed keys, and a private endpoint created outside the module.
- [Speech Service](examples/speech-service) - This example provisions a SpeechServices Cognitive Account.
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
| [azurerm_cognitive_account.cognitive_account](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/cognitive_account) | resource |
| [azurerm_cognitive_account_customer_managed_key.cognitive_account_customer_managed_key](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/cognitive_account_customer_managed_key) | resource |
| [azurerm_cognitive_account_rai_blocklist.cognitive_account_rai_blocklist](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/cognitive_account_rai_blocklist) | resource |
| [azurerm_cognitive_account_rai_policy.cognitive_account_rai_policy](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/cognitive_account_rai_policy) | resource |
| [azurerm_cognitive_deployment.cognitive_deployment](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/cognitive_deployment) | resource |
| [azurerm_monitor_diagnostic_setting.monitor_diagnostic_setting](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/monitor_diagnostic_setting) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_custom_subdomain_name"></a> [custom\_subdomain\_name](#input\_custom\_subdomain\_name) | The custom subdomain name used for Entra ID token-based authentication. Required when network\_acls is set. | `string` | `null` | no |
| <a name="input_customer_managed_key"></a> [customer\_managed\_key](#input\_customer\_managed\_key) | Customer-managed key configuration for the Cognitive Account. | <pre>object({<br/>    key_vault_key_id      = string<br/>    identity_client_id    = optional(string)<br/>    use_separate_resource = optional(bool, false)<br/>  })</pre> | `null` | no |
| <a name="input_deployments"></a> [deployments](#input\_deployments) | OpenAI deployments to create when kind is OpenAI. | <pre>list(object({<br/>    name = string<br/>    model = object({<br/>      format  = string<br/>      name    = string<br/>      version = optional(string)<br/>    })<br/>    sku = object({<br/>      name     = string<br/>      tier     = optional(string)<br/>      size     = optional(string)<br/>      family   = optional(string)<br/>      capacity = optional(number)<br/>    })<br/>    dynamic_throttling_enabled = optional(bool)<br/>    rai_policy_name            = optional(string)<br/>    version_upgrade_option     = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_diagnostic_settings"></a> [diagnostic\_settings](#input\_diagnostic\_settings) | Diagnostic settings configuration for the Cognitive Account.<br/><br/>Supported categories for azurerm 4.57.0:<br/>- log\_categories: AuditEvent<br/>- log\_category\_groups: allLogs<br/>- metric\_categories: AllMetrics | <pre>list(object({<br/>    name                           = string<br/>    log_categories                 = optional(list(string))<br/>    metric_categories              = optional(list(string))<br/>    log_category_groups            = optional(list(string))<br/>    log_analytics_workspace_id     = optional(string)<br/>    log_analytics_destination_type = optional(string)<br/>    storage_account_id             = optional(string)<br/>    eventhub_authorization_rule_id = optional(string)<br/>    eventhub_name                  = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_fqdns"></a> [fqdns](#input\_fqdns) | List of FQDNs allowed for the Cognitive Account. | `list(string)` | `[]` | no |
| <a name="input_identity"></a> [identity](#input\_identity) | Managed identity configuration for the Cognitive Account. | <pre>object({<br/>    type         = string<br/>    identity_ids = optional(list(string), [])<br/>  })</pre> | `null` | no |
| <a name="input_kind"></a> [kind](#input\_kind) | The Cognitive Account kind. Supported values: OpenAI, TextAnalytics (Language), Speech, SpeechServices. The value Language is normalized to TextAnalytics. | `string` | n/a | yes |
| <a name="input_local_auth_enabled"></a> [local\_auth\_enabled](#input\_local\_auth\_enabled) | Whether local authentication is enabled for the Cognitive Account. | `bool` | `false` | no |
| <a name="input_location"></a> [location](#input\_location) | The Azure region where the Cognitive Account should exist. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the Cognitive Account. Must start with an alphanumeric character and contain only alphanumerics, periods, dashes, or underscores. | `string` | n/a | yes |
| <a name="input_network_acls"></a> [network\_acls](#input\_network\_acls) | Network ACLs configuration for the Cognitive Account. | <pre>object({<br/>    default_action = string<br/>    bypass         = optional(string)<br/>    ip_rules       = optional(list(string), [])<br/>    virtual_network_rules = optional(list(object({<br/>      subnet_id                            = string<br/>      ignore_missing_vnet_service_endpoint = optional(bool, false)<br/>    })), [])<br/>  })</pre> | `null` | no |
| <a name="input_outbound_network_access_restricted"></a> [outbound\_network\_access\_restricted](#input\_outbound\_network\_access\_restricted) | Whether outbound network access is restricted for the Cognitive Account. | `bool` | `false` | no |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled) | Whether public network access is enabled for the Cognitive Account. | `bool` | `false` | no |
| <a name="input_rai_blocklists"></a> [rai\_blocklists](#input\_rai\_blocklists) | OpenAI RAI blocklists to create when kind is OpenAI. | <pre>list(object({<br/>    name        = string<br/>    description = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_rai_policies"></a> [rai\_policies](#input\_rai\_policies) | OpenAI RAI policies to create when kind is OpenAI. | <pre>list(object({<br/>    name             = string<br/>    base_policy_name = string<br/>    mode             = optional(string)<br/>    content_filters = list(object({<br/>      name               = string<br/>      filter_enabled     = bool<br/>      block_enabled      = bool<br/>      severity_threshold = string<br/>      source             = string<br/>    }))<br/>    tags = optional(map(string), {})<br/>  }))</pre> | `[]` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group in which to create the Cognitive Account. | `string` | n/a | yes |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | The SKU name for the Cognitive Account. Allowed values are defined by the AzureRM provider. | `string` | n/a | yes |
| <a name="input_storage"></a> [storage](#input\_storage) | Optional storage configuration for Cognitive Account user-owned storage. | <pre>list(object({<br/>    storage_account_id = string<br/>    identity_client_id = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the Cognitive Account. | `map(string)` | `{}` | no |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | Optional timeouts configuration for the Cognitive Account. | <pre>object({<br/>    create = optional(string)<br/>    update = optional(string)<br/>    read   = optional(string)<br/>    delete = optional(string)<br/>  })</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_custom_subdomain_name"></a> [custom\_subdomain\_name](#output\_custom\_subdomain\_name) | The custom subdomain name of the Cognitive Account. |
| <a name="output_customer_managed_key_id"></a> [customer\_managed\_key\_id](#output\_customer\_managed\_key\_id) | The ID of the Customer Managed Key resource when managed separately. |
| <a name="output_deployments"></a> [deployments](#output\_deployments) | OpenAI deployments created by the module. |
| <a name="output_diagnostic_settings_skipped"></a> [diagnostic\_settings\_skipped](#output\_diagnostic\_settings\_skipped) | Deprecated compatibility output. Diagnostic settings require explicit categories, so no entries are skipped. |
| <a name="output_endpoint"></a> [endpoint](#output\_endpoint) | The endpoint of the Cognitive Account. |
| <a name="output_id"></a> [id](#output\_id) | The ID of the Cognitive Account. |
| <a name="output_identity"></a> [identity](#output\_identity) | The managed identity of the Cognitive Account (if configured). |
| <a name="output_kind"></a> [kind](#output\_kind) | The kind of the Cognitive Account. |
| <a name="output_location"></a> [location](#output\_location) | The location of the Cognitive Account. |
| <a name="output_name"></a> [name](#output\_name) | The name of the Cognitive Account. |
| <a name="output_primary_access_key"></a> [primary\_access\_key](#output\_primary\_access\_key) | The primary access key for the Cognitive Account (null when local auth is disabled). |
| <a name="output_public_network_access_enabled"></a> [public\_network\_access\_enabled](#output\_public\_network\_access\_enabled) | Whether public network access is enabled for the Cognitive Account. |
| <a name="output_rai_blocklists"></a> [rai\_blocklists](#output\_rai\_blocklists) | RAI blocklists created by the module. |
| <a name="output_rai_policies"></a> [rai\_policies](#output\_rai\_policies) | RAI policies created by the module. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The resource group name of the Cognitive Account. |
| <a name="output_secondary_access_key"></a> [secondary\_access\_key](#output\_secondary\_access\_key) | The secondary access key for the Cognitive Account (null when local auth is disabled). |
| <a name="output_sku_name"></a> [sku\_name](#output\_sku\_name) | The SKU name of the Cognitive Account. |
<!-- END_TF_DOCS -->

## Additional Documentation

- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
- [docs/README.md](docs/README.md) - Additional module documentation
- [docs/IMPORT.md](docs/IMPORT.md) - Import instructions
