# Secure Storage Account Example

This example demonstrates a maximum-security Azure Storage Account configuration suitable for highly sensitive data and regulated environments.

## Security Features

### Zero-Trust Network Security
- **Complete Network Isolation**: `public_network_access_enabled = false`
- **Private Endpoints Only**: No public access, all connections via private endpoints
- **No Service Bypass**: Even Azure services must use private endpoints
- **Private DNS Integration**: Automatic DNS resolution for private endpoints
- **Copy Scope Restriction**: `allowed_copy_scope = "PrivateLink"` - Data can only be copied within the same private network
- **Cross-Tenant Protection**: `cross_tenant_replication_enabled = false` - Prevents data leakage across Azure AD tenants

### Enhanced Encryption
- **HSM-Protected Keys**: Using RSA-HSM 4096-bit keys in Premium Key Vault
- **Key Rotation**: Automatic key rotation every 365 days
- **Infrastructure Encryption**: Double encryption at rest
- **Customer-Managed Keys**: Full control over encryption keys
- **Queue Encryption**: `queue_encryption_key_type = "Account"` - Queue service uses storage account encryption keys
- **Table Encryption**: `table_encryption_key_type = "Account"` - Table service uses storage account encryption keys

### Access Control
- **OAuth Authentication Default**: `default_to_oauth_authentication = true` - Forces Azure AD authentication in Azure Portal
- **No Shared Access Keys**: `shared_access_key_enabled = false` - Eliminates key-based authentication vulnerability
- **Managed Identities**: System and user-assigned identities for secure service-to-service authentication
- **No Anonymous Access**: Public blob access completely disabled
- **RBAC Integration**: Role-based access control enforced for all access

### Compliance & Auditing
- **Extended Retention**: 365-day soft delete for blobs and containers
- **Audit Logging**: Comprehensive logging to Log Analytics
- **Change Feed**: One-year retention for audit trail
- **Versioning**: All changes tracked and retained
- **Security Alerts**: Automated alerts for authentication failures

### Security Monitoring
- **Authentication Monitoring**: Alerts on failed authentication attempts
- **Activity Logging**: Comprehensive audit trails in Log Analytics
- **Real-time Alerts**: Automated notifications to security team

## Use Cases

This configuration is suitable for:
- **Financial Services**: PCI-DSS compliant storage
- **Healthcare**: HIPAA-compliant data storage
- **Government**: High-security classification data
- **Legal**: Attorney-client privileged information
- **Research**: Confidential research data

## Architecture

```
┌─────────────────────┐
│   Private VNet      │
│  ┌───────────────┐  │
│  │Private Endpoint│  │
│  └───────┬───────┘  │
│          │          │
└──────────┼──────────┘
           │
    ┌──────▼──────┐
    │   Storage   │ ← No Public Access
    │   Account   │ ← HSM Encryption
    └─────────────┘ ← Azure AD Auth Only
```

## Prerequisites

