# Secure Storage Account with Private Endpoints Example

This example demonstrates how to deploy a highly secure Azure Storage Account suitable for production environments handling sensitive data.

## Features

### Security Configuration
- ✅ **HTTPS-only traffic** - All communication encrypted in transit
- ✅ **TLS 1.2 minimum** - Modern encryption protocols only
- ✅ **Public blob access disabled** - No anonymous access to blobs
- ✅ **Infrastructure encryption** - Double encryption at rest (configurable)
- ✅ **Customer-managed keys** - Bring your own encryption keys with rotation
- ✅ **Network isolation** - Default deny with private endpoints
- ✅ **Private DNS zones** - Automatic name resolution for all storage services
- ✅ **Comprehensive logging** - All operations tracked in Log Analytics
- ✅ **Microsoft Defender** - Advanced threat protection for storage
- ✅ **Network Security Groups** - Traffic filtering at subnet level
- ✅ **Flow Logs** - Network traffic analysis and forensics
- ✅ **Azure Policy** - Automated compliance enforcement
- ✅ **Security Alerts** - Real-time threat detection

### Network Architecture
- **Virtual Network**: Isolated network with DDoS protection (optional)
- **Private Endpoints**: All storage services (blob, file, queue, table, dfs, web)
- **Private DNS Zones**: Complete DNS setup for all storage services
- **Service Endpoints**: Additional network-level security
- **Network ACLs**: Deny all public access by default
- **Network Security Groups**: Strict inbound/outbound rules
- **Flow Logs**: Traffic monitoring with analytics
- **Network Watcher**: Advanced network diagnostics

### Data Protection
- **Blob versioning**: Automatic version history
- **Soft delete**: 30-day recovery window
- **Change feed**: Audit trail of all changes
- **Diagnostic logging**: Comprehensive activity logs

### Compliance Features
- **Audit logging**: All operations logged to Log Analytics
- **Encryption at rest**: AES-256 with customer-managed keys
- **Key rotation**: Automatic reminders and rotation policy
- **Access controls**: Azure AD authentication required
- **Azure Policy**: 6 built-in policies + custom policies
- **Compliance reporting**: Automated compliance dashboards
- **Resource locks**: Prevent accidental deletion
- **Monitoring**: Real-time security alerts with anomaly detection

## Prerequisites

- Azure subscription with appropriate permissions
- Terraform >= 1.3.0
- AzureRM Provider 4.35.0 (correctly pinned to match the module version)
- Network connectivity for private endpoints
- Permissions to create:
  - Virtual Networks and Subnets
  - Private Endpoints and DNS Zones
  - Key Vault with encryption keys
  - Log Analytics workspace

**Note**: The module uses a pinned version of the AzureRM provider (4.35.0) to ensure consistent behavior across all deployments.

## Usage

```bash
# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply the configuration
terraform apply
```

## Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         Azure Virtual Network                            │
│                            10.0.0.0/16                                   │
│                                                                          │
│  ┌─────────────────────────────┐     ┌────────────────────────────┐    │
│  │   Private Endpoints Subnet   │     │    Application Subnet      │    │
│  │       10.0.1.0/24            │     │       10.0.2.0/24          │    │
│  │                              │     │                            │    │
│  │  Private Endpoints:          │     │  • Service Endpoints       │    │
│  │  • Blob PE  ─┐               │     │  • Apps/VMs                │    │
│  │  • File PE  ─┼─┐             │     │  • Allowed in Network ACL  │    │
│  │  • Queue PE ─┼─┼─┐           │     │                            │    │
│  │  • Table PE ─┼─┼─┼─┐         │     │                            │    │
│  └──────────────┼─┼─┼─┼─────────┘     └────────────────────────────┘    │
│                 │ │ │ │                                                  │
│  ┌──────────────▼─▼─▼─▼─────────────────────────────────────────────┐   │
│  │                    Private DNS Zones                              │   │
│  │  • privatelink.blob.core.windows.net                              │   │
│  │  • privatelink.file.core.windows.net                              │   │
│  │  • privatelink.queue.core.windows.net                             │   │
│  │  • privatelink.table.core.windows.net                             │   │
│  └───────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────┘
                                   │
                                   │ Private Connectivity Only
                                   │ (No Public Access)
                                   │
                       ┌───────────▼──────────────┐
                       │     Storage Account      │
                       │   stsecure<random>       │
                       │                          │
                       │ Security Features:       │
                       │ • CMK Encryption (KEK)   │
                       │ • Infrastructure Encrypt │
                       │ • Network ACL: Deny All  │
                       │ • Private Endpoints Only │
                       │ • TLS 1.2 Minimum       │
                       │ • Versioning Enabled     │
                       │ • Soft Delete (30 days) │
                       └──────────────────────────┘
                                   │
                                   │ Logs & Metrics
                                   │
                       ┌───────────▼──────────────┐
                       │   Log Analytics          │
                       │   Workspace              │
                       │                          │
                       │ • Storage Operations     │
                       │ • Security Events        │
                       │ • Performance Metrics    │
                       └──────────────────────────┘
