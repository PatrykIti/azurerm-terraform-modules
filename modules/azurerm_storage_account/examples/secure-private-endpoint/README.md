# Secure Storage Account with Private Endpoints Example

This example demonstrates how to deploy a highly secure Azure Storage Account suitable for production environments handling sensitive data.

## Features

### Security Configuration
- ✅ **HTTPS-only traffic** - All communication encrypted in transit
- ✅ **TLS 1.2 minimum** - Modern encryption protocols only
- ✅ **Public access disabled** - No anonymous access to blobs
- ✅ **Shared keys disabled** - Azure AD authentication only
- ✅ **Infrastructure encryption** - Double encryption at rest
- ✅ **Advanced threat protection** - Real-time security monitoring
- ✅ **Customer-managed keys** - Bring your own encryption keys
- ✅ **Network isolation** - Default deny with private endpoints

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
┌─────────────────────────────────────────────────────────────┐
│                     Azure Virtual Network                    │
│                         10.0.0.0/16                          │
│                                                              │
│  ┌─────────────────────────┐  ┌───────────────────────┐    │
│  │   Private Endpoints      │  │   Application Subnet   │    │
│  │     10.0.1.0/24          │  │     10.0.2.0/24        │    │
│  │                          │  │                        │    │
│  │  • Blob PE               │  │  • Service Endpoints   │    │
│  │  • File PE               │  │  • Apps/VMs            │    │
│  │  • Queue PE              │  │                        │    │
│  │  • Table PE              │  │                        │    │
│  └─────────────────────────┘  └───────────────────────┘    │
│                                                              │
└─────────────────────────────────────────────────────────────┘
                               │
                               │ Private Connectivity
                               │
                    ┌──────────▼──────────┐
                    │   Storage Account   │
                    │                      │
                    │  • CMK Encryption    │
                    │  • Network Isolated  │
                    │  • AD Auth Only      │
                    │  • Threat Protection │
                    └──────────────────────┘
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
   - Azure AD authentication required
   - No shared key access
   - RBAC for fine-grained permissions

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

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

**Note**: Due to Key Vault soft-delete and purge protection, the Key Vault and keys will remain in a soft-deleted state for 90 days.