- Azure subscription with appropriate security clearances
- Terraform >= 1.3.0
- AzureRM Provider 4.35.0 (as specified in the module's [versions.tf](../../versions.tf))
- Permissions to create:
  - Premium Key Vault with HSM
  - Private endpoints and DNS zones
  - Log Analytics workspace
  - Monitor alerts
- Network connectivity to private endpoints

**Note**: The module uses a pinned version of the AzureRM provider (4.35.0) to ensure consistent behavior across all deployments.

## Deployment Considerations

### Pre-deployment
1. **IP Allowlist**: Update Key Vault network ACLs with your management IPs
2. **Alert Recipients**: Update security team email in action group
3. **Compliance Tags**: Adjust tags for your compliance requirements

### Post-deployment
1. **Access Reviews**: Set up regular access reviews
2. **Key Rotation**: Verify automatic key rotation policy
3. **Monitoring**: Configure additional security alerts as needed
4. **Backup**: Implement backup strategy for critical data

## Security Hardening Checklist

- ✅ Public network access disabled (`public_network_access_enabled = false`)
- ✅ Shared access keys disabled (`shared_access_key_enabled = false`)
- ✅ OAuth authentication enforced (`default_to_oauth_authentication = true`)
- ✅ Infrastructure encryption enabled
- ✅ HSM-protected encryption keys
- ✅ Private endpoints for all services
- ✅ Copy scope restricted to private links (`allowed_copy_scope = "PrivateLink"`)
- ✅ Cross-tenant replication disabled (`cross_tenant_replication_enabled = false`)
- ✅ Queue and Table services using account encryption keys
- ✅ Advanced threat protection enabled
- ✅ Comprehensive audit logging
- ✅ Extended soft delete retention (365 days)
- ✅ Authentication failure alerts
- ✅ No CORS rules (API access only)
- ✅ Minimum TLS 1.2 enforced (`min_tls_version = "TLS1_2"`)

## Cost Considerations

This maximum security configuration includes premium features:
- Premium Key Vault (HSM-backed)
- Premium Block Blob Storage (ZRS)
- Extended log retention (90 days)
- Advanced Threat Protection
- Multiple private endpoints

## Compliance Mapping

| Requirement | Implementation |
|-------------|----------------|
| Encryption at Rest | CMK with HSM, Infrastructure encryption |
| Encryption in Transit | TLS 1.2 minimum, HTTPS only |
| Access Control | Azure AD only, RBAC |
| Network Security | Private endpoints, no public access |
| Audit Logging | Comprehensive logs to Log Analytics |
| Data Retention | 365-day soft delete |
| Key Management | HSM-protected keys with rotation |
| Threat Detection | Advanced Threat Protection |

## Usage

```bash
# Initialize Terraform
terraform init

# Review the security configuration
terraform plan

# Deploy the secure storage account
terraform apply

# Verify private endpoint connectivity
nslookup <storage-account-name>.blob.core.windows.net
```

## Security Posture Achieved

This configuration implements a **Defense-in-Depth** strategy with multiple layers of security:

### 1. **Authentication & Authorization Layer**
- OAuth/Azure AD is the only authentication method (`shared_access_key_enabled = false`)
- Portal access defaults to Azure AD authentication (`default_to_oauth_authentication = true`)
- All access controlled through RBAC roles

### 2. **Network Security Layer**
- Complete isolation from public internet (`public_network_access_enabled = false`)
- Private endpoints with private DNS zones for all services
- No bypass rules for Azure services - everything must use private endpoints

### 3. **Data Protection Layer**
- Data movement restricted to private network only (`allowed_copy_scope = "PrivateLink"`)
- Cross-tenant data movement blocked (`cross_tenant_replication_enabled = false`)
- Infrastructure encryption provides double encryption at rest

### 4. **Encryption Layer**
- HSM-protected customer-managed keys with automatic rotation
- All services (Blob, Queue, Table) use account-level encryption keys
- TLS 1.2 minimum for all connections

### 5. **Compliance & Audit Layer**
- Comprehensive logging of all read/write/delete operations
- 365-day retention for soft-deleted data
- Real-time security alerts for suspicious activities

## Important Notes

1. **No Public Access**: This storage account is only accessible via private endpoints
2. **Azure AD Authentication**: Configure RBAC roles before attempting access
3. **Key Vault Access**: Ensure proper access policies for key management
4. **Network Planning**: Private endpoints require network connectivity
5. **Monitoring**: Review security alerts and logs regularly
6. **OAuth Setup**: Applications must be configured for Azure AD authentication (no SAS tokens)
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
| [azurerm_monitor_action_group.security](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_action_group) | resource |
| [azurerm_monitor_metric_alert.storage_auth_failures](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) | resource |
| [azurerm_private_dns_zone.storage](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) | resource |
| [azurerm_private_dns_zone_virtual_network_link.storage](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) | resource |
| [azurerm_resource_group.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_subnet.private_endpoints](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_user_assigned_identity.storage](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [azurerm_virtual_network.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [random_string.suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_encryption_key_id"></a> [encryption\_key\_id](#output\_encryption\_key\_id) | The ID of the encryption key |
| <a name="output_identity_principal_id"></a> [identity\_principal\_id](#output\_identity\_principal\_id) | The principal ID of the storage account's system-assigned identity |
| <a name="output_key_vault_uri"></a> [key\_vault\_uri](#output\_key\_vault\_uri) | The URI of the Key Vault |
| <a name="output_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#output\_log\_analytics\_workspace\_id) | The ID of the Log Analytics workspace for security monitoring |
| <a name="output_network_security_status"></a> [network\_security\_status](#output\_network\_security\_status) | Network security configuration status |
| <a name="output_primary_blob_endpoint"></a> [primary\_blob\_endpoint](#output\_primary\_blob\_endpoint) | The primary blob endpoint (accessible only via private endpoint) |
| <a name="output_private_endpoint_ids"></a> [private\_endpoint\_ids](#output\_private\_endpoint\_ids) | Map of private endpoint IDs |
| <a name="output_security_alert_id"></a> [security\_alert\_id](#output\_security\_alert\_id) | The ID of the authentication failure alert |
| <a name="output_security_configuration"></a> [security\_configuration](#output\_security\_configuration) | Summary of security settings applied to the storage account |
| <a name="output_storage_account_id"></a> [storage\_account\_id](#output\_storage\_account\_id) | The ID of the storage account |
| <a name="output_storage_account_name"></a> [storage\_account\_name](#output\_storage\_account\_name) | The name of the storage account |
<!-- END_TF_DOCS -->
