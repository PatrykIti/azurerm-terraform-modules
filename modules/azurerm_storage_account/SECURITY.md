# Storage Account Module Security

## Overview

This document details the security features and configurations available in the Azure Storage Account Terraform module. The module implements comprehensive security controls to protect data at rest and in transit.

## Security Features

### 1. **Encryption**

#### At Rest
- **Infrastructure Encryption**: Enabled by default (`infrastructure_encryption_enabled = true`)
- **Service-Managed Keys**: Automatic encryption with Microsoft-managed keys
- **Customer-Managed Keys**: Optional support for bring-your-own-key (BYOK)
  ```hcl
  customer_managed_key = {
    key_vault_key_id          = azurerm_key_vault_key.example.id
    user_assigned_identity_id = azurerm_user_assigned_identity.example.id
  }
  ```

#### In Transit
- **HTTPS Only**: Enforced by default (`enable_https_traffic_only = true`)
- **Minimum TLS Version**: TLS 1.2 by default (`min_tls_version = "TLS1_2"`)
- **SMB Encryption**: Automatic for Azure Files

### 2. **Access Control**

#### Authentication Methods
- **Azure AD Authentication**: Recommended approach
  ```hcl
  azure_files_authentication = {
    directory_type = "AADDS"  # or "AD" for on-premises AD
  }
  ```
- **Shared Key**: Disabled by default (`shared_access_key_enabled = false`)
- **SAS Tokens**: Use Azure AD when possible

#### Network Security
- **Conditional Default Action**: When IP rules or subnet IDs are provided, access is allow-listed (default_action = "Deny"); when both are empty, public access is allowed
  ```hcl
  network_rules = {
    ip_rules = ["203.0.113.0/24"]
    bypass   = ["AzureServices"]
  }
  ```
- **Private Endpoints**: Full support for all storage services
  ```hcl
  private_endpoints = {
    blob = {
      name                 = "storage-blob-pe"
      subnet_id            = azurerm_subnet.private.id
      private_dns_zone_ids = [azurerm_private_dns_zone.blob.id]
    }
  }
  ```

### 3. **Data Protection**

#### Soft Delete
- **Blob Soft Delete**: 7 days retention by default
- **Container Soft Delete**: 7 days retention by default
- **File Share Soft Delete**: Configurable

#### Versioning
- **Blob Versioning**: Enabled by default
- **Change Feed**: Enabled for audit trail

#### Backup and Recovery
- **Point-in-time Restore**: Available with versioning
- **Immutable Blobs**: Support for compliance requirements

### 4. **Monitoring and Compliance**

#### Diagnostic Logging
```hcl
diagnostic_settings = {
  name                       = "storage-diagnostics"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  logs = [
    { category = "StorageRead" },
    { category = "StorageWrite" },
    { category = "StorageDelete" }
  ]
  metrics = [
    { category = "Transaction" },
    { category = "Capacity" }
  ]
}
```

#### Advanced Threat Protection
- **Microsoft Defender for Storage**: Enabled by default
- **Anomaly Detection**: Automatic threat detection
- **Security Alerts**: Real-time notifications

## Compliance Mapping

### SOC 2 Controls
| Control | Implementation |
|---------|---------------|
| CC6.1 - Logical Access | Azure AD authentication, RBAC |
| CC6.6 - Encryption | TLS 1.2, Infrastructure encryption |
| CC7.2 - Monitoring | Diagnostic logs, metrics |
| A1.1 - Availability | Replication options (GRS, ZRS) |

### ISO 27001 Controls
| Control | Implementation |
|---------|---------------|
| A.10.1.1 - Cryptographic controls | Encryption at rest and in transit |
| A.9.1.2 - Access to networks | Network ACLs, Private endpoints |
| A.12.4.1 - Event logging | Comprehensive diagnostic logging |
| A.18.1.3 - Protection of records | Immutability policies |

### GDPR Requirements
| Requirement | Implementation |
|-------------|---------------|
| Encryption (Art. 32) | Default encryption for all data |
| Access logs (Art. 30) | Diagnostic logging enabled |
| Data locality | Region-specific deployment |
| Right to erasure | Soft delete for recovery |

## Security Configuration Examples

