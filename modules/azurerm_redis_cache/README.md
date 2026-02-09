# Terraform Azure Redis Cache Module

## Module Version

<!-- BEGIN_VERSION -->
Current version: **vUnreleased**
<!-- END_VERSION -->

## Description

Azure Redis Cache Terraform module with Redis-specific sub-resources including
firewall rules, linked servers, patch schedule, and diagnostic settings.

## Usage

```hcl
terraform {
  required_version = ">= 1.12.2"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.57.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-redis-example"
  location = "westeurope"
}

module "redis_cache" {
  source = "path/to/azurerm_redis_cache"

  name                = "rediscacheexample001"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  sku_name = "Standard"
  family   = "C"
  capacity = 1

  tags = {
    Environment = "Development"
    Project     = "Example"
  }
}
```

## Examples

<!-- BEGIN_EXAMPLES -->
- [Basic](examples/basic) - This example demonstrates a minimal Azure Redis Cache deployment using the
- [Complete](examples/complete) - This example demonstrates a Premium Redis Cache deployment with clustering,
- [Diagnostic Settings](examples/diagnostic-settings) - This example demonstrates sending Redis Cache metrics to a Log Analytics
- [Firewall Rules](examples/firewall-rules) - This example demonstrates enabling public access with firewall rules to restrict
- [Linked Server](examples/linked-server) - This example demonstrates linking a primary Redis Cache to a secondary cache
- [Patch Schedule](examples/patch-schedule) - This example demonstrates configuring a patch schedule for a Premium Redis Cache.
- [Redis Configuration](examples/redis-configuration) - This example demonstrates configuring Redis-specific settings such as memory
- [Secure](examples/secure) - This example demonstrates a security-focused Redis Cache deployment with VNet
- [Vnet Injection](examples/vnet-injection) - This example demonstrates deploying a Premium Redis Cache using VNet injection
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
| [azurerm_monitor_diagnostic_setting.monitor_diagnostic_setting](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_redis_cache.redis_cache](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/redis_cache) | resource |
| [azurerm_redis_firewall_rule.redis_firewall_rule](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/redis_firewall_rule) | resource |
| [azurerm_redis_linked_server.redis_linked_server](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/redis_linked_server) | resource |
| [azurerm_monitor_diagnostic_categories.redis_cache](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/data-sources/monitor_diagnostic_categories) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_keys_authentication_enabled"></a> [access\_keys\_authentication\_enabled](#input\_access\_keys\_authentication\_enabled) | Whether access key authentication is enabled. When disabled, Active Directory authentication must be enabled in redis\_configuration. | `bool` | `true` | no |
| <a name="input_capacity"></a> [capacity](#input\_capacity) | The SKU capacity. Valid ranges depend on sku\_name/family. | `number` | n/a | yes |
| <a name="input_diagnostic_settings"></a> [diagnostic\_settings](#input\_diagnostic\_settings) | Diagnostic settings for Redis Cache logs and metrics.<br/><br/>Provide explicit log\_categories and/or metric\_categories and at least one destination. | <pre>list(object({<br/>    name                           = string<br/>    log_categories                 = optional(list(string))<br/>    metric_categories              = optional(list(string))<br/>    log_analytics_workspace_id     = optional(string)<br/>    log_analytics_destination_type = optional(string)<br/>    storage_account_id             = optional(string)<br/>    eventhub_authorization_rule_id = optional(string)<br/>    eventhub_name                  = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_family"></a> [family](#input\_family) | The SKU family. Possible values: C (Basic/Standard) or P (Premium). | `string` | n/a | yes |
| <a name="input_firewall_rules"></a> [firewall\_rules](#input\_firewall\_rules) | Firewall rules for the Redis Cache (public access only). | <pre>list(object({<br/>    name             = string<br/>    start_ip_address = string<br/>    end_ip_address   = string<br/>  }))</pre> | `[]` | no |
| <a name="input_identity"></a> [identity](#input\_identity) | Managed identity configuration. | <pre>object({<br/>    type         = string<br/>    identity_ids = optional(list(string))<br/>  })</pre> | `null` | no |
| <a name="input_linked_servers"></a> [linked\_servers](#input\_linked\_servers) | Linked Redis servers (geo-replication) for Premium caches. | <pre>list(object({<br/>    name                        = string<br/>    linked_redis_cache_id       = string<br/>    linked_redis_cache_location = string<br/>    server_role                 = string<br/>  }))</pre> | `[]` | no |
| <a name="input_location"></a> [location](#input\_location) | The Azure region where the Redis Cache should be created. | `string` | n/a | yes |
| <a name="input_minimum_tls_version"></a> [minimum\_tls\_version](#input\_minimum\_tls\_version) | The minimum TLS version. Possible values: 1.0, 1.1, 1.2. | `string` | `"1.2"` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the Redis Cache. | `string` | n/a | yes |
| <a name="input_non_ssl_port_enabled"></a> [non\_ssl\_port\_enabled](#input\_non\_ssl\_port\_enabled) | Whether the non-SSL port (6379) is enabled. | `bool` | `false` | no |
| <a name="input_patch_schedule"></a> [patch\_schedule](#input\_patch\_schedule) | Patch schedule entries for Premium caches. | <pre>list(object({<br/>    day_of_week        = string<br/>    start_hour_utc     = optional(number)<br/>    maintenance_window = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_private_static_ip_address"></a> [private\_static\_ip\_address](#input\_private\_static\_ip\_address) | The static IP address for the Redis Cache when using subnet injection (Premium only). | `string` | `null` | no |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled) | Whether public network access is enabled. | `bool` | `true` | no |
| <a name="input_redis_configuration"></a> [redis\_configuration](#input\_redis\_configuration) | Redis configuration settings.<br/><br/>Note: maxclients is computed by the provider and cannot be set. | <pre>object({<br/>    active_directory_authentication_enabled = optional(bool)<br/>    aof_backup_enabled                      = optional(bool)<br/>    aof_storage_connection_string_0         = optional(string)<br/>    aof_storage_connection_string_1         = optional(string)<br/>    authentication_enabled                  = optional(bool)<br/>    data_persistence_authentication_method  = optional(string)<br/>    maxfragmentationmemory_reserved         = optional(number)<br/>    maxmemory_delta                         = optional(number)<br/>    maxmemory_policy                        = optional(string)<br/>    maxmemory_reserved                      = optional(number)<br/>    notify_keyspace_events                  = optional(string)<br/>    rdb_backup_enabled                      = optional(bool)<br/>    rdb_backup_frequency                    = optional(number)<br/>    rdb_backup_max_snapshot_count           = optional(number)<br/>    rdb_storage_connection_string           = optional(string)<br/>    storage_account_subscription_id         = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_redis_version"></a> [redis\_version](#input\_redis\_version) | The Redis version. Possible values: 4, 6. | `string` | `"6"` | no |
| <a name="input_replicas_per_master"></a> [replicas\_per\_master](#input\_replicas\_per\_master) | The number of replicas per master (Premium only). | `number` | `null` | no |
| <a name="input_replicas_per_primary"></a> [replicas\_per\_primary](#input\_replicas\_per\_primary) | The number of replicas per primary (Premium only). | `number` | `null` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group in which to create the Redis Cache. | `string` | n/a | yes |
| <a name="input_shard_count"></a> [shard\_count](#input\_shard\_count) | The number of shards (Premium only). | `number` | `null` | no |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | The SKU name of the Redis Cache. Possible values: Basic, Standard, Premium. | `string` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | The ID of the subnet to deploy the Redis Cache into (Premium only). | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the Redis Cache. | `map(string)` | `{}` | no |
| <a name="input_tenant_settings"></a> [tenant\_settings](#input\_tenant\_settings) | Tenant settings for the Redis Cache. | `map(string)` | `{}` | no |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | Timeouts for Redis Cache operations. | <pre>object({<br/>    create = optional(string)<br/>    read   = optional(string)<br/>    update = optional(string)<br/>    delete = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_zones"></a> [zones](#input\_zones) | The availability zones in which to deploy the Redis Cache. | `set(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_diagnostic_settings_skipped"></a> [diagnostic\_settings\_skipped](#output\_diagnostic\_settings\_skipped) | Diagnostic settings entries skipped because no log or metric categories were supplied. |
| <a name="output_firewall_rules"></a> [firewall\_rules](#output\_firewall\_rules) | Firewall rules created for the Redis Cache. |
| <a name="output_hostname"></a> [hostname](#output\_hostname) | The hostname of the Redis Cache. |
| <a name="output_id"></a> [id](#output\_id) | The ID of the Redis Cache. |
| <a name="output_identity"></a> [identity](#output\_identity) | The managed identity configuration for the Redis Cache. |
| <a name="output_linked_servers"></a> [linked\_servers](#output\_linked\_servers) | Linked servers created for the Redis Cache. |
| <a name="output_location"></a> [location](#output\_location) | The location of the Redis Cache. |
| <a name="output_name"></a> [name](#output\_name) | The name of the Redis Cache. |
| <a name="output_port"></a> [port](#output\_port) | The non-SSL port of the Redis Cache. |
| <a name="output_primary_access_key"></a> [primary\_access\_key](#output\_primary\_access\_key) | The primary access key for the Redis Cache. |
| <a name="output_primary_connection_string"></a> [primary\_connection\_string](#output\_primary\_connection\_string) | The primary connection string for the Redis Cache. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The resource group name of the Redis Cache. |
| <a name="output_secondary_access_key"></a> [secondary\_access\_key](#output\_secondary\_access\_key) | The secondary access key for the Redis Cache. |
| <a name="output_secondary_connection_string"></a> [secondary\_connection\_string](#output\_secondary\_connection\_string) | The secondary connection string for the Redis Cache. |
| <a name="output_ssl_port"></a> [ssl\_port](#output\_ssl\_port) | The SSL port of the Redis Cache. |
<!-- END_TF_DOCS -->

## Additional Documentation

- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
