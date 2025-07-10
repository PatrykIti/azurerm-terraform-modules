# Azure Storage Account Module Documentation

This directory contains additional documentation for the Azure Storage Account Terraform module.

## Documentation Structure

### Main Documentation
- [`../README.md`](../README.md) - Main module documentation with usage examples
- [`../CHANGELOG.md`](../CHANGELOG.md) - Version history and change tracking
- [`../CONTRIBUTING.md`](../CONTRIBUTING.md) - Contribution guidelines
- [`../VERSIONING.md`](../VERSIONING.md) - Versioning strategy and guidelines

### Examples
- [`../examples/simple/`](../examples/simple/) - Basic storage account setup
- [`../examples/complete/`](../examples/complete/) - Full-featured enterprise deployment
- [`../examples/secure/`](../examples/secure/) - Maximum security configuration
- [`../examples/multi-region/`](../examples/multi-region/) - Multi-region DR setup

### Configuration Files
- [`../.terraform-docs.yml`](../.terraform-docs.yml) - Terraform-docs configuration
- [`../generate-docs.sh`](../generate-docs.sh) - Documentation generation script

## Quick Start

### 1. Basic Usage
```hcl
module "storage" {
  source = "../"
  
  name                = "mystorageaccount"
  resource_group_name = "my-resource-group"
  location            = "westeurope"
}
```

### 2. Generate Documentation
```bash
cd ..
./generate-docs.sh
```

### 3. Run Examples
```bash
cd ../examples/simple
terraform init
terraform plan
```

## Module Features

### Core Capabilities
- ✅ All storage account types supported
- ✅ Security-by-default configuration
- ✅ Network isolation with private endpoints
- ✅ Comprehensive monitoring and diagnostics
- ✅ Customer-managed encryption keys
- ✅ Lifecycle management policies
- ✅ Multi-region replication options

### Enterprise Features
- ✅ Advanced threat protection
- ✅ Immutability policies
- ✅ Compliance controls
- ✅ Cost optimization through lifecycle rules
- ✅ High availability configurations
- ✅ Disaster recovery patterns

## Architecture Patterns

### Single Region
- Simple deployment for development/testing
- Cost-effective for non-critical workloads
- Local redundancy options (LRS)

### Multi-Region
- Geographic redundancy (GRS/RAGRS)
- Read scale-out capabilities
- Disaster recovery preparedness
- Compliance with data residency

### Secure
- Private endpoint only access
- Customer-managed keys with HSM
- Advanced threat protection
- Comprehensive audit logging

## Security Best Practices

1. **Network Security**
   - Use private endpoints for production
   - Implement network ACLs
   - Disable public network access when possible

2. **Access Control**
   - Use Azure AD authentication
   - Implement RBAC
   - Disable shared key access when feasible

3. **Encryption**
   - Enable infrastructure encryption
   - Use customer-managed keys for sensitive data
   - Implement key rotation policies

4. **Monitoring**
   - Enable diagnostic settings
   - Configure security alerts
   - Regular access reviews

## Cost Optimization

1. **Storage Tiers**
   - Use Hot tier for frequently accessed data
   - Cool tier for infrequent access (30+ days)
   - Archive tier for long-term retention (180+ days)

2. **Lifecycle Policies**
   - Automate tier transitions
   - Delete expired data
   - Optimize costs based on access patterns

3. **Replication**
   - LRS for non-critical data
   - ZRS for high availability within region
   - GRS only when geographic redundancy required

## Troubleshooting

### Common Issues

1. **Name Already Taken**
   - Storage account names must be globally unique
   - Use random suffix or naming convention

2. **Network Access Denied**
   - Check firewall rules
   - Verify private endpoint configuration
   - Ensure DNS resolution is working

3. **Encryption Key Access**
   - Verify Key Vault access policies
   - Check managed identity permissions
   - Ensure Key Vault is accessible

### Debug Commands
```bash
# Check storage account status
az storage account show --name <storage-account-name>

# Verify network rules
az storage account network-rule list --account-name <storage-account-name>

# Test connectivity
nslookup <storage-account-name>.blob.core.windows.net
```

## Additional Resources

- [Azure Storage Documentation](https://docs.microsoft.com/en-us/azure/storage/)
- [Terraform AzureRM Provider Docs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure Storage Best Practices](https://docs.microsoft.com/en-us/azure/storage/common/storage-best-practices)
- [Azure Storage Security Guide](https://docs.microsoft.com/en-us/azure/storage/common/storage-security-guide)

## Support

For issues, questions, or contributions:
1. Check existing issues in the repository
2. Review the contributing guidelines
3. Open a new issue with detailed information
4. Follow the pull request process for contributions