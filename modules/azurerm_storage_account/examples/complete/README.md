# Complete Storage Account Example

This example demonstrates a comprehensive deployment of an Azure Storage Account with all available features and security configurations.

## Overview

This example creates:
- A highly secure Storage Account with all enterprise features enabled
- Virtual Network with subnets for private endpoints
- Private endpoints for all storage services (blob, file, queue, table)
- Customer Managed Key (CMK) encryption using Azure Key Vault
- Diagnostic settings with Log Analytics integration
- Static website hosting
- Lifecycle management policies
- All storage services with example resources (containers, queues, tables, file shares)

## Features Demonstrated

### Core Configuration
- **Account Kind**: StorageV2 (most feature-rich option)
- **Replication**: ZRS (Zone-Redundant Storage)
- **Access Tier**: Hot (optimized for frequent access)

### Security Features
- **HTTPS Only**: Enforces encrypted connections
- **TLS Version**: Minimum TLS 1.2
- **Infrastructure Encryption**: Double encryption at rest
- **Advanced Threat Protection**: Enabled for security monitoring
- **OAuth Authentication**: Default authentication method in Azure portal
- **Cross-Tenant Replication**: Disabled for security
- **Copy Scope**: Restricted to Private Link connections only

### Encryption Configuration
- **Customer Managed Keys**: Using Azure Key Vault
- **Queue Encryption**: Account-scoped encryption keys
- **Table Encryption**: Account-scoped encryption keys
- **Infrastructure Encryption**: Enabled for additional security layer

### Network Security
- **Private Endpoints**: For all storage services (blob, file, queue, table)
- **Network Rules**: Configured with secure defaults
- **Service Endpoints**: Configured on VNet subnets

### Data Protection
- **Blob Versioning**: Enabled for version history
- **Change Feed**: Enabled for tracking changes
- **Soft Delete**: 30-day retention for blobs and containers
- **Lifecycle Management**: Automated data lifecycle policies

### Compliance and Governance
- **Immutability Policy**: Configured for WORM (Write Once Read Many) compliance
- **SAS Policy**: 90-day expiration with logging
- **Diagnostic Settings**: Full audit logging to Log Analytics

### Advanced Features
- **Static Website**: Hosting enabled with custom error pages
- **Large File Shares**: Support for shares >5TB
- **Share Properties**: SMB multichannel and advanced security settings
- **Routing**: Microsoft routing with internet endpoints published

### Protocol Support
- **Hierarchical Namespace**: Configurable for Data Lake Gen2
- **SFTP**: Configurable for secure file transfer
- **NFSv3**: Configurable for Linux workloads
- **Local Users**: Configurable for non-AD authentication

## Parameter Documentation

### Basic Parameters
- `name`: Globally unique storage account name
- `resource_group_name`: Resource group for deployment
- `location`: Azure region
- `account_kind`: Type of storage account (StorageV2 recommended)
- `account_tier`: Performance tier (Standard/Premium)
- `account_replication_type`: Redundancy option (LRS/ZRS/GRS/RAGRS/GZRS/RAGZRS)
- `access_tier`: Default access tier for blobs (Hot/Cool/Premium)

### Security Settings
- `security_settings`: Object containing:
  - `https_traffic_only_enabled`: Enforce HTTPS (default: true)
  - `min_tls_version`: Minimum TLS version (default: TLS1_2)
  - `shared_access_key_enabled`: Enable/disable shared key access
  - `allow_nested_items_to_be_public`: Control public access to blobs
  - `infrastructure_encryption_enabled`: Enable double encryption
  - `enable_advanced_threat_protection`: Enable ATP monitoring

### New Security Parameters (Task #18)
- `default_to_oauth_authentication`: Use OAuth in Azure portal by default
- `cross_tenant_replication_enabled`: Allow/deny cross-tenant replication
- `queue_encryption_key_type`: Encryption scope for queues (Service/Account)
- `table_encryption_key_type`: Encryption scope for tables (Service/Account)
- `allowed_copy_scope`: Restrict copy operations (AAD/PrivateLink)

### Data Lake and Protocol Support (Task #18)
- `is_hns_enabled`: Enable Hierarchical Namespace for Data Lake Gen2
- `sftp_enabled`: Enable SFTP protocol (requires HNS)
- `nfsv3_enabled`: Enable NFSv3 protocol for Linux workloads
- `local_user_enabled`: Enable local user authentication