### 1. **Maximum Security Configuration**
```hcl
module "storage_account" {
  source = "./modules/azurerm_storage_account"

  name                = "mystorageaccount"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  # Encryption
  infrastructure_encryption_enabled = true
  customer_managed_key = {
    key_vault_key_id          = azurerm_key_vault_key.storage.id
    user_assigned_identity_id = azurerm_user_assigned_identity.storage.id
  }

  # Access Control
  shared_access_key_enabled        = false
  allow_nested_items_to_be_public  = false
  
  # Network Security
  network_rules = {
    default_action             = "Deny"
    ip_rules                   = []  # No public IPs
    virtual_network_subnet_ids = [azurerm_subnet.storage.id]
    bypass                     = ["AzureServices"]
  }

  # Private Endpoints for all services
  private_endpoints = {
    blob = {
      name                 = "${var.name}-blob-pe"
      subnet_id            = azurerm_subnet.private.id
      private_dns_zone_ids = [azurerm_private_dns_zone.blob.id]
    }
    file = {
      name                 = "${var.name}-file-pe"
      subnet_id            = azurerm_subnet.private.id
      private_dns_zone_ids = [azurerm_private_dns_zone.file.id]
    }
    queue = {
      name                 = "${var.name}-queue-pe"
      subnet_id            = azurerm_subnet.private.id
      private_dns_zone_ids = [azurerm_private_dns_zone.queue.id]
    }
    table = {
      name                 = "${var.name}-table-pe"
      subnet_id            = azurerm_subnet.private.id
      private_dns_zone_ids = [azurerm_private_dns_zone.table.id]
    }
  }

  # Data Protection
  blob_properties = {
    versioning_enabled  = true
    change_feed_enabled = true
    delete_retention_policy = {
      days = 30
    }
    container_delete_retention_policy = {
      days = 30
    }
  }

  # Monitoring
  diagnostic_settings = {
    name                       = "${var.name}-diag"
    log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
    logs = [
      { category = "StorageRead" },
      { category = "StorageWrite" },
      { category = "StorageDelete" }
    ]
    metrics = [
      { category = "Transaction" },
      { category = "Capacity" }
    ]
  }

  # Threat Protection
  enable_advanced_threat_protection = true

  tags = {
    Environment        = "Production"
    DataClassification = "Confidential"
    Owner              = "security-team"
    CostCenter         = "IT-Security"
  }
}
```

### 2. **Development Environment Configuration**
```hcl
module "storage_account_dev" {
  source = "./modules/azurerm_storage_account"

  name                = "devstorageaccount"
  resource_group_name = azurerm_resource_group.dev.name
  location            = azurerm_resource_group.dev.location

  # Still secure by default, but allow some flexibility
  network_rules = {
    default_action = "Deny"
    ip_rules       = ["203.0.113.0/24"]  # Developer IPs
    bypass         = ["AzureServices", "Logging", "Metrics"]
  }

  # Basic monitoring
  diagnostic_settings = {
    name                       = "${var.name}-diag"
    log_analytics_workspace_id = azurerm_log_analytics_workspace.dev.id
    logs = [
      { category = "StorageWrite" },
      { category = "StorageDelete" }
    ]
    metrics = [
      { category = "Transaction" }
    ]
  }

  tags = {
    Environment        = "Development"
    DataClassification = "Internal"
  }
}
```

## Security Hardening Checklist

Before deploying to production, ensure:

- [ ] Infrastructure encryption is enabled
- [ ] Minimum TLS version is 1.2 or higher
- [ ] Public blob access is disabled
- [ ] Network rules default to Deny
- [ ] Private endpoints are configured for all used services
- [ ] Shared access keys are disabled (use Azure AD)
- [ ] Soft delete is enabled with appropriate retention
- [ ] Versioning is enabled for blob storage
- [ ] Diagnostic logging covers all operations
- [ ] Advanced threat protection is enabled
- [ ] Customer-managed keys are configured (if required)
- [ ] Appropriate tags are applied for compliance
- [ ] Firewall rules are minimized
- [ ] Regular access reviews are scheduled

## Common Security Mistakes to Avoid

1. **Enabling Public Access**
   ```hcl
   # ❌ AVOID
   allow_nested_items_to_be_public = true
   ```

2. **Using Shared Keys**
   ```hcl
   # ❌ AVOID
   shared_access_key_enabled = true
   ```

3. **Allowing All Networks**
   ```hcl
   # ❌ AVOID
   network_rules = {
     default_action = "Allow"
   }
   ```

4. **Disabling HTTPS**
   ```hcl
   # ❌ NEVER DO THIS
   enable_https_traffic_only = false
   ```

5. **Using Old TLS Versions**
   ```hcl
   # ❌ AVOID
   min_tls_version = "TLS1_0"
   ```

## Incident Response

If a security incident occurs:

1. **Immediate Actions**
   - Rotate all access keys
   - Review diagnostic logs
   - Check for unauthorized access
   - Enable additional logging if needed

2. **Investigation**
   - Use Log Analytics queries to investigate
   - Check Advanced Threat Protection alerts
   - Review network access logs

3. **Remediation**
   - Apply additional network restrictions
   - Implement additional monitoring
   - Update security configurations

## Additional Resources

- [Azure Storage security guide](https://docs.microsoft.com/en-us/azure/storage/common/storage-security-guide)
- [Azure Storage encryption](https://docs.microsoft.com/en-us/azure/storage/common/storage-service-encryption)
- [Private endpoints for Azure Storage](https://docs.microsoft.com/en-us/azure/storage/common/storage-private-endpoints)
- [Azure Storage threat protection](https://docs.microsoft.com/en-us/azure/storage/common/azure-defender-storage-configure)

---

**Module Version**: 1.0.0
**Last Updated**: 2024-06-30
**Security Contact**: patryk.ciechanski@patrykiti.pl
