# Terraform Azure Managed Redis Module

## Module Version

<!-- BEGIN_VERSION -->
Current version: **vUnreleased**
<!-- END_VERSION -->

## Description

Azure Managed Redis Terraform module with support for the core Managed Redis
resource, optional geo-replication membership management, and inline diagnostic
settings.

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
  name     = "rg-managed-redis-example"
  location = "westeurope"
}

module "managed_redis" {
  source = "path/to/azurerm_managed_redis"

  name                = "managed-redis-example"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  managed_redis = {
    sku_name = "Balanced_B3"
  }

  default_database = {
    clustering_policy = "OSSCluster"
  }

  tags = {
    Environment = "Development"
    Project     = "Example"
  }
}
```

## Examples

<!-- BEGIN_EXAMPLES -->
- [Basic](examples/basic) - This example demonstrates a minimal Azure Managed Redis deployment with the
- [Complete](examples/complete) - This example demonstrates a fuller Managed Redis deployment with high
- [Customer Managed Key](examples/customer-managed-key) - This example demonstrates Managed Redis with customer-managed key encryption and
- [Diagnostic Settings](examples/diagnostic-settings) - This example demonstrates how to send Managed Redis connection logs and metrics
- [Geo Replication](examples/geo-replication) - This example demonstrates two Managed Redis instances joined into one
- [Secure](examples/secure) - This example demonstrates Managed Redis with public network access disabled and
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
| [azurerm_managed_redis.managed_redis](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/managed_redis) | resource |
| [azurerm_managed_redis_geo_replication.geo_replication](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/managed_redis_geo_replication) | resource |
| [azurerm_monitor_diagnostic_setting.monitor_diagnostic_settings](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/monitor_diagnostic_setting) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_customer_managed_key"></a> [customer\_managed\_key](#input\_customer\_managed\_key) | Customer-managed key configuration for Managed Redis.<br/><br/>This requires a user-assigned identity with access to the specified Key Vault key. | <pre>object({<br/>    key_vault_key_id          = string<br/>    user_assigned_identity_id = string<br/>  })</pre> | `null` | no |
| <a name="input_default_database"></a> [default\_database](#input\_default\_database) | Configuration for the default Managed Redis database.<br/><br/>Leave as the default empty object to create the default database with provider defaults.<br/>Set to null only when you intentionally want to remove the default database for troubleshooting. | <pre>object({<br/>    access_keys_authentication_enabled            = optional(bool, false)<br/>    client_protocol                               = optional(string, "Encrypted")<br/>    clustering_policy                             = optional(string, "OSSCluster")<br/>    eviction_policy                               = optional(string, "VolatileLRU")<br/>    geo_replication_group_name                    = optional(string)<br/>    persistence_append_only_file_backup_frequency = optional(string)<br/>    persistence_redis_database_backup_frequency   = optional(string)<br/>    modules = optional(list(object({<br/>      name = string<br/>      args = optional(string)<br/>    })), [])<br/>  })</pre> | `{}` | no |
| <a name="input_geo_replication"></a> [geo\_replication](#input\_geo\_replication) | Optional geo-replication membership management for this Managed Redis instance.<br/><br/>The local Managed Redis instance is always the managed\_redis\_id.<br/>Provide only the linked Managed Redis IDs for the rest of the geo-replication group. | <pre>object({<br/>    linked_managed_redis_ids = set(string)<br/>    timeouts = optional(object({<br/>      create = optional(string)<br/>      read   = optional(string)<br/>      update = optional(string)<br/>      delete = optional(string)<br/>    }))<br/>  })</pre> | `null` | no |
| <a name="input_identity"></a> [identity](#input\_identity) | Managed identity configuration for Managed Redis.<br/><br/>type can be SystemAssigned, UserAssigned, or SystemAssigned, UserAssigned.<br/>identity\_ids must be provided when the type includes UserAssigned. | <pre>object({<br/>    type         = string<br/>    identity_ids = optional(list(string))<br/>  })</pre> | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region where the Managed Redis instance is created.<br/>Geo-replication examples may use a different region for linked instances created outside this module. | `string` | n/a | yes |
| <a name="input_managed_redis"></a> [managed\_redis](#input\_managed\_redis) | Core Managed Redis configuration.<br/><br/>sku\_name: Managed Redis SKU.<br/>high\_availability\_enabled: Whether HA is enabled for the cluster.<br/>public\_network\_access: Public network access mode, either Enabled or Disabled.<br/>timeouts: Optional custom create/read/update/delete timeouts. | <pre>object({<br/>    sku_name                  = string<br/>    high_availability_enabled = optional(bool, true)<br/>    public_network_access     = optional(string, "Enabled")<br/>    timeouts = optional(object({<br/>      create = optional(string)<br/>      read   = optional(string)<br/>      update = optional(string)<br/>      delete = optional(string)<br/>    }))<br/>  })</pre> | n/a | yes |
| <a name="input_monitoring"></a> [monitoring](#input\_monitoring) | Monitoring configuration for Managed Redis.<br/><br/>Diagnostic settings for logs and metrics. Provide explicit log\_categories<br/>and/or metric\_categories and at least one destination (Log Analytics,<br/>Storage, or Event Hub). | <pre>list(object({<br/>    name                           = string<br/>    log_categories                 = optional(list(string))<br/>    metric_categories              = optional(list(string))<br/>    log_analytics_workspace_id     = optional(string)<br/>    log_analytics_destination_type = optional(string)<br/>    storage_account_id             = optional(string)<br/>    eventhub_authorization_rule_id = optional(string)<br/>    eventhub_name                  = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the Managed Redis instance.<br/>Use 1-63 characters with letters, numbers, and hyphens. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group where the Managed Redis instance and child resources are created.<br/>The resource group must already exist. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the Managed Redis instance.<br/>Provide a map of string keys and values. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_customer_managed_key"></a> [customer\_managed\_key](#output\_customer\_managed\_key) | Customer-managed key configuration for the Managed Redis instance. |
| <a name="output_default_database"></a> [default\_database](#output\_default\_database) | Sanitized details of the Managed Redis default database. |
| <a name="output_default_database_primary_access_key"></a> [default\_database\_primary\_access\_key](#output\_default\_database\_primary\_access\_key) | The primary access key for the default database, when access key authentication is enabled. |
| <a name="output_default_database_secondary_access_key"></a> [default\_database\_secondary\_access\_key](#output\_default\_database\_secondary\_access\_key) | The secondary access key for the default database, when access key authentication is enabled. |
| <a name="output_diagnostic_settings_skipped"></a> [diagnostic\_settings\_skipped](#output\_diagnostic\_settings\_skipped) | Diagnostic settings entries skipped because no log or metric categories were supplied. |
| <a name="output_geo_replication"></a> [geo\_replication](#output\_geo\_replication) | Geo-replication membership details managed by this module. |
| <a name="output_high_availability_enabled"></a> [high\_availability\_enabled](#output\_high\_availability\_enabled) | Whether high availability is enabled for the Managed Redis instance. |
| <a name="output_hostname"></a> [hostname](#output\_hostname) | The DNS hostname of the Managed Redis instance. |
| <a name="output_id"></a> [id](#output\_id) | The ID of the Managed Redis instance. |
| <a name="output_identity"></a> [identity](#output\_identity) | Managed identity configuration for the Managed Redis instance. |
| <a name="output_location"></a> [location](#output\_location) | The Azure region of the Managed Redis instance. |
| <a name="output_name"></a> [name](#output\_name) | The name of the Managed Redis instance. |
| <a name="output_public_network_access"></a> [public\_network\_access](#output\_public\_network\_access) | The public network access mode of the Managed Redis instance. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The resource group containing the Managed Redis instance. |
| <a name="output_sku_name"></a> [sku\_name](#output\_sku\_name) | The SKU name of the Managed Redis instance. |
| <a name="output_tags"></a> [tags](#output\_tags) | The tags assigned to the Managed Redis instance. |
<!-- END_TF_DOCS -->

## Additional Documentation

- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
- [docs/README.md](docs/README.md) - Extended documentation and scope notes
- [docs/IMPORT.md](docs/IMPORT.md) - Importing existing Managed Redis resources
