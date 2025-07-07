# Secure Storage Account with Private Endpoints Example

This example demonstrates how to deploy a highly secure Azure Storage Account suitable for production environments handling sensitive data.

## Features

### Security Configuration
- ✅ **HTTPS-only traffic** - All communication encrypted in transit
- ✅ **TLS 1.2 minimum** - Modern encryption protocols only
- ✅ **Public blob access disabled** - No anonymous access to blobs
- ✅ **Infrastructure encryption** - Double encryption at rest
- ✅ **Customer-managed keys** - Bring your own encryption keys
- ✅ **Network isolation** - Default deny with private endpoints
- ✅ **Private DNS zones** - Automatic name resolution for private endpoints
- ✅ **Comprehensive logging** - All operations tracked in Log Analytics

### Network Architecture
- **Virtual Network**: Isolated network for resources
- **Private Endpoints**: All storage services accessible only via private IPs
- **Private DNS Zones**: Automatic DNS resolution for private endpoints
- **Service Endpoints**: Additional network-level security
- **Network ACLs**: Deny all public access by default

### Data Protection
- **Blob versioning**: Automatic version history
- **Soft delete**: 30-day recovery window
- **Change feed**: Audit trail of all changes
- **Diagnostic logging**: Comprehensive activity logs

### Compliance Features
- **Audit logging**: All operations logged to Log Analytics
- **Encryption at rest**: AES-256 with customer-managed keys
- **Access controls**: Azure AD authentication required
- **Monitoring**: Real-time security alerts

## Prerequisites

- Azure subscription with appropriate permissions
- Terraform >= 1.3.0
- AzureRM Provider 4.35.0 (as specified in the module's [versions.tf](../../versions.tf))
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

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

**Note**: Due to Key Vault soft-delete and purge protection, the Key Vault and keys will remain in a soft-deleted state for 90 days.