```

## Security Considerations

1. **Key Management**
   - Keys are stored in Azure Key Vault with purge protection
   - Access to keys requires explicit permissions
   - Regular key rotation is recommended

2. **Network Security**
   - No public endpoints exposed
   - All traffic flows through private endpoints
   - DNS resolution handled by private DNS zones

3. **Access Control**
   - Shared key access enabled (required for Terraform management)
   - Consider disabling shared keys post-deployment for maximum security
   - Use Azure AD authentication and RBAC for application access

4. **Monitoring**
   - All operations logged to Log Analytics
   - Advanced threat protection alerts
   - Regular security reviews recommended

## Cost Optimization

While this configuration prioritizes security, consider:
- Private endpoints incur additional costs
- Advanced threat protection is a premium feature
- Customer-managed keys require Key Vault
- Comprehensive logging increases storage costs

## Customization

To adapt this example for your needs:

1. **Network Configuration**
   ```hcl
   # Add your IP ranges if needed (not recommended for production)
   network_rules = {
     ip_rules = ["YOUR_IP_RANGE"]
   }
   ```

2. **Retention Policies**
   ```hcl
   # Adjust retention based on compliance requirements
   delete_retention_policy = {
     days = 90  # Increase for longer retention
   }
   ```

3. **Diagnostic Settings**
   ```hcl
   # Add additional log categories as needed
   logs = [
     { category = "StorageRead" },
     { category = "StorageWrite" },
     { category = "StorageDelete" },
     { category = "Transaction" }  # Additional category
   ]
   ```

## Private Endpoint Setup Observations

### Key Implementation Details

1. **Network Policy Configuration**
   - The subnet for private endpoints has `private_endpoint_network_policies = "Disabled"`
   - This is required for private endpoints to function properly
   - Previously known as `enforce_private_link_endpoint_network_policies`

2. **DNS Integration**
   - Each storage service (blob, file, queue, table) requires its own private DNS zone
   - DNS zones follow the pattern: `privatelink.<service>.core.windows.net`
   - Virtual network links connect the DNS zones to the VNet for automatic resolution

3. **Service-Specific Endpoints**
   - Each storage service gets its own private endpoint
   - Subresource names map to storage services: blob, file, queue, table
   - All endpoints are created in a dedicated subnet for better management

4. **Network Isolation**
   - Network ACLs are set to "Deny" by default
   - Only the application subnet is allowed via service endpoints
   - Private endpoints bypass network ACLs by design

5. **Public Access Note**
   - The module currently doesn't support the `public_network_access_enabled` parameter
   - Network isolation is achieved through network ACLs with `default_action = "Deny"`
   - This provides similar security but allows Azure services to bypass if needed

### Best Practices Demonstrated

- **Dedicated Subnet**: Private endpoints are isolated in their own subnet
- **Complete DNS Setup**: All required DNS zones and links are pre-configured
- **Multiple Services**: Example shows how to configure all storage services
- **Dependencies**: Proper dependency management ensures resources are created in order
- **Security Layers**: Multiple security controls work together for defense in depth

## Security Enhancements in This Example

### 1. Advanced Threat Protection
- Microsoft Defender for Storage with malware scanning
- Sensitive data discovery
- Anomaly detection for data access patterns
- Real-time security alerts

### 2. Network Security Hardening
- Network Security Groups with restrictive rules
- NSG Flow Logs for traffic analysis
- Traffic Analytics integration
- Optional DDoS Protection Standard

### 3. Policy Compliance
- 6 Azure Policy assignments for security compliance
- Custom policy for TLS version enforcement
- Automated compliance reporting
- Policy violation alerts

### 4. Enhanced Monitoring
- Authentication failure alerts
- Data exfiltration detection
- Key Vault access monitoring
- Security-focused Log Analytics queries
- Application Insights for security dashboards

### 5. Key Management
- Automatic key rotation policy (90 days)
- Key expiration reminders
- Comprehensive Key Vault access policies
- Key Vault diagnostic logging

## Configuration Variables

Key variables to customize the deployment:

| Variable | Description | Default |
|----------|-------------|---------||
| `enable_advanced_threat_protection` | Enable Microsoft Defender | true |
| `enable_network_flow_logs` | Enable NSG flow logs | true |
| `enable_azure_policy_compliance` | Enable policy assignments | true |
| `enable_infrastructure_encryption` | Double encryption at rest | true |
| `key_rotation_reminder_days` | Days before key expiry alert | 30 |
| `log_retention_days` | Log retention period | 90 |
| `enable_ddos_protection` | DDoS Protection Standard | false |

## Security Operations

### Daily Tasks
1. Review security alerts in Azure Security Center
2. Check authentication failure logs
3. Monitor data access patterns

### Weekly Tasks
1. Review policy compliance status
2. Analyze flow logs for anomalies
3. Check Key Vault access logs

### Monthly Tasks
1. Review and update network rules
2. Audit user permissions
3. Test incident response procedures

### Quarterly Tasks
1. Rotate encryption keys
2. Review and update security policies
3. Conduct security assessment

## Cost Considerations

Premium security features that incur additional costs:
- Microsoft Defender for Storage (~$0.02/GB scanned)
- Private Endpoints (~$0.01/hour per endpoint)
- DDoS Protection Standard (~$2,944/month)
- Flow Logs and Traffic Analytics
- Extended log retention

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

**Note**: 
- Due to Key Vault soft-delete and purge protection, the Key Vault and keys will remain in a soft-deleted state for 90 days
- Resource locks must be removed before deletion
- Some policy assignments may need manual cleanup