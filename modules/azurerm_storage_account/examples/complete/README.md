# Complete Storage Account Example

This example demonstrates a comprehensive enterprise-grade Azure Storage Account deployment with all security and monitoring features enabled.

## Features Demonstrated

### Security
- **Encryption**: Customer-managed keys (CMK) with Azure Key Vault
- **Network Security**: Private endpoints for all storage services (blob, file, queue, table)
- **Access Control**: Disabled public access, network ACLs with IP and subnet restrictions
- **Identity**: System and user-assigned managed identities
- **Advanced Threat Protection**: Enabled for security monitoring

### High Availability
- **Zone-Redundant Storage (ZRS)**: Data replicated across availability zones
- **Versioning**: Blob versioning enabled for data protection
- **Soft Delete**: 30-day retention for deleted blobs and containers

### Monitoring & Compliance
- **Diagnostic Settings**: Full metrics and logs to Log Analytics
- **Change Feed**: Enabled for audit trail
- **Last Access Time Tracking**: For lifecycle management
- **CORS Configuration**: For web applications

### Lifecycle Management
- **Archive Policy**: Automatically tier old logs to cool/archive storage
- **Cleanup Policy**: Delete temporary data after 7 days
- **Version Management**: Clean up old versions after 90 days

### Enterprise Features
- **Static Website**: Configured for hosting static content
- **SMB Multi-Channel**: Enhanced file share performance
- **Infrastructure Encryption**: Double encryption at rest

## Prerequisites

- Azure subscription with appropriate permissions
- Terraform >= 1.3.0
- AzureRM Provider 4.35.0 (as specified in the module's [versions.tf](../../versions.tf))

**Note**: The module uses a pinned version of the AzureRM provider (4.35.0) to ensure consistent behavior across all deployments.
- Sufficient quota for:
  - Storage accounts
  - Virtual networks and subnets
  - Private endpoints
  - Key Vault
  - Log Analytics workspace

## Usage

```bash
# Initialize Terraform
terraform init

# Review the planned changes
terraform plan

# Apply the configuration
terraform apply
```

## Network Architecture

The example creates a complete network setup:
- Virtual Network: 10.0.0.0/16
- Private Endpoints Subnet: 10.0.1.0/24
- Services Subnet: 10.0.2.0/24 (with service endpoints)

## Security Considerations

1. **Key Vault Access**: The example grants necessary permissions to the current user and managed identity
2. **Network Rules**: Default action is "Deny" - adjust IP rules for your environment
3. **Private DNS**: Automatically configured for private endpoint resolution
4. **Shared Access Keys**: Disabled in this example - use Azure AD authentication

## Cost Optimization

This example includes several cost optimization features:
- Lifecycle policies for automatic blob tiering
- Metrics retention limited to 30 days
- Archive tier for old logs

## Customization

To adapt this example for your environment:
1. Update the `ip_rules` in network_rules with your allowed IP ranges
2. Modify the `allowed_origins` in CORS rules for your domains
3. Adjust lifecycle policies based on your data retention requirements
4. Configure tags according to your organization's standards

## Outputs

- Storage account details (ID, name, endpoints)
- Private endpoint IDs for each service
- Key Vault and Log Analytics workspace IDs
- Identity configuration
- Connection strings (marked as sensitive)