### Infrastructure Parameters (Task #18)
- `large_file_share_enabled`: Support for file shares larger than 5TB
- `edge_zone`: Deploy to Azure Edge Zone (optional)

### Compliance Features (Task #18)
- `immutability_policy`: WORM compliance configuration
  - `allow_protected_append_writes`: Allow append operations
  - `state`: Policy state (Locked/Unlocked)
  - `period_since_creation_in_days`: Retention period
- `sas_policy`: SAS token governance
  - `expiration_period`: Maximum SAS token lifetime
  - `expiration_action`: Action on expiration (Log/Block)

### Advanced Networking (Task #18)
- `routing`: Traffic routing configuration
  - `choice`: Routing preference (MicrosoftRouting/InternetRouting)
  - `publish_internet_endpoints`: Publish internet routing endpoints
  - `publish_microsoft_endpoints`: Publish Microsoft routing endpoints
- `custom_domain`: Custom domain configuration
  - `name`: Custom domain name
  - `use_subdomain`: Enable indirect CNAME validation

### File Share Properties (Task #18)
- `share_properties`: Advanced file share configuration
  - `retention_policy`: Soft delete retention
  - `smb`: SMB protocol settings
    - `versions`: Supported SMB versions
    - `authentication_types`: Authentication methods
    - `kerberos_ticket_encryption_type`: Kerberos encryption
    - `channel_encryption_type`: Channel encryption
    - `multichannel_enabled`: Enable SMB multichannel
  - `cors_rule`: CORS configuration for file shares

## Outputs

This example exposes ALL available outputs from the storage account module, including:

### Endpoint Outputs
- All primary and secondary endpoints for each service
- Internet routing endpoints
- Microsoft routing endpoints
- Separate endpoints for blob, file, queue, table, DFS, and web services

### Configuration Outputs
- Account configuration details
- Security settings status
- Feature enablement status
- Encryption configuration

### Resource Outputs
- Created containers, queues, tables, and file shares
- Private endpoint details
- Identity configuration
- Diagnostic settings

### Infrastructure Outputs
- Key Vault ID for CMK
- Log Analytics Workspace ID
- Virtual Network and Subnet IDs

## Prerequisites

