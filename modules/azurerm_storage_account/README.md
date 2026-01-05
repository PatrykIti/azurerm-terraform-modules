# Terraform Azure Storage Account Module

## Module Version

<!-- BEGIN_VERSION -->
Current version: **1.2.3**
<!-- END_VERSION -->

## Description

This module creates a comprehensive Azure Storage Account with support for all enterprise features including security, monitoring, and lifecycle management.

## Usage

```hcl
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = var.resource_group_name
  location = var.location
}

module "storage_account" {
  source = "path/to/azurerm_storage_account"

  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  # Basic example uses secure defaults (shared access keys disabled)
  # To enable shared access keys, uncomment the following:
  # security_settings = {
  #   shared_access_key_enabled = true
  # }

  # Create a container for basic storage usage
  containers = [
    {
      name                  = "logs"
      container_access_type = "private"
    }
  ]

  tags = {
    Environment = "Development"
    Project     = "Example"
  }
}
```

## Examples

<!-- BEGIN_EXAMPLES -->
- [Advanced Policies](examples/advanced-policies) - This example demonstrates the implementation of advanced storage account policies including SAS policies, immutability policies, routing preferences, custom domains, and SMB configurations.
- [Basic](examples/basic) - This example demonstrates a basic Azure Storage Account configuration using secure defaults and minimal setup.
- [Complete](examples/complete) - This example demonstrates a comprehensive deployment of an Azure Storage Account with all available features and security configurations.
- [Data Lake Gen2](examples/data-lake-gen2) - This example demonstrates how to configure an Azure Storage Account as a Data Lake Storage Gen2 with hierarchical namespace, SFTP, and NFSv3 support.
- [Identity Access](examples/identity-access) - This example demonstrates how to configure an Azure Storage Account with **keyless authentication** using managed identities and Microsoft Entra ID (formerly Azure AD) integration. This approach eliminates the need for shared access keys, providing enhanced security through identity-based access control.
- [Multi Region](examples/multi-region) - This example demonstrates a comprehensive multi-region Azure Storage Account deployment strategy with enhanced disaster recovery capabilities, cross-tenant replication, and optimized geo-redundancy configurations.
- [Secure](examples/secure) - This example demonstrates a maximum-security Azure Storage Account configuration suitable for highly sensitive data and regulated environments.
- [Secure Private Endpoint](examples/secure-private-endpoint) - This example demonstrates how to deploy a highly secure Azure Storage Account suitable for production environments handling sensitive data.
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
| [azurerm_monitor_diagnostic_setting.monitor_diagnostic_settings](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_storage_account.storage_account](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/storage_account) | resource |
| [azurerm_storage_account_queue_properties.queue_properties](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/storage_account_queue_properties) | resource |
| [azurerm_storage_account_static_website.static_website](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/storage_account_static_website) | resource |
| [azurerm_storage_container.storage_container](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/storage_container) | resource |
| [azurerm_storage_management_policy.storage_management_policy](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/storage_management_policy) | resource |
| [azurerm_storage_queue.storage_queue](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/storage_queue) | resource |
| [azurerm_storage_share.storage_share](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/storage_share) | resource |
| [azurerm_storage_table.storage_table](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/resources/storage_table) | resource |
| [azurerm_monitor_diagnostic_categories.storage](https://registry.terraform.io/providers/hashicorp/azurerm/4.57.0/docs/data-sources/monitor_diagnostic_categories) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_tier"></a> [access\_tier](#input\_access\_tier) | Defines the access tier for BlobStorage, FileStorage and StorageV2 accounts. Valid options are Hot and Cool. Premium is only valid for BlockBlobStorage and FileStorage account kinds. | `string` | `"Hot"` | no |
| <a name="input_account_kind"></a> [account\_kind](#input\_account\_kind) | Defines the Kind of account. Valid options are BlobStorage, BlockBlobStorage, FileStorage, Storage and StorageV2. | `string` | `"StorageV2"` | no |
| <a name="input_account_replication_type"></a> [account\_replication\_type](#input\_account\_replication\_type) | Defines the type of replication to use for this storage account. | `string` | `"ZRS"` | no |
| <a name="input_account_tier"></a> [account\_tier](#input\_account\_tier) | Defines the Tier to use for this storage account. Valid options are Standard and Premium. | `string` | `"Standard"` | no |
| <a name="input_allowed_copy_scope"></a> [allowed\_copy\_scope](#input\_allowed\_copy\_scope) | Restrict copy to and from Storage Accounts within an AAD tenant or with Private Links to the same VNet. Possible values are AAD and PrivateLink. | `string` | `null` | no |
| <a name="input_azure_files_authentication"></a> [azure\_files\_authentication](#input\_azure\_files\_authentication) | Azure Files authentication configuration. | <pre>object({<br/>    directory_type = string<br/>    active_directory = optional(object({<br/>      domain_name         = string<br/>      domain_guid         = string<br/>      domain_sid          = string<br/>      storage_sid         = string<br/>      forest_name         = string<br/>      netbios_domain_name = string<br/>    }))<br/>  })</pre> | `null` | no |
| <a name="input_blob_properties"></a> [blob\_properties](#input\_blob\_properties) | Blob service properties including soft delete and versioning. | <pre>object({<br/>    versioning_enabled            = optional(bool, true)<br/>    change_feed_enabled           = optional(bool, true)<br/>    change_feed_retention_in_days = optional(number)<br/>    last_access_time_enabled      = optional(bool, false)<br/>    default_service_version       = optional(string)<br/>    delete_retention_policy = optional(object({<br/>      enabled = optional(bool, true)<br/>      days    = optional(number, 7)<br/>    }), { enabled = true, days = 7 })<br/>    container_delete_retention_policy = optional(object({<br/>      enabled = optional(bool, true)<br/>      days    = optional(number, 7)<br/>    }), { enabled = true, days = 7 })<br/>    restore_policy = optional(object({<br/>      days = number<br/>    }))<br/>    cors_rules = optional(list(object({<br/>      allowed_headers    = list(string)<br/>      allowed_methods    = list(string)<br/>      allowed_origins    = list(string)<br/>      exposed_headers    = list(string)<br/>      max_age_in_seconds = number<br/>    })), [])<br/>  })</pre> | `{}` | no |
| <a name="input_containers"></a> [containers](#input\_containers) | List of storage containers to create. | <pre>list(object({<br/>    name                  = string<br/>    container_access_type = optional(string, "private")<br/>    metadata              = optional(map(string), {})<br/>  }))</pre> | `[]` | no |
| <a name="input_cross_tenant_replication_enabled"></a> [cross\_tenant\_replication\_enabled](#input\_cross\_tenant\_replication\_enabled) | Should cross Tenant replication be enabled? Defaults to false. | `bool` | `null` | no |
| <a name="input_custom_domain"></a> [custom\_domain](#input\_custom\_domain) | Custom domain configuration for the storage account. | <pre>object({<br/>    name          = string<br/>    use_subdomain = optional(bool)<br/>  })</pre> | `null` | no |
| <a name="input_default_to_oauth_authentication"></a> [default\_to\_oauth\_authentication](#input\_default\_to\_oauth\_authentication) | Default to Azure Active Directory authorization in the Azure portal when accessing the Storage Account. The default value is false. This will have no effect when the account is not in the same tenant as your Azure subscription. | `bool` | `null` | no |
| <a name="input_diagnostic_settings"></a> [diagnostic\_settings](#input\_diagnostic\_settings) | Diagnostic settings for the storage account and services (blob/queue/file/table/dfs).<br/><br/>Each entry creates a separate azurerm\_monitor\_diagnostic\_setting for the selected scope.<br/>Use areas to group categories (read/write/delete/transaction/capacity) or provide explicit<br/>log\_categories / metric\_categories. Entries with no available categories are skipped and<br/>reported in diagnostic\_settings\_skipped. | <pre>list(object({<br/>    name                           = string<br/>    scope                          = optional(string, "storage_account")<br/>    areas                          = optional(list(string))<br/>    log_categories                 = optional(list(string))<br/>    metric_categories              = optional(list(string))<br/>    log_analytics_workspace_id     = optional(string)<br/>    log_analytics_destination_type = optional(string)<br/>    storage_account_id             = optional(string)<br/>    eventhub_authorization_rule_id = optional(string)<br/>    eventhub_name                  = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_edge_zone"></a> [edge\_zone](#input\_edge\_zone) | Specifies the Edge Zone within the Azure Region where this Storage Account should exist. Defaults to null for backward compatibility. | `string` | `null` | no |
| <a name="input_encryption"></a> [encryption](#input\_encryption) | Encryption configuration for the storage account. | <pre>object({<br/>    enabled                           = optional(bool, true)<br/>    infrastructure_encryption_enabled = optional(bool, true)<br/>    key_vault_key_id                  = optional(string)<br/>    user_assigned_identity_id         = optional(string)<br/>  })</pre> | <pre>{<br/>  "enabled": true,<br/>  "infrastructure_encryption_enabled": true<br/>}</pre> | no |
| <a name="input_file_shares"></a> [file\_shares](#input\_file\_shares) | List of file shares to create. | <pre>list(object({<br/>    name             = string<br/>    quota            = optional(number, 5120)<br/>    access_tier      = optional(string, "Hot")<br/>    enabled_protocol = optional(string, "SMB")<br/>    metadata         = optional(map(string), {})<br/>  }))</pre> | `[]` | no |
| <a name="input_identity"></a> [identity](#input\_identity) | Identity configuration for the storage account. | <pre>object({<br/>    type         = string<br/>    identity_ids = optional(list(string))<br/>  })</pre> | `null` | no |
| <a name="input_immutability_policy"></a> [immutability\_policy](#input\_immutability\_policy) | Immutability policy configuration for the storage account. | <pre>object({<br/>    allow_protected_append_writes = bool<br/>    state                         = string<br/>    period_since_creation_in_days = number<br/>  })</pre> | `null` | no |
| <a name="input_is_hns_enabled"></a> [is\_hns\_enabled](#input\_is\_hns\_enabled) | Is Hierarchical Namespace enabled? This is required for Data Lake Storage Gen 2. | `bool` | `null` | no |
| <a name="input_large_file_share_enabled"></a> [large\_file\_share\_enabled](#input\_large\_file\_share\_enabled) | Is Large File Share Enabled? Defaults to null for backward compatibility. | `bool` | `null` | no |
| <a name="input_lifecycle_rules"></a> [lifecycle\_rules](#input\_lifecycle\_rules) | List of lifecycle management rules for the storage account. | <pre>list(object({<br/>    name    = string<br/>    enabled = optional(bool, true)<br/>    filters = object({<br/>      blob_types   = list(string)<br/>      prefix_match = optional(list(string), [])<br/>    })<br/>    actions = object({<br/>      base_blob = optional(object({<br/>        tier_to_cool_after_days_since_modification_greater_than        = optional(number)<br/>        tier_to_archive_after_days_since_modification_greater_than     = optional(number)<br/>        delete_after_days_since_modification_greater_than              = optional(number)<br/>        tier_to_cool_after_days_since_last_access_time_greater_than    = optional(number)<br/>        tier_to_archive_after_days_since_last_access_time_greater_than = optional(number)<br/>        delete_after_days_since_last_access_time_greater_than          = optional(number)<br/>      }))<br/>      snapshot = optional(object({<br/>        change_tier_to_archive_after_days_since_creation = optional(number)<br/>        change_tier_to_cool_after_days_since_creation    = optional(number)<br/>        delete_after_days_since_creation_greater_than    = optional(number)<br/>      }))<br/>      version = optional(object({<br/>        change_tier_to_archive_after_days_since_creation = optional(number)<br/>        change_tier_to_cool_after_days_since_creation    = optional(number)<br/>        delete_after_days_since_creation                 = optional(number)<br/>      }))<br/>    })<br/>  }))</pre> | `[]` | no |
| <a name="input_local_user_enabled"></a> [local\_user\_enabled](#input\_local\_user\_enabled) | Is local user feature enabled for this storage account? | `bool` | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | The Azure Region where the Storage Account should exist. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the storage account. Must be globally unique. | `string` | n/a | yes |
| <a name="input_network_rules"></a> [network\_rules](#input\_network\_rules) | Network access control rules for the storage account.<br/><br/>When ip\_rules or virtual\_network\_subnet\_ids are specified, only those sources will have access (default\_action will be "Deny").<br/>When both are empty/null, all public access will be allowed (default\_action will be "Allow").<br/>If default\_action is set to "Allow" or "Deny", it overrides the automatic behavior.<br/><br/>To allow all public access, set this variable to null, set default\_action to "Allow", or leave ip\_rules and virtual\_network\_subnet\_ids empty.<br/><br/>bypass: Azure services that should bypass network rules (default: ["AzureServices"])<br/>ip\_rules: Set of public IP addresses or CIDR blocks that should have access<br/>virtual\_network\_subnet\_ids: Set of subnet IDs that should have access via service endpoints<br/>private\_link\_access: Private endpoints that should have access | <pre>object({<br/>    default_action             = optional(string)<br/>    bypass                     = optional(set(string), ["AzureServices"])<br/>    ip_rules                   = optional(set(string), [])<br/>    virtual_network_subnet_ids = optional(set(string), [])<br/>    private_link_access = optional(list(object({<br/>      endpoint_resource_id = string<br/>      endpoint_tenant_id   = optional(string)<br/>    })), [])<br/>  })</pre> | <pre>{<br/>  "bypass": [<br/>    "AzureServices"<br/>  ]<br/>}</pre> | no |
| <a name="input_nfsv3_enabled"></a> [nfsv3\_enabled](#input\_nfsv3\_enabled) | Is NFSv3 protocol enabled for this storage account? | `bool` | `null` | no |
| <a name="input_queue_encryption_key_type"></a> [queue\_encryption\_key\_type](#input\_queue\_encryption\_key\_type) | The encryption key type to use for the Queue service. Possible values are Service and Account. | `string` | `null` | no |
| <a name="input_queue_properties"></a> [queue\_properties](#input\_queue\_properties) | Queue service properties including logging configuration. | <pre>object({<br/>    logging = optional(object({<br/>      delete                = optional(bool, true)<br/>      read                  = optional(bool, true)<br/>      write                 = optional(bool, true)<br/>      version               = optional(string, "1.0")<br/>      retention_policy_days = optional(number, 7)<br/>      }), {<br/>      delete                = true<br/>      read                  = true<br/>      write                 = true<br/>      version               = "1.0"<br/>      retention_policy_days = 7<br/>    })<br/>  })</pre> | `{}` | no |
| <a name="input_queues"></a> [queues](#input\_queues) | List of storage queues to create. | <pre>list(object({<br/>    name     = string<br/>    metadata = optional(map(string), {})<br/>  }))</pre> | `[]` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group in which to create the storage account. | `string` | n/a | yes |
| <a name="input_routing"></a> [routing](#input\_routing) | Routing configuration for the storage account. | <pre>object({<br/>    choice                      = optional(string)<br/>    publish_internet_endpoints  = optional(bool)<br/>    publish_microsoft_endpoints = optional(bool)<br/>  })</pre> | `null` | no |
| <a name="input_sas_policy"></a> [sas\_policy](#input\_sas\_policy) | SAS policy configuration for the storage account. | <pre>object({<br/>    expiration_period = string<br/>    expiration_action = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_security_settings"></a> [security\_settings](#input\_security\_settings) | Security configuration for the storage account. | <pre>object({<br/>    https_traffic_only_enabled        = optional(bool, true)<br/>    min_tls_version                   = optional(string, "TLS1_2")<br/>    shared_access_key_enabled         = optional(bool, false)<br/>    allow_nested_items_to_be_public   = optional(bool, false)<br/>    infrastructure_encryption_enabled = optional(bool, true)<br/>    enable_advanced_threat_protection = optional(bool, true)<br/>    public_network_access_enabled     = optional(bool, true)<br/>  })</pre> | `{}` | no |
| <a name="input_sftp_enabled"></a> [sftp\_enabled](#input\_sftp\_enabled) | Is SFTP enabled for this storage account? | `bool` | `null` | no |
| <a name="input_share_properties"></a> [share\_properties](#input\_share\_properties) | Share service properties including SMB, retention policy, and CORS rules. | <pre>object({<br/>    cors_rule = optional(list(object({<br/>      allowed_headers    = list(string)<br/>      allowed_methods    = list(string)<br/>      allowed_origins    = list(string)<br/>      exposed_headers    = list(string)<br/>      max_age_in_seconds = number<br/>    })), [])<br/>    retention_policy = optional(object({<br/>      days = optional(number, 7)<br/>    }))<br/>    smb = optional(object({<br/>      versions                        = optional(list(string), ["SMB3.0", "SMB3.1.1"])<br/>      authentication_types            = optional(list(string), ["NTLMv2", "Kerberos"])<br/>      kerberos_ticket_encryption_type = optional(list(string), ["RC4-HMAC", "AES-256"])<br/>      channel_encryption_type         = optional(list(string), ["AES-128-CCM", "AES-128-GCM", "AES-256-GCM"])<br/>      multichannel_enabled            = optional(bool, false)<br/>    }))<br/>  })</pre> | `null` | no |
| <a name="input_static_website"></a> [static\_website](#input\_static\_website) | Static website configuration. | <pre>object({<br/>    enabled            = optional(bool, false)<br/>    index_document     = optional(string)<br/>    error_404_document = optional(string)<br/>  })</pre> | `{}` | no |
| <a name="input_table_encryption_key_type"></a> [table\_encryption\_key\_type](#input\_table\_encryption\_key\_type) | The encryption key type to use for the Table service. Possible values are Service and Account. | `string` | `null` | no |
| <a name="input_tables"></a> [tables](#input\_tables) | List of storage tables to create. | <pre>list(object({<br/>    name = string<br/>  }))</pre> | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the resource. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_access_tier"></a> [access\_tier](#output\_access\_tier) | The access tier of the storage account |
| <a name="output_account_kind"></a> [account\_kind](#output\_account\_kind) | The Kind of the storage account |
| <a name="output_account_replication_type"></a> [account\_replication\_type](#output\_account\_replication\_type) | The replication type of the storage account |
| <a name="output_account_tier"></a> [account\_tier](#output\_account\_tier) | The Tier of the storage account |
| <a name="output_allow_nested_items_to_be_public"></a> [allow\_nested\_items\_to\_be\_public](#output\_allow\_nested\_items\_to\_be\_public) | Are nested items allowed to be public for the storage account |
| <a name="output_containers"></a> [containers](#output\_containers) | Map of created storage containers with all available attributes |
| <a name="output_cross_tenant_replication_enabled"></a> [cross\_tenant\_replication\_enabled](#output\_cross\_tenant\_replication\_enabled) | Is cross tenant replication enabled for the storage account |
| <a name="output_diagnostic_settings_skipped"></a> [diagnostic\_settings\_skipped](#output\_diagnostic\_settings\_skipped) | Diagnostic settings entries skipped because no categories were available after filtering. |
| <a name="output_file_shares"></a> [file\_shares](#output\_file\_shares) | Map of created file shares |
| <a name="output_https_traffic_only_enabled"></a> [https\_traffic\_only\_enabled](#output\_https\_traffic\_only\_enabled) | Is HTTPS traffic only enabled for the storage account |
| <a name="output_id"></a> [id](#output\_id) | The ID of the Storage Account |
| <a name="output_identity"></a> [identity](#output\_identity) | The identity block of the storage account |
| <a name="output_infrastructure_encryption_enabled"></a> [infrastructure\_encryption\_enabled](#output\_infrastructure\_encryption\_enabled) | Is infrastructure encryption enabled for the storage account |
| <a name="output_is_hns_enabled"></a> [is\_hns\_enabled](#output\_is\_hns\_enabled) | Is Hierarchical Namespace enabled for the storage account |
| <a name="output_large_file_share_enabled"></a> [large\_file\_share\_enabled](#output\_large\_file\_share\_enabled) | Are Large File Shares enabled for the storage account |
| <a name="output_lifecycle_management_policy_id"></a> [lifecycle\_management\_policy\_id](#output\_lifecycle\_management\_policy\_id) | The ID of the Storage Account Management Policy |
| <a name="output_location"></a> [location](#output\_location) | The Azure location where the storage account exists |
| <a name="output_min_tls_version"></a> [min\_tls\_version](#output\_min\_tls\_version) | The minimum TLS version of the storage account |
| <a name="output_name"></a> [name](#output\_name) | The name of the Storage Account |
| <a name="output_nfsv3_enabled"></a> [nfsv3\_enabled](#output\_nfsv3\_enabled) | Is NFSv3 protocol enabled for the storage account |
| <a name="output_primary_access_key"></a> [primary\_access\_key](#output\_primary\_access\_key) | The primary access key for the storage account |
| <a name="output_primary_blob_connection_string"></a> [primary\_blob\_connection\_string](#output\_primary\_blob\_connection\_string) | The primary blob connection string for the storage account |
| <a name="output_primary_blob_endpoint"></a> [primary\_blob\_endpoint](#output\_primary\_blob\_endpoint) | The endpoint URL for blob storage in the primary location |
| <a name="output_primary_blob_host"></a> [primary\_blob\_host](#output\_primary\_blob\_host) | The hostname with port if applicable for blob storage in the primary location |
| <a name="output_primary_blob_internet_endpoint"></a> [primary\_blob\_internet\_endpoint](#output\_primary\_blob\_internet\_endpoint) | The internet routing endpoint URL for blob storage in the primary location |
| <a name="output_primary_blob_internet_host"></a> [primary\_blob\_internet\_host](#output\_primary\_blob\_internet\_host) | The internet routing hostname with port if applicable for blob storage in the primary location |
| <a name="output_primary_blob_microsoft_endpoint"></a> [primary\_blob\_microsoft\_endpoint](#output\_primary\_blob\_microsoft\_endpoint) | The microsoft routing endpoint URL for blob storage in the primary location |
| <a name="output_primary_blob_microsoft_host"></a> [primary\_blob\_microsoft\_host](#output\_primary\_blob\_microsoft\_host) | The microsoft routing hostname with port if applicable for blob storage in the primary location |
| <a name="output_primary_connection_string"></a> [primary\_connection\_string](#output\_primary\_connection\_string) | The primary connection string for the storage account |
| <a name="output_primary_dfs_endpoint"></a> [primary\_dfs\_endpoint](#output\_primary\_dfs\_endpoint) | The endpoint URL for DFS storage in the primary location |
| <a name="output_primary_dfs_host"></a> [primary\_dfs\_host](#output\_primary\_dfs\_host) | The hostname with port if applicable for DFS storage in the primary location |
| <a name="output_primary_dfs_internet_endpoint"></a> [primary\_dfs\_internet\_endpoint](#output\_primary\_dfs\_internet\_endpoint) | The internet routing endpoint URL for DFS storage in the primary location |
| <a name="output_primary_dfs_internet_host"></a> [primary\_dfs\_internet\_host](#output\_primary\_dfs\_internet\_host) | The internet routing hostname with port if applicable for DFS storage in the primary location |
| <a name="output_primary_dfs_microsoft_endpoint"></a> [primary\_dfs\_microsoft\_endpoint](#output\_primary\_dfs\_microsoft\_endpoint) | The microsoft routing endpoint URL for DFS storage in the primary location |
| <a name="output_primary_dfs_microsoft_host"></a> [primary\_dfs\_microsoft\_host](#output\_primary\_dfs\_microsoft\_host) | The microsoft routing hostname with port if applicable for DFS storage in the primary location |
| <a name="output_primary_file_endpoint"></a> [primary\_file\_endpoint](#output\_primary\_file\_endpoint) | The endpoint URL for file storage in the primary location |
| <a name="output_primary_file_host"></a> [primary\_file\_host](#output\_primary\_file\_host) | The hostname with port if applicable for file storage in the primary location |
| <a name="output_primary_file_internet_endpoint"></a> [primary\_file\_internet\_endpoint](#output\_primary\_file\_internet\_endpoint) | The internet routing endpoint URL for file storage in the primary location |
| <a name="output_primary_file_internet_host"></a> [primary\_file\_internet\_host](#output\_primary\_file\_internet\_host) | The internet routing hostname with port if applicable for file storage in the primary location |
| <a name="output_primary_file_microsoft_endpoint"></a> [primary\_file\_microsoft\_endpoint](#output\_primary\_file\_microsoft\_endpoint) | The microsoft routing endpoint URL for file storage in the primary location |
| <a name="output_primary_file_microsoft_host"></a> [primary\_file\_microsoft\_host](#output\_primary\_file\_microsoft\_host) | The microsoft routing hostname with port if applicable for file storage in the primary location |
| <a name="output_primary_location"></a> [primary\_location](#output\_primary\_location) | The primary location of the storage account |
| <a name="output_primary_queue_endpoint"></a> [primary\_queue\_endpoint](#output\_primary\_queue\_endpoint) | The endpoint URL for queue storage in the primary location |
| <a name="output_primary_queue_host"></a> [primary\_queue\_host](#output\_primary\_queue\_host) | The hostname with port if applicable for queue storage in the primary location |
| <a name="output_primary_table_endpoint"></a> [primary\_table\_endpoint](#output\_primary\_table\_endpoint) | The endpoint URL for table storage in the primary location |
| <a name="output_primary_table_host"></a> [primary\_table\_host](#output\_primary\_table\_host) | The hostname with port if applicable for table storage in the primary location |
| <a name="output_primary_web_endpoint"></a> [primary\_web\_endpoint](#output\_primary\_web\_endpoint) | The endpoint URL for web storage in the primary location |
| <a name="output_primary_web_host"></a> [primary\_web\_host](#output\_primary\_web\_host) | The hostname with port if applicable for web storage in the primary location |
| <a name="output_primary_web_internet_endpoint"></a> [primary\_web\_internet\_endpoint](#output\_primary\_web\_internet\_endpoint) | The internet routing endpoint URL for web storage in the primary location |
| <a name="output_primary_web_internet_host"></a> [primary\_web\_internet\_host](#output\_primary\_web\_internet\_host) | The internet routing hostname with port if applicable for web storage in the primary location |
| <a name="output_primary_web_microsoft_endpoint"></a> [primary\_web\_microsoft\_endpoint](#output\_primary\_web\_microsoft\_endpoint) | The microsoft routing endpoint URL for web storage in the primary location |
| <a name="output_primary_web_microsoft_host"></a> [primary\_web\_microsoft\_host](#output\_primary\_web\_microsoft\_host) | The microsoft routing hostname with port if applicable for web storage in the primary location |
| <a name="output_queue_encryption_key_type"></a> [queue\_encryption\_key\_type](#output\_queue\_encryption\_key\_type) | The encryption type of the queue service |
| <a name="output_queue_properties_id"></a> [queue\_properties\_id](#output\_queue\_properties\_id) | The ID of the Storage Account Queue Properties |
| <a name="output_queues"></a> [queues](#output\_queues) | Map of created storage queues |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The name of the resource group in which the storage account is created |
| <a name="output_secondary_access_key"></a> [secondary\_access\_key](#output\_secondary\_access\_key) | The secondary access key for the storage account |
| <a name="output_secondary_blob_connection_string"></a> [secondary\_blob\_connection\_string](#output\_secondary\_blob\_connection\_string) | The secondary blob connection string for the storage account |
| <a name="output_secondary_blob_endpoint"></a> [secondary\_blob\_endpoint](#output\_secondary\_blob\_endpoint) | The endpoint URL for blob storage in the secondary location |
| <a name="output_secondary_blob_host"></a> [secondary\_blob\_host](#output\_secondary\_blob\_host) | The hostname with port if applicable for blob storage in the secondary location |
| <a name="output_secondary_blob_internet_endpoint"></a> [secondary\_blob\_internet\_endpoint](#output\_secondary\_blob\_internet\_endpoint) | The internet routing endpoint URL for blob storage in the secondary location |
| <a name="output_secondary_blob_internet_host"></a> [secondary\_blob\_internet\_host](#output\_secondary\_blob\_internet\_host) | The internet routing hostname with port if applicable for blob storage in the secondary location |
| <a name="output_secondary_blob_microsoft_endpoint"></a> [secondary\_blob\_microsoft\_endpoint](#output\_secondary\_blob\_microsoft\_endpoint) | The microsoft routing endpoint URL for blob storage in the secondary location |
| <a name="output_secondary_blob_microsoft_host"></a> [secondary\_blob\_microsoft\_host](#output\_secondary\_blob\_microsoft\_host) | The microsoft routing hostname with port if applicable for blob storage in the secondary location |
| <a name="output_secondary_connection_string"></a> [secondary\_connection\_string](#output\_secondary\_connection\_string) | The secondary connection string for the storage account |
| <a name="output_secondary_dfs_endpoint"></a> [secondary\_dfs\_endpoint](#output\_secondary\_dfs\_endpoint) | The endpoint URL for DFS storage in the secondary location |
| <a name="output_secondary_dfs_host"></a> [secondary\_dfs\_host](#output\_secondary\_dfs\_host) | The hostname with port if applicable for DFS storage in the secondary location |
| <a name="output_secondary_dfs_internet_endpoint"></a> [secondary\_dfs\_internet\_endpoint](#output\_secondary\_dfs\_internet\_endpoint) | The internet routing endpoint URL for DFS storage in the secondary location |
| <a name="output_secondary_dfs_internet_host"></a> [secondary\_dfs\_internet\_host](#output\_secondary\_dfs\_internet\_host) | The internet routing hostname with port if applicable for DFS storage in the secondary location |
| <a name="output_secondary_dfs_microsoft_endpoint"></a> [secondary\_dfs\_microsoft\_endpoint](#output\_secondary\_dfs\_microsoft\_endpoint) | The microsoft routing endpoint URL for DFS storage in the secondary location |
| <a name="output_secondary_dfs_microsoft_host"></a> [secondary\_dfs\_microsoft\_host](#output\_secondary\_dfs\_microsoft\_host) | The microsoft routing hostname with port if applicable for DFS storage in the secondary location |
| <a name="output_secondary_file_endpoint"></a> [secondary\_file\_endpoint](#output\_secondary\_file\_endpoint) | The endpoint URL for file storage in the secondary location |
| <a name="output_secondary_file_host"></a> [secondary\_file\_host](#output\_secondary\_file\_host) | The hostname with port if applicable for file storage in the secondary location |
| <a name="output_secondary_file_internet_endpoint"></a> [secondary\_file\_internet\_endpoint](#output\_secondary\_file\_internet\_endpoint) | The internet routing endpoint URL for file storage in the secondary location |
| <a name="output_secondary_file_internet_host"></a> [secondary\_file\_internet\_host](#output\_secondary\_file\_internet\_host) | The internet routing hostname with port if applicable for file storage in the secondary location |
| <a name="output_secondary_file_microsoft_endpoint"></a> [secondary\_file\_microsoft\_endpoint](#output\_secondary\_file\_microsoft\_endpoint) | The microsoft routing endpoint URL for file storage in the secondary location |
| <a name="output_secondary_file_microsoft_host"></a> [secondary\_file\_microsoft\_host](#output\_secondary\_file\_microsoft\_host) | The microsoft routing hostname with port if applicable for file storage in the secondary location |
| <a name="output_secondary_location"></a> [secondary\_location](#output\_secondary\_location) | The secondary location of the storage account, if configured |
| <a name="output_secondary_queue_endpoint"></a> [secondary\_queue\_endpoint](#output\_secondary\_queue\_endpoint) | The endpoint URL for queue storage in the secondary location |
| <a name="output_secondary_queue_host"></a> [secondary\_queue\_host](#output\_secondary\_queue\_host) | The hostname with port if applicable for queue storage in the secondary location |
| <a name="output_secondary_table_endpoint"></a> [secondary\_table\_endpoint](#output\_secondary\_table\_endpoint) | The endpoint URL for table storage in the secondary location |
| <a name="output_secondary_table_host"></a> [secondary\_table\_host](#output\_secondary\_table\_host) | The hostname with port if applicable for table storage in the secondary location |
| <a name="output_secondary_web_endpoint"></a> [secondary\_web\_endpoint](#output\_secondary\_web\_endpoint) | The endpoint URL for web storage in the secondary location |
| <a name="output_secondary_web_host"></a> [secondary\_web\_host](#output\_secondary\_web\_host) | The hostname with port if applicable for web storage in the secondary location |
| <a name="output_secondary_web_internet_endpoint"></a> [secondary\_web\_internet\_endpoint](#output\_secondary\_web\_internet\_endpoint) | The internet routing endpoint URL for web storage in the secondary location |
| <a name="output_secondary_web_internet_host"></a> [secondary\_web\_internet\_host](#output\_secondary\_web\_internet\_host) | The internet routing hostname with port if applicable for web storage in the secondary location |
| <a name="output_secondary_web_microsoft_endpoint"></a> [secondary\_web\_microsoft\_endpoint](#output\_secondary\_web\_microsoft\_endpoint) | The microsoft routing endpoint URL for web storage in the secondary location |
| <a name="output_secondary_web_microsoft_host"></a> [secondary\_web\_microsoft\_host](#output\_secondary\_web\_microsoft\_host) | The microsoft routing hostname with port if applicable for web storage in the secondary location |
| <a name="output_sftp_enabled"></a> [sftp\_enabled](#output\_sftp\_enabled) | Is SFTP enabled for the storage account |
| <a name="output_shared_access_key_enabled"></a> [shared\_access\_key\_enabled](#output\_shared\_access\_key\_enabled) | Are shared access keys enabled for the storage account |
| <a name="output_static_website"></a> [static\_website](#output\_static\_website) | Static website properties |
| <a name="output_static_website_id"></a> [static\_website\_id](#output\_static\_website\_id) | The ID of the Storage Account Static Website configuration |
| <a name="output_table_encryption_key_type"></a> [table\_encryption\_key\_type](#output\_table\_encryption\_key\_type) | The encryption type of the table service |
| <a name="output_tables"></a> [tables](#output\_tables) | Map of created storage tables |
| <a name="output_tags"></a> [tags](#output\_tags) | A map of tags assigned to the storage account |
<!-- END_TF_DOCS -->

## Additional Documentation

- [VERSIONING.md](VERSIONING.md) - Module versioning and release process
- [SECURITY.md](SECURITY.md) - Security features and configuration guidelines
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
