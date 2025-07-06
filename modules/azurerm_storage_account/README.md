<!-- BEGIN_TF_DOCS -->


## Module Version

Current version: **SAv1.0.0**

## Description

This module creates a comprehensive Azure Storage Account with support for all enterprise features including security, monitoring, private endpoints, and lifecycle management.

## Usage

```hcl
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-storage-simple-example"
  location = "West Europe"
}

module "storage_account" {
  source = "../../"

  name                     = "stexamplesimple001"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  # Enable shared access keys for simple example
  security_settings = {
    shared_access_key_enabled = true
  }

  tags = {
    Environment = "Development"
    Project     = "Example"
  }
}
```

## Examples

- [Simple](examples/simple) - Basic storage account configuration
- [Complete](examples/complete) - Full-featured storage account with all enterprise capabilities  
- [Secure](examples/secure) - Maximum security configuration
- [Multi-Region](examples/multi-region) - Multi-region setup with disaster recovery

## Requirements

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | 4.35.0 |

## Providers

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.35.0 |

## Modules

## Modules

No modules.

## Resources

## Resources

| Name | Type |
|------|------|
| [azurerm_monitor_diagnostic_setting.blob_diagnostic_setting](https://registry.terraform.io/providers/hashicorp/azurerm/4.35.0/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_monitor_diagnostic_setting.monitor_diagnostic_setting](https://registry.terraform.io/providers/hashicorp/azurerm/4.35.0/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_private_endpoint.private_endpoint](https://registry.terraform.io/providers/hashicorp/azurerm/4.35.0/docs/resources/private_endpoint) | resource |
| [azurerm_storage_account.storage_account](https://registry.terraform.io/providers/hashicorp/azurerm/4.35.0/docs/resources/storage_account) | resource |
| [azurerm_storage_account_queue_properties.queue_properties](https://registry.terraform.io/providers/hashicorp/azurerm/4.35.0/docs/resources/storage_account_queue_properties) | resource |
| [azurerm_storage_account_static_website.static_website](https://registry.terraform.io/providers/hashicorp/azurerm/4.35.0/docs/resources/storage_account_static_website) | resource |
| [azurerm_storage_container.storage_container](https://registry.terraform.io/providers/hashicorp/azurerm/4.35.0/docs/resources/storage_container) | resource |
| [azurerm_storage_management_policy.storage_management_policy](https://registry.terraform.io/providers/hashicorp/azurerm/4.35.0/docs/resources/storage_management_policy) | resource |
| [azurerm_storage_queue.storage_queue](https://registry.terraform.io/providers/hashicorp/azurerm/4.35.0/docs/resources/storage_queue) | resource |
| [azurerm_storage_share.storage_share](https://registry.terraform.io/providers/hashicorp/azurerm/4.35.0/docs/resources/storage_share) | resource |
| [azurerm_storage_table.storage_table](https://registry.terraform.io/providers/hashicorp/azurerm/4.35.0/docs/resources/storage_table) | resource |

## Inputs

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_tier"></a> [access\_tier](#input\_access\_tier) | Defines the access tier for BlobStorage, FileStorage and StorageV2 accounts. Valid options are Hot and Cool. | `string` | `"Hot"` | no |
| <a name="input_account_kind"></a> [account\_kind](#input\_account\_kind) | Defines the Kind of account. Valid options are BlobStorage, BlockBlobStorage, FileStorage, Storage and StorageV2. | `string` | `"StorageV2"` | no |
| <a name="input_account_replication_type"></a> [account\_replication\_type](#input\_account\_replication\_type) | Defines the type of replication to use for this storage account. | `string` | `"ZRS"` | no |
| <a name="input_account_tier"></a> [account\_tier](#input\_account\_tier) | Defines the Tier to use for this storage account. Valid options are Standard and Premium. | `string` | `"Standard"` | no |
| <a name="input_azure_files_authentication"></a> [azure\_files\_authentication](#input\_azure\_files\_authentication) | Azure Files authentication configuration. | <pre>object({<br/>    directory_type = string<br/>    active_directory = optional(object({<br/>      domain_name         = string<br/>      domain_guid         = string<br/>      domain_sid          = string<br/>      storage_sid         = string<br/>      forest_name         = string<br/>      netbios_domain_name = string<br/>    }))<br/>  })</pre> | `null` | no |
| <a name="input_blob_properties"></a> [blob\_properties](#input\_blob\_properties) | Blob service properties including soft delete and versioning. | <pre>object({<br/>    versioning_enabled       = optional(bool, true)<br/>    change_feed_enabled      = optional(bool, true)<br/>    last_access_time_enabled = optional(bool, false)<br/>    default_service_version  = optional(string)<br/>    delete_retention_policy = optional(object({<br/>      enabled = optional(bool, true)<br/>      days    = optional(number, 7)<br/>    }), { enabled = true, days = 7 })<br/>    container_delete_retention_policy = optional(object({<br/>      enabled = optional(bool, true)<br/>      days    = optional(number, 7)<br/>    }), { enabled = true, days = 7 })<br/>    cors_rules = optional(list(object({<br/>      allowed_headers    = list(string)<br/>      allowed_methods    = list(string)<br/>      allowed_origins    = list(string)<br/>      exposed_headers    = list(string)<br/>      max_age_in_seconds = number<br/>    })), [])<br/>  })</pre> | `{}` | no |
| <a name="input_containers"></a> [containers](#input\_containers) | List of storage containers to create. | <pre>list(object({<br/>    name                  = string<br/>    container_access_type = optional(string, "private")<br/>    metadata              = optional(map(string), {})<br/>  }))</pre> | `[]` | no |
| <a name="input_customer_managed_key"></a> [customer\_managed\_key](#input\_customer\_managed\_key) | Customer managed key configuration for encryption at rest. | <pre>object({<br/>    key_vault_key_id          = string<br/>    user_assigned_identity_id = string<br/>  })</pre> | `null` | no |
| <a name="input_diagnostic_settings"></a> [diagnostic\_settings](#input\_diagnostic\_settings) | Diagnostic settings configuration for audit logging. | <pre>object({<br/>    enabled                    = optional(bool, true)<br/>    log_analytics_workspace_id = optional(string)<br/>    storage_account_id         = optional(string)<br/>    eventhub_auth_rule_id      = optional(string)<br/>    logs = optional(object({<br/>      storage_read   = optional(bool, true)<br/>      storage_write  = optional(bool, true)<br/>      storage_delete = optional(bool, true)<br/>      retention_days = optional(number, 7)<br/>    }), {})<br/>    metrics = optional(object({<br/>      transaction    = optional(bool, true)<br/>      capacity       = optional(bool, true)<br/>      retention_days = optional(number, 7)<br/>    }), {})<br/>  })</pre> | <pre>{<br/>  "enabled": false<br/>}</pre> | no |
| <a name="input_encryption"></a> [encryption](#input\_encryption) | Encryption configuration for the storage account. | <pre>object({<br/>    enabled                           = optional(bool, true)<br/>    infrastructure_encryption_enabled = optional(bool, true)<br/>    key_vault_key_id                  = optional(string)<br/>    user_assigned_identity_id         = optional(string)<br/>  })</pre> | <pre>{<br/>  "enabled": true,<br/>  "infrastructure_encryption_enabled": true<br/>}</pre> | no |
| <a name="input_file_shares"></a> [file\_shares](#input\_file\_shares) | List of file shares to create. | <pre>list(object({<br/>    name             = string<br/>    quota            = optional(number, 5120)<br/>    access_tier      = optional(string, "Hot")<br/>    enabled_protocol = optional(string, "SMB")<br/>    metadata         = optional(map(string), {})<br/>  }))</pre> | `[]` | no |
| <a name="input_identity"></a> [identity](#input\_identity) | Identity configuration for the storage account. | <pre>object({<br/>    type         = string<br/>    identity_ids = optional(list(string))<br/>  })</pre> | `null` | no |
| <a name="input_lifecycle_rules"></a> [lifecycle\_rules](#input\_lifecycle\_rules) | List of lifecycle management rules for the storage account. | <pre>list(object({<br/>    name    = string<br/>    enabled = optional(bool, true)<br/>    filters = object({<br/>      blob_types   = list(string)<br/>      prefix_match = optional(list(string), [])<br/>    })<br/>    actions = object({<br/>      base_blob = optional(object({<br/>        tier_to_cool_after_days_since_modification_greater_than        = optional(number)<br/>        tier_to_archive_after_days_since_modification_greater_than     = optional(number)<br/>        delete_after_days_since_modification_greater_than              = optional(number)<br/>        tier_to_cool_after_days_since_last_access_time_greater_than    = optional(number)<br/>        tier_to_archive_after_days_since_last_access_time_greater_than = optional(number)<br/>        delete_after_days_since_last_access_time_greater_than          = optional(number)<br/>      }))<br/>      snapshot = optional(object({<br/>        change_tier_to_archive_after_days_since_creation = optional(number)<br/>        change_tier_to_cool_after_days_since_creation    = optional(number)<br/>        delete_after_days_since_creation_greater_than    = optional(number)<br/>      }))<br/>      version = optional(object({<br/>        change_tier_to_archive_after_days_since_creation = optional(number)<br/>        change_tier_to_cool_after_days_since_creation    = optional(number)<br/>        delete_after_days_since_creation                 = optional(number)<br/>      }))<br/>    })<br/>  }))</pre> | `[]` | no |
| <a name="input_location"></a> [location](#input\_location) | The Azure Region where the Storage Account should exist. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the storage account. Must be globally unique. | `string` | n/a | yes |
| <a name="input_network_rules"></a> [network\_rules](#input\_network\_rules) | Network rules for the storage account. | <pre>object({<br/>    default_action             = string<br/>    bypass                     = optional(set(string), ["AzureServices"])<br/>    ip_rules                   = optional(set(string), [])<br/>    virtual_network_subnet_ids = optional(set(string), [])<br/>    private_link_access = optional(list(object({<br/>      endpoint_resource_id = string<br/>      endpoint_tenant_id   = optional(string)<br/>    })), [])<br/>  })</pre> | <pre>{<br/>  "bypass": [<br/>    "AzureServices"<br/>  ],<br/>  "default_action": "Deny"<br/>}</pre> | no |
| <a name="input_private_endpoints"></a> [private\_endpoints](#input\_private\_endpoints) | List of private endpoints to create for the storage account. | <pre>list(object({<br/>    name                            = string<br/>    subresource_names               = list(string)<br/>    subnet_id                       = string<br/>    private_dns_zone_ids            = optional(list(string), [])<br/>    private_service_connection_name = optional(string)<br/>    is_manual_connection            = optional(bool, false)<br/>    request_message                 = optional(string)<br/>    private_dns_zone_group_name     = optional(string, "default")<br/>    custom_network_interface_name   = optional(string)<br/>    tags                            = optional(map(string), {})<br/>  }))</pre> | `[]` | no |
| <a name="input_queue_properties"></a> [queue\_properties](#input\_queue\_properties) | Queue service properties including logging configuration. | <pre>object({<br/>    logging = optional(object({<br/>      delete                = optional(bool, true)<br/>      read                  = optional(bool, true)<br/>      write                 = optional(bool, true)<br/>      version               = optional(string, "1.0")<br/>      retention_policy_days = optional(number, 7)<br/>      }), {<br/>      delete                = true<br/>      read                  = true<br/>      write                 = true<br/>      version               = "1.0"<br/>      retention_policy_days = 7<br/>    })<br/>  })</pre> | `{}` | no |
| <a name="input_queues"></a> [queues](#input\_queues) | List of storage queues to create. | <pre>list(object({<br/>    name     = string<br/>    metadata = optional(map(string), {})<br/>  }))</pre> | `[]` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group in which to create the storage account. | `string` | n/a | yes |
| <a name="input_security_settings"></a> [security\_settings](#input\_security\_settings) | Security configuration for the storage account. | <pre>object({<br/>    https_traffic_only_enabled        = optional(bool, true)<br/>    min_tls_version                   = optional(string, "TLS1_2")<br/>    shared_access_key_enabled         = optional(bool, false)<br/>    allow_nested_items_to_be_public   = optional(bool, false)<br/>    infrastructure_encryption_enabled = optional(bool, true)<br/>    enable_advanced_threat_protection = optional(bool, true)<br/>  })</pre> | `{}` | no |
| <a name="input_static_website"></a> [static\_website](#input\_static\_website) | Static website configuration. | <pre>object({<br/>    enabled            = optional(bool, false)<br/>    index_document     = optional(string)<br/>    error_404_document = optional(string)<br/>  })</pre> | `{}` | no |
| <a name="input_tables"></a> [tables](#input\_tables) | List of storage tables to create. | <pre>list(object({<br/>    name = string<br/>  }))</pre> | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the resource. | `map(string)` | `{}` | no |

## Outputs

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_containers"></a> [containers](#output\_containers) | Map of created storage containers |
| <a name="output_file_shares"></a> [file\_shares](#output\_file\_shares) | Map of created file shares |
| <a name="output_id"></a> [id](#output\_id) | The ID of the Storage Account |
| <a name="output_identity"></a> [identity](#output\_identity) | The identity block of the storage account |
| <a name="output_lifecycle_management_policy_id"></a> [lifecycle\_management\_policy\_id](#output\_lifecycle\_management\_policy\_id) | The ID of the Storage Account Management Policy |
| <a name="output_name"></a> [name](#output\_name) | The name of the Storage Account |
| <a name="output_primary_access_key"></a> [primary\_access\_key](#output\_primary\_access\_key) | The primary access key for the storage account |
| <a name="output_primary_blob_connection_string"></a> [primary\_blob\_connection\_string](#output\_primary\_blob\_connection\_string) | The primary blob connection string for the storage account |
| <a name="output_primary_blob_endpoint"></a> [primary\_blob\_endpoint](#output\_primary\_blob\_endpoint) | The endpoint URL for blob storage in the primary location |
| <a name="output_primary_blob_host"></a> [primary\_blob\_host](#output\_primary\_blob\_host) | The hostname with port if applicable for blob storage in the primary location |
| <a name="output_primary_connection_string"></a> [primary\_connection\_string](#output\_primary\_connection\_string) | The primary connection string for the storage account |
| <a name="output_primary_dfs_endpoint"></a> [primary\_dfs\_endpoint](#output\_primary\_dfs\_endpoint) | The endpoint URL for DFS storage in the primary location |
| <a name="output_primary_file_endpoint"></a> [primary\_file\_endpoint](#output\_primary\_file\_endpoint) | The endpoint URL for file storage in the primary location |
| <a name="output_primary_location"></a> [primary\_location](#output\_primary\_location) | The primary location of the storage account |
| <a name="output_primary_queue_endpoint"></a> [primary\_queue\_endpoint](#output\_primary\_queue\_endpoint) | The endpoint URL for queue storage in the primary location |
| <a name="output_primary_table_endpoint"></a> [primary\_table\_endpoint](#output\_primary\_table\_endpoint) | The endpoint URL for table storage in the primary location |
| <a name="output_primary_web_endpoint"></a> [primary\_web\_endpoint](#output\_primary\_web\_endpoint) | The endpoint URL for web storage in the primary location |
| <a name="output_private_endpoints"></a> [private\_endpoints](#output\_private\_endpoints) | Map of private endpoints created for the storage account |
| <a name="output_queue_properties_id"></a> [queue\_properties\_id](#output\_queue\_properties\_id) | The ID of the Storage Account Queue Properties |
| <a name="output_queues"></a> [queues](#output\_queues) | Map of created storage queues |
| <a name="output_secondary_access_key"></a> [secondary\_access\_key](#output\_secondary\_access\_key) | The secondary access key for the storage account |
| <a name="output_secondary_blob_connection_string"></a> [secondary\_blob\_connection\_string](#output\_secondary\_blob\_connection\_string) | The secondary blob connection string for the storage account |
| <a name="output_secondary_blob_endpoint"></a> [secondary\_blob\_endpoint](#output\_secondary\_blob\_endpoint) | The endpoint URL for blob storage in the secondary location |
| <a name="output_secondary_blob_host"></a> [secondary\_blob\_host](#output\_secondary\_blob\_host) | The hostname with port if applicable for blob storage in the secondary location |
| <a name="output_secondary_connection_string"></a> [secondary\_connection\_string](#output\_secondary\_connection\_string) | The secondary connection string for the storage account |
| <a name="output_secondary_dfs_endpoint"></a> [secondary\_dfs\_endpoint](#output\_secondary\_dfs\_endpoint) | The endpoint URL for DFS storage in the secondary location |
| <a name="output_secondary_file_endpoint"></a> [secondary\_file\_endpoint](#output\_secondary\_file\_endpoint) | The endpoint URL for file storage in the secondary location |
| <a name="output_secondary_location"></a> [secondary\_location](#output\_secondary\_location) | The secondary location of the storage account, if configured |
| <a name="output_secondary_queue_endpoint"></a> [secondary\_queue\_endpoint](#output\_secondary\_queue\_endpoint) | The endpoint URL for queue storage in the secondary location |
| <a name="output_secondary_table_endpoint"></a> [secondary\_table\_endpoint](#output\_secondary\_table\_endpoint) | The endpoint URL for table storage in the secondary location |
| <a name="output_secondary_web_endpoint"></a> [secondary\_web\_endpoint](#output\_secondary\_web\_endpoint) | The endpoint URL for web storage in the secondary location |
| <a name="output_static_website"></a> [static\_website](#output\_static\_website) | Static website properties |
| <a name="output_tables"></a> [tables](#output\_tables) | Map of created storage tables |

## Additional Documentation

- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines

<!-- END_TF_DOCS -->