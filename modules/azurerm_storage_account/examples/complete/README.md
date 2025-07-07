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