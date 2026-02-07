# Terraform Azure Event Hub Namespace Module

## Module Version

<!-- BEGIN_VERSION -->
Current version: **vUnreleased**
<!-- END_VERSION -->

## Description

Manages Azure Event Hub Namespaces and related sub-resources (authorization rules,
schema registry groups, network rule set, disaster recovery config, CMK, and
diagnostic settings).

## Usage

```hcl
module "eventhub_namespace" {
  source = "path/to/azurerm_eventhub_namespace"

  name                = "example-ehns"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  sku = "Standard"

  schema_groups = [
    {
      name                 = "orders"
      schema_type          = "Avro"
      schema_compatibility = "Backward"
    }
  ]

  tags = {
    Environment = "Development"
    Project     = "Example"
  }
}
```

## Schema Registry Groups

The module exposes namespace schema registry support end-to-end:

- Input: `schema_groups`
- Managed resource: `azurerm_eventhub_namespace_schema_group.schema_group`
- Output: `schema_group_ids`

## Security Considerations

- Disable `public_network_access_enabled` and use private endpoints for private access.
- Disable `local_authentication_enabled` when using Entra ID (AAD) only.
- Use `customer_managed_key` with a managed identity and Key Vault access policies.
- Keep `minimum_tls_version` at `1.2`.

## Examples