- Azure subscription with appropriate permissions
- Terraform >= 1.3.0
- AzureRM Provider 4.35.0 (as specified in the module's [versions.tf](../../versions.tf))

**Note**: The module uses a pinned version of the AzureRM provider (4.35.0) to ensure consistent behavior across all deployments.

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## Security Considerations

1. **Initial Setup**: Network rules are set to "Allow" for initial configuration. After deployment, update to "Deny" with specific allowed IPs/subnets.
2. **Access Keys**: Although `shared_access_key_enabled` is true (required for Terraform), use Azure AD authentication where possible.
3. **Private Endpoints**: Ensure DNS resolution is properly configured for private endpoint connectivity.
4. **CMK Rotation**: Implement key rotation policies in Key Vault for enhanced security.

## Cost Optimization

1. **Lifecycle Policies**: Automatically move or delete old data to reduce costs
2. **Access Tiers**: Use Cool tier for infrequently accessed data
3. **Replication**: Choose appropriate replication based on availability requirements
4. **Monitoring**: Use diagnostic settings to track and optimize usage

## Next Steps

1. Configure network rules to restrict access
2. Set up Azure AD authentication for applications
3. Implement backup and disaster recovery procedures
4. Configure advanced threat protection alerts
5. Review and adjust lifecycle management policies
<!-- BEGIN_TF_DOCS -->


## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.0.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.35.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.7.2 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_storage_account"></a> [storage\_account](#module\_storage\_account) | github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_storage_account?ref=SAv1.0.0 | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_key_vault.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault) | resource |
| [azurerm_key_vault_key.storage](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_key) | resource |
| [azurerm_log_analytics_workspace.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) | resource |
| [azurerm_private_dns_zone.blob](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) | resource |
| [azurerm_private_dns_zone.file](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) | resource |
| [azurerm_private_dns_zone.queue](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) | resource |
| [azurerm_private_dns_zone.table](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) | resource |
| [azurerm_private_dns_zone_virtual_network_link.blob](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) | resource |
| [azurerm_private_dns_zone_virtual_network_link.file](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) | resource |
| [azurerm_resource_group.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_subnet.private_endpoints](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet.services](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_user_assigned_identity.storage](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [azurerm_virtual_network.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [random_string.suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_enable_private_endpoints"></a> [enable\_private\_endpoints](#input\_enable\_private\_endpoints) | Whether to enable private endpoints for storage services | `bool` | `true` | no |
| <a name="input_location"></a> [location](#input\_location) | The Azure region where resources will be created | `string` | `"West Europe"` | no |
| <a name="input_log_analytics_retention_days"></a> [log\_analytics\_retention\_days](#input\_log\_analytics\_retention\_days) | Number of days to retain logs in Log Analytics | `number` | `30` | no |
| <a name="input_network_ranges"></a> [network\_ranges](#input\_network\_ranges) | IP ranges to allow network access | `list(string)` | `[]` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix for resource names | `string` | `"example"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_access_tier"></a> [access\_tier](#output\_access\_tier) | The access tier of the storage account |
| <a name="output_account_kind"></a> [account\_kind](#output\_account\_kind) | The kind of the storage account |
| <a name="output_account_replication_type"></a> [account\_replication\_type](#output\_account\_replication\_type) | The replication type of the storage account |
| <a name="output_account_tier"></a> [account\_tier](#output\_account\_tier) | The tier of the storage account |
| <a name="output_allow_nested_items_to_be_public"></a> [allow\_nested\_items\_to\_be\_public](#output\_allow\_nested\_items\_to\_be\_public) | Are nested items allowed to be public |
| <a name="output_containers"></a> [containers](#output\_containers) | Map of created storage containers |
| <a name="output_cross_tenant_replication_enabled"></a> [cross\_tenant\_replication\_enabled](#output\_cross\_tenant\_replication\_enabled) | Is cross tenant replication enabled |
| <a name="output_diagnostic_settings"></a> [diagnostic\_settings](#output\_diagnostic\_settings) | Map of diagnostic settings created |
| <a name="output_file_shares"></a> [file\_shares](#output\_file\_shares) | Map of created file shares |
| <a name="output_https_traffic_only_enabled"></a> [https\_traffic\_only\_enabled](#output\_https\_traffic\_only\_enabled) | Is HTTPS traffic only enabled |
| <a name="output_identity"></a> [identity](#output\_identity) | The identity configuration of the storage account |
| <a name="output_infrastructure_encryption_enabled"></a> [infrastructure\_encryption\_enabled](#output\_infrastructure\_encryption\_enabled) | Is infrastructure encryption enabled |
| <a name="output_is_hns_enabled"></a> [is\_hns\_enabled](#output\_is\_hns\_enabled) | Is Hierarchical Namespace enabled (Data Lake Gen2) |
| <a name="output_key_vault_id"></a> [key\_vault\_id](#output\_key\_vault\_id) | The ID of the Key Vault used for CMK |
| <a name="output_large_file_share_enabled"></a> [large\_file\_share\_enabled](#output\_large\_file\_share\_enabled) | Are large file shares enabled |
| <a name="output_lifecycle_management_policy_id"></a> [lifecycle\_management\_policy\_id](#output\_lifecycle\_management\_policy\_id) | The ID of the Storage Account Management Policy |
| <a name="output_location"></a> [location](#output\_location) | The Azure location of the storage account |
| <a name="output_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#output\_log\_analytics\_workspace\_id) | The ID of the Log Analytics workspace |
| <a name="output_min_tls_version"></a> [min\_tls\_version](#output\_min\_tls\_version) | The minimum TLS version |
| <a name="output_nfsv3_enabled"></a> [nfsv3\_enabled](#output\_nfsv3\_enabled) | Is NFSv3 protocol enabled |
| <a name="output_primary_access_key"></a> [primary\_access\_key](#output\_primary\_access\_key) | The primary access key |
| <a name="output_primary_blob_connection_string"></a> [primary\_blob\_connection\_string](#output\_primary\_blob\_connection\_string) | The primary blob connection string |
| <a name="output_primary_blob_endpoint"></a> [primary\_blob\_endpoint](#output\_primary\_blob\_endpoint) | The primary blob endpoint |
| <a name="output_primary_blob_host"></a> [primary\_blob\_host](#output\_primary\_blob\_host) | The primary blob host |
| <a name="output_primary_blob_internet_endpoint"></a> [primary\_blob\_internet\_endpoint](#output\_primary\_blob\_internet\_endpoint) | The internet routing endpoint URL for blob storage in the primary location |
| <a name="output_primary_blob_internet_host"></a> [primary\_blob\_internet\_host](#output\_primary\_blob\_internet\_host) | The internet routing hostname for blob storage in the primary location |
| <a name="output_primary_blob_microsoft_endpoint"></a> [primary\_blob\_microsoft\_endpoint](#output\_primary\_blob\_microsoft\_endpoint) | The microsoft routing endpoint URL for blob storage in the primary location |
| <a name="output_primary_blob_microsoft_host"></a> [primary\_blob\_microsoft\_host](#output\_primary\_blob\_microsoft\_host) | The microsoft routing hostname for blob storage in the primary location |
| <a name="output_primary_connection_string"></a> [primary\_connection\_string](#output\_primary\_connection\_string) | The primary connection string |
| <a name="output_primary_dfs_endpoint"></a> [primary\_dfs\_endpoint](#output\_primary\_dfs\_endpoint) | The endpoint URL for DFS storage in the primary location |
| <a name="output_primary_dfs_host"></a> [primary\_dfs\_host](#output\_primary\_dfs\_host) | The hostname for DFS storage in the primary location |
| <a name="output_primary_dfs_internet_endpoint"></a> [primary\_dfs\_internet\_endpoint](#output\_primary\_dfs\_internet\_endpoint) | The internet routing endpoint URL for DFS storage in the primary location |
| <a name="output_primary_dfs_internet_host"></a> [primary\_dfs\_internet\_host](#output\_primary\_dfs\_internet\_host) | The internet routing hostname for DFS storage in the primary location |
| <a name="output_primary_dfs_microsoft_endpoint"></a> [primary\_dfs\_microsoft\_endpoint](#output\_primary\_dfs\_microsoft\_endpoint) | The microsoft routing endpoint URL for DFS storage in the primary location |
| <a name="output_primary_dfs_microsoft_host"></a> [primary\_dfs\_microsoft\_host](#output\_primary\_dfs\_microsoft\_host) | The microsoft routing hostname for DFS storage in the primary location |
| <a name="output_primary_file_endpoint"></a> [primary\_file\_endpoint](#output\_primary\_file\_endpoint) | The endpoint URL for file storage in the primary location |
| <a name="output_primary_file_host"></a> [primary\_file\_host](#output\_primary\_file\_host) | The hostname for file storage in the primary location |
| <a name="output_primary_file_internet_endpoint"></a> [primary\_file\_internet\_endpoint](#output\_primary\_file\_internet\_endpoint) | The internet routing endpoint URL for file storage in the primary location |
| <a name="output_primary_file_internet_host"></a> [primary\_file\_internet\_host](#output\_primary\_file\_internet\_host) | The internet routing hostname for file storage in the primary location |
| <a name="output_primary_file_microsoft_endpoint"></a> [primary\_file\_microsoft\_endpoint](#output\_primary\_file\_microsoft\_endpoint) | The microsoft routing endpoint URL for file storage in the primary location |
| <a name="output_primary_file_microsoft_host"></a> [primary\_file\_microsoft\_host](#output\_primary\_file\_microsoft\_host) | The microsoft routing hostname for file storage in the primary location |
| <a name="output_primary_location"></a> [primary\_location](#output\_primary\_location) | The primary location of the storage account |
| <a name="output_primary_queue_endpoint"></a> [primary\_queue\_endpoint](#output\_primary\_queue\_endpoint) | The endpoint URL for queue storage in the primary location |
| <a name="output_primary_queue_host"></a> [primary\_queue\_host](#output\_primary\_queue\_host) | The hostname for queue storage in the primary location |
| <a name="output_primary_table_endpoint"></a> [primary\_table\_endpoint](#output\_primary\_table\_endpoint) | The endpoint URL for table storage in the primary location |
| <a name="output_primary_table_host"></a> [primary\_table\_host](#output\_primary\_table\_host) | The hostname for table storage in the primary location |
| <a name="output_primary_web_endpoint"></a> [primary\_web\_endpoint](#output\_primary\_web\_endpoint) | The endpoint URL for web storage in the primary location |
| <a name="output_primary_web_host"></a> [primary\_web\_host](#output\_primary\_web\_host) | The hostname for web storage in the primary location |
| <a name="output_primary_web_internet_endpoint"></a> [primary\_web\_internet\_endpoint](#output\_primary\_web\_internet\_endpoint) | The internet routing endpoint URL for web storage in the primary location |
| <a name="output_primary_web_internet_host"></a> [primary\_web\_internet\_host](#output\_primary\_web\_internet\_host) | The internet routing hostname for web storage in the primary location |
| <a name="output_primary_web_microsoft_endpoint"></a> [primary\_web\_microsoft\_endpoint](#output\_primary\_web\_microsoft\_endpoint) | The microsoft routing endpoint URL for web storage in the primary location |
| <a name="output_primary_web_microsoft_host"></a> [primary\_web\_microsoft\_host](#output\_primary\_web\_microsoft\_host) | The microsoft routing hostname for web storage in the primary location |
| <a name="output_private_endpoint_subnet_id"></a> [private\_endpoint\_subnet\_id](#output\_private\_endpoint\_subnet\_id) | The ID of the subnet for private endpoints |
| <a name="output_private_endpoints"></a> [private\_endpoints](#output\_private\_endpoints) | Map of private endpoints |
| <a name="output_private_endpoints_by_subresource"></a> [private\_endpoints\_by\_subresource](#output\_private\_endpoints\_by\_subresource) | Private endpoints grouped by subresource type |
| <a name="output_queue_encryption_key_type"></a> [queue\_encryption\_key\_type](#output\_queue\_encryption\_key\_type) | The encryption type of the queue service |
| <a name="output_queue_properties_id"></a> [queue\_properties\_id](#output\_queue\_properties\_id) | The ID of the Storage Account Queue Properties |
| <a name="output_queues"></a> [queues](#output\_queues) | Map of created storage queues |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The name of the resource group |
| <a name="output_secondary_access_key"></a> [secondary\_access\_key](#output\_secondary\_access\_key) | The secondary access key |
| <a name="output_secondary_blob_connection_string"></a> [secondary\_blob\_connection\_string](#output\_secondary\_blob\_connection\_string) | The secondary blob connection string |
| <a name="output_secondary_blob_endpoint"></a> [secondary\_blob\_endpoint](#output\_secondary\_blob\_endpoint) | The secondary blob endpoint |
| <a name="output_secondary_blob_host"></a> [secondary\_blob\_host](#output\_secondary\_blob\_host) | The secondary blob host |
| <a name="output_secondary_blob_internet_endpoint"></a> [secondary\_blob\_internet\_endpoint](#output\_secondary\_blob\_internet\_endpoint) | The internet routing endpoint URL for blob storage in the secondary location |
| <a name="output_secondary_blob_internet_host"></a> [secondary\_blob\_internet\_host](#output\_secondary\_blob\_internet\_host) | The internet routing hostname for blob storage in the secondary location |
| <a name="output_secondary_blob_microsoft_endpoint"></a> [secondary\_blob\_microsoft\_endpoint](#output\_secondary\_blob\_microsoft\_endpoint) | The microsoft routing endpoint URL for blob storage in the secondary location |
| <a name="output_secondary_blob_microsoft_host"></a> [secondary\_blob\_microsoft\_host](#output\_secondary\_blob\_microsoft\_host) | The microsoft routing hostname for blob storage in the secondary location |
| <a name="output_secondary_connection_string"></a> [secondary\_connection\_string](#output\_secondary\_connection\_string) | The secondary connection string |
| <a name="output_secondary_dfs_endpoint"></a> [secondary\_dfs\_endpoint](#output\_secondary\_dfs\_endpoint) | The endpoint URL for DFS storage in the secondary location |
| <a name="output_secondary_dfs_host"></a> [secondary\_dfs\_host](#output\_secondary\_dfs\_host) | The hostname for DFS storage in the secondary location |
| <a name="output_secondary_dfs_internet_endpoint"></a> [secondary\_dfs\_internet\_endpoint](#output\_secondary\_dfs\_internet\_endpoint) | The internet routing endpoint URL for DFS storage in the secondary location |
| <a name="output_secondary_dfs_internet_host"></a> [secondary\_dfs\_internet\_host](#output\_secondary\_dfs\_internet\_host) | The internet routing hostname for DFS storage in the secondary location |
| <a name="output_secondary_dfs_microsoft_endpoint"></a> [secondary\_dfs\_microsoft\_endpoint](#output\_secondary\_dfs\_microsoft\_endpoint) | The microsoft routing endpoint URL for DFS storage in the secondary location |
| <a name="output_secondary_dfs_microsoft_host"></a> [secondary\_dfs\_microsoft\_host](#output\_secondary\_dfs\_microsoft\_host) | The microsoft routing hostname for DFS storage in the secondary location |
| <a name="output_secondary_file_endpoint"></a> [secondary\_file\_endpoint](#output\_secondary\_file\_endpoint) | The endpoint URL for file storage in the secondary location |
| <a name="output_secondary_file_host"></a> [secondary\_file\_host](#output\_secondary\_file\_host) | The hostname for file storage in the secondary location |
| <a name="output_secondary_file_internet_endpoint"></a> [secondary\_file\_internet\_endpoint](#output\_secondary\_file\_internet\_endpoint) | The internet routing endpoint URL for file storage in the secondary location |
| <a name="output_secondary_file_internet_host"></a> [secondary\_file\_internet\_host](#output\_secondary\_file\_internet\_host) | The internet routing hostname for file storage in the secondary location |
| <a name="output_secondary_file_microsoft_endpoint"></a> [secondary\_file\_microsoft\_endpoint](#output\_secondary\_file\_microsoft\_endpoint) | The microsoft routing endpoint URL for file storage in the secondary location |
| <a name="output_secondary_file_microsoft_host"></a> [secondary\_file\_microsoft\_host](#output\_secondary\_file\_microsoft\_host) | The microsoft routing hostname for file storage in the secondary location |
| <a name="output_secondary_location"></a> [secondary\_location](#output\_secondary\_location) | The secondary location of the storage account |
| <a name="output_secondary_queue_endpoint"></a> [secondary\_queue\_endpoint](#output\_secondary\_queue\_endpoint) | The endpoint URL for queue storage in the secondary location |
| <a name="output_secondary_queue_host"></a> [secondary\_queue\_host](#output\_secondary\_queue\_host) | The hostname for queue storage in the secondary location |
| <a name="output_secondary_table_endpoint"></a> [secondary\_table\_endpoint](#output\_secondary\_table\_endpoint) | The endpoint URL for table storage in the secondary location |
| <a name="output_secondary_table_host"></a> [secondary\_table\_host](#output\_secondary\_table\_host) | The hostname for table storage in the secondary location |
| <a name="output_secondary_web_endpoint"></a> [secondary\_web\_endpoint](#output\_secondary\_web\_endpoint) | The endpoint URL for web storage in the secondary location |
| <a name="output_secondary_web_host"></a> [secondary\_web\_host](#output\_secondary\_web\_host) | The hostname for web storage in the secondary location |
| <a name="output_secondary_web_internet_endpoint"></a> [secondary\_web\_internet\_endpoint](#output\_secondary\_web\_internet\_endpoint) | The internet routing endpoint URL for web storage in the secondary location |
| <a name="output_secondary_web_internet_host"></a> [secondary\_web\_internet\_host](#output\_secondary\_web\_internet\_host) | The internet routing hostname for web storage in the secondary location |
| <a name="output_secondary_web_microsoft_endpoint"></a> [secondary\_web\_microsoft\_endpoint](#output\_secondary\_web\_microsoft\_endpoint) | The microsoft routing endpoint URL for web storage in the secondary location |
| <a name="output_secondary_web_microsoft_host"></a> [secondary\_web\_microsoft\_host](#output\_secondary\_web\_microsoft\_host) | The microsoft routing hostname for web storage in the secondary location |
| <a name="output_shared_access_key_enabled"></a> [shared\_access\_key\_enabled](#output\_shared\_access\_key\_enabled) | Are shared access keys enabled |
| <a name="output_static_website"></a> [static\_website](#output\_static\_website) | Static website properties |
| <a name="output_static_website_id"></a> [static\_website\_id](#output\_static\_website\_id) | The ID of the Storage Account Static Website configuration |
| <a name="output_storage_account_id"></a> [storage\_account\_id](#output\_storage\_account\_id) | The ID of the storage account |
| <a name="output_storage_account_name"></a> [storage\_account\_name](#output\_storage\_account\_name) | The name of the storage account |
| <a name="output_table_encryption_key_type"></a> [table\_encryption\_key\_type](#output\_table\_encryption\_key\_type) | The encryption type of the table service |
| <a name="output_tables"></a> [tables](#output\_tables) | Map of created storage tables |
| <a name="output_tags"></a> [tags](#output\_tags) | Tags assigned to the storage account |
| <a name="output_virtual_network_id"></a> [virtual\_network\_id](#output\_virtual\_network\_id) | The ID of the Virtual Network |
<!-- END_TF_DOCS -->
