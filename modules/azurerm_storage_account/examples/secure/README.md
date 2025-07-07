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

### Threat Protection
- **Advanced Threat Protection**: Enabled for anomaly detection
- **Security Monitoring**: Real-time alerts to security team
- **Authentication Monitoring**: Alerts on failed authentication attempts

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