<!-- BEGIN_EXAMPLES -->
- [Basic](examples/basic) - This example creates a minimal Event Hub Namespace with Standard SKU.
- [Complete](examples/complete) - This example demonstrates a more comprehensive Event Hub Namespace configuration.
- [Disaster Recovery](examples/disaster-recovery) - This example demonstrates configuring disaster recovery between two Event Hub Namespaces.
- [Network Rule Set](examples/network-rule-set) - This example demonstrates configuring an Event Hub Namespace with a network rule set (IP rules and VNet rules).
- [Secure](examples/secure) - This example demonstrates a security-focused Event Hub Namespace configuration.
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
| [azurerm_eventhub_namespace.namespace](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/eventhub_namespace) | resource |
| [azurerm_eventhub_namespace_authorization_rule.authorization_rules](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/eventhub_namespace_authorization_rule) | resource |
| [azurerm_eventhub_namespace_customer_managed_key.customer_managed_key](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/eventhub_namespace_customer_managed_key) | resource |
| [azurerm_eventhub_namespace_disaster_recovery_config.disaster_recovery](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/eventhub_namespace_disaster_recovery_config) | resource |
| [azurerm_monitor_diagnostic_setting.diagnostic_settings](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_monitor_diagnostic_categories.eventhub_namespace](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/data-sources/monitor_diagnostic_categories) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_auto_inflate_enabled"></a> [auto\_inflate\_enabled](#input\_auto\_inflate\_enabled) | Is Auto Inflate enabled for the Event Hub Namespace? | `bool` | `false` | no |
| <a name="input_capacity"></a> [capacity](#input\_capacity) | Specifies the Capacity / Throughput Units for a Standard SKU namespace. Defaults to 1. | `number` | `1` | no |
| <a name="input_customer_managed_key"></a> [customer\_managed\_key](#input\_customer\_managed\_key) | Customer-managed key configuration for the Event Hub Namespace. | <pre>object({<br/>    key_vault_key_ids                 = list(string)<br/>    user_assigned_identity_id         = optional(string)<br/>    infrastructure_encryption_enabled = optional(bool)<br/>  })</pre> | `null` | no |
| <a name="input_dedicated_cluster_id"></a> [dedicated\_cluster\_id](#input\_dedicated\_cluster\_id) | Specifies the ID of the Event Hub Dedicated Cluster where this Namespace should be created. | `string` | `null` | no |
| <a name="input_diagnostic_settings"></a> [diagnostic\_settings](#input\_diagnostic\_settings) | Diagnostic settings for the Event Hub Namespace.<br/><br/>Provide either log\_categories/metric\_categories or areas to select categories.<br/>If neither is provided, areas defaults to ["all"]. | <pre>list(object({<br/>    name                           = string<br/>    areas                          = optional(list(string))<br/>    log_categories                 = optional(list(string))<br/>    metric_categories              = optional(list(string))<br/>    log_analytics_workspace_id     = optional(string)<br/>    log_analytics_destination_type = optional(string)<br/>    storage_account_id             = optional(string)<br/>    eventhub_authorization_rule_id = optional(string)<br/>    eventhub_name                  = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_disaster_recovery_config"></a> [disaster\_recovery\_config](#input\_disaster\_recovery\_config) | Optional disaster recovery configuration for the Event Hub Namespace. | <pre>object({<br/>    name                 = string<br/>    partner_namespace_id = string<br/>  })</pre> | `null` | no |
| <a name="input_identity"></a> [identity](#input\_identity) | Managed identity configuration for the Event Hub Namespace. | <pre>object({<br/>    type         = string<br/>    identity_ids = optional(list(string), [])<br/>  })</pre> | `null` | no |
| <a name="input_local_authentication_enabled"></a> [local\_authentication\_enabled](#input\_local\_authentication\_enabled) | Is SAS authentication enabled for the Event Hub Namespace? | `bool` | `true` | no |
| <a name="input_location"></a> [location](#input\_location) | The Azure region where the Event Hub Namespace should exist. | `string` | n/a | yes |
| <a name="input_maximum_throughput_units"></a> [maximum\_throughput\_units](#input\_maximum\_throughput\_units) | Specifies the maximum number of throughput units when Auto Inflate is enabled. Valid values range from 1 to 40. | `number` | `null` | no |
| <a name="input_minimum_tls_version"></a> [minimum\_tls\_version](#input\_minimum\_tls\_version) | The minimum supported TLS version for this Event Hub Namespace. In azurerm 4.57.0 only 1.2 is supported. | `string` | `"1.2"` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the Event Hub Namespace. | `string` | n/a | yes |
| <a name="input_namespace_authorization_rules"></a> [namespace\_authorization\_rules](#input\_namespace\_authorization\_rules) | Authorization rules for the Event Hub Namespace. | <pre>list(object({<br/>    name   = string<br/>    listen = optional(bool, false)<br/>    send   = optional(bool, false)<br/>    manage = optional(bool, false)<br/>  }))</pre> | `[]` | no |
| <a name="input_network_rule_set"></a> [network\_rule\_set](#input\_network\_rule\_set) | Network rule set configuration for the Event Hub Namespace. | <pre>object({<br/>    default_action                 = string<br/>    public_network_access_enabled  = optional(bool)<br/>    trusted_service_access_enabled = optional(bool)<br/>    ip_rules = optional(list(object({<br/>      ip_mask = string<br/>      action  = optional(string, "Allow")<br/>    })), [])<br/>    vnet_rules = optional(list(object({<br/>      subnet_id                            = string<br/>      ignore_missing_vnet_service_endpoint = optional(bool)<br/>    })), [])<br/>  })</pre> | `null` | no |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled) | Is public network access enabled for the Event Hub Namespace? | `bool` | `true` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group in which to create the Event Hub Namespace. | `string` | n/a | yes |
| <a name="input_sku"></a> [sku](#input\_sku) | Defines which tier to use. Valid options are Basic, Standard, and Premium. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the resource. | `map(string)` | `{}` | no |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | Custom timeouts for the Event Hub Namespace resource. | <pre>object({<br/>    create = optional(string)<br/>    read   = optional(string)<br/>    update = optional(string)<br/>    delete = optional(string)<br/>  })</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_authorization_rules"></a> [authorization\_rules](#output\_authorization\_rules) | Authorization rules created for the namespace. |
| <a name="output_auto_inflate_enabled"></a> [auto\_inflate\_enabled](#output\_auto\_inflate\_enabled) | Whether auto inflate is enabled. |
| <a name="output_capacity"></a> [capacity](#output\_capacity) | The capacity (throughput units) for the Event Hub Namespace. |
| <a name="output_customer_managed_key_id"></a> [customer\_managed\_key\_id](#output\_customer\_managed\_key\_id) | The ID of the customer managed key association, if configured. |
| <a name="output_default_primary_connection_string"></a> [default\_primary\_connection\_string](#output\_default\_primary\_connection\_string) | The primary connection string for RootManageSharedAccessKey, if present. |
| <a name="output_default_primary_key"></a> [default\_primary\_key](#output\_default\_primary\_key) | The primary key for RootManageSharedAccessKey, if present. |
| <a name="output_default_secondary_connection_string"></a> [default\_secondary\_connection\_string](#output\_default\_secondary\_connection\_string) | The secondary connection string for RootManageSharedAccessKey, if present. |
| <a name="output_default_secondary_key"></a> [default\_secondary\_key](#output\_default\_secondary\_key) | The secondary key for RootManageSharedAccessKey, if present. |
| <a name="output_diagnostic_settings_skipped"></a> [diagnostic\_settings\_skipped](#output\_diagnostic\_settings\_skipped) | Diagnostic settings entries skipped because no log or metric categories were supplied. |
| <a name="output_disaster_recovery_config_id"></a> [disaster\_recovery\_config\_id](#output\_disaster\_recovery\_config\_id) | The ID of the disaster recovery configuration, if configured. |
| <a name="output_id"></a> [id](#output\_id) | The Event Hub Namespace ID. |
| <a name="output_identity"></a> [identity](#output\_identity) | The managed identity configuration for the namespace. |
| <a name="output_local_authentication_enabled"></a> [local\_authentication\_enabled](#output\_local\_authentication\_enabled) | Whether SAS authentication is enabled. |
| <a name="output_location"></a> [location](#output\_location) | The location of the Event Hub Namespace. |
| <a name="output_maximum_throughput_units"></a> [maximum\_throughput\_units](#output\_maximum\_throughput\_units) | The maximum throughput units when auto inflate is enabled. |
| <a name="output_minimum_tls_version"></a> [minimum\_tls\_version](#output\_minimum\_tls\_version) | The minimum TLS version for the namespace. |
| <a name="output_name"></a> [name](#output\_name) | The name of the Event Hub Namespace. |
| <a name="output_public_network_access_enabled"></a> [public\_network\_access\_enabled](#output\_public\_network\_access\_enabled) | Whether public network access is enabled. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The resource group name of the Event Hub Namespace. |
| <a name="output_sku"></a> [sku](#output\_sku) | The SKU of the Event Hub Namespace. |
<!-- END_TF_DOCS -->

## Additional Documentation

- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
