# Azure Storage Account Terraform Module

This module creates an Azure Storage Account with comprehensive security configurations and enterprise-grade features.

## Features

- 🔒 **Security-by-default configuration**
- 🔐 **Private endpoint support** for all storage services
- 🛡️ **Advanced threat protection**
- 🔑 **Customer-managed key encryption**
- 📊 **Comprehensive diagnostic logging**
- 🌐 **Network isolation with firewall rules**
- 🆔 **Azure AD authentication support**
- 💾 **Data protection with soft delete and versioning**

## Usage

### Basic Example

```hcl
module "storage_account" {
  source = "terraform-azurerm-modules/storage-account/azurerm"

  name                = "mystorageaccount"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  tags = {
    Environment = "Production"
    Owner       = "TeamName"
  }
}
```

### Secure Example with Private Endpoints

```hcl
module "secure_storage" {
  source = "terraform-azurerm-modules/storage-account/azurerm"

  name                = "securestorageaccount"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  # Disable public access
  network_rules = {
    default_action = "Deny"
    bypass         = ["AzureServices"]
  }

  # Configure private endpoints
  private_endpoints = {
    blob = {
      name                 = "blob-private-endpoint"
      subnet_id            = azurerm_subnet.private.id
      private_dns_zone_ids = [azurerm_private_dns_zone.blob.id]
    }
  }

  # Enable diagnostic logging
  diagnostic_settings = {
    name                       = "storage-diagnostics"
    log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
    logs = [
      { category = "StorageRead" },
      { category = "StorageWrite" },
      { category = "StorageDelete" }
    ]
    metrics = [
      { category = "Transaction" }
    ]
  }

  tags = {
    Environment        = "Production"
    DataClassification = "Confidential"
  }
}
```

## Security Features

This module implements security best practices by default:

- **HTTPS-only traffic**: Enforced by default
- **TLS 1.2 minimum**: No support for older TLS versions
- **Public access disabled**: Blobs are private by default
- **Infrastructure encryption**: Additional layer of encryption
- **Network isolation**: Default deny with explicit allow rules
- **Azure AD authentication**: Preferred over shared keys
- **Audit logging**: All operations can be logged

For detailed security information, see [SECURITY.md](./SECURITY.md).

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.3.0 |
| azurerm | >= 3.0.0 |

## Providers

| Name | Version |
|------|---------|
| azurerm | >= 3.0.0 |

## Resources

| Name | Type |
|------|------|
| azurerm_storage_account.this | resource |
| azurerm_private_endpoint.this | resource |
| azurerm_monitor_diagnostic_setting.this | resource |
| azurerm_advanced_threat_protection.this | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | The name of the storage account | `string` | n/a | yes |
| resource_group_name | The name of the resource group | `string` | n/a | yes |
| location | The Azure Region | `string` | n/a | yes |
| account_tier | Defines the Tier (Standard/Premium) | `string` | `"Standard"` | no |
| account_replication_type | Type of replication (LRS/GRS/RAGRS/ZRS/GZRS/RAGZRS) | `string` | `"ZRS"` | no |
| min_tls_version | Minimum TLS version | `string` | `"TLS1_2"` | no |
| network_rules | Network ACL configuration | `object` | See variables.tf | no |
| private_endpoints | Private endpoint configuration | `map(object)` | `{}` | no |
| diagnostic_settings | Diagnostic logging configuration | `object` | `null` | no |
| tags | Resource tags | `map(string)` | `{}` | no |

For a complete list of inputs, see [variables.tf](./variables.tf).

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the Storage Account |
| name | The name of the Storage Account |
| primary_blob_endpoint | The endpoint URL for blob storage |
| primary_access_key | The primary access key (sensitive) |
| private_endpoints | Map of private endpoint configurations |
| identity | The identity configuration of the Storage Account |

For a complete list of outputs, see [outputs.tf](./outputs.tf).

## Examples

- [Basic](./examples/simple) - Simple storage account configuration
- [Complete](./examples/complete) - Full feature demonstration
- [Secure with Private Endpoints](./examples/secure-private-endpoint) - Production-ready secure configuration

## Development

### Pre-commit Hooks

This repository uses pre-commit hooks for security scanning and code quality:

```bash
pip install pre-commit
pre-commit install
```

### Security Scanning

Run security scans manually:

```bash
./scripts/security-scan.sh
```

### Testing

Run Terratest tests:

```bash
cd tests
go test -v -timeout 30m
```

## Contributing

Please see [CONTRIBUTING.md](../CONTRIBUTING.md) for guidelines.

## License

This module is licensed under the MIT License. See [LICENSE](../LICENSE) for details.

## Support

For issues and feature requests, please use the [GitHub issues](https://github.com/your-org/terraform-azurerm-modules/issues) page.