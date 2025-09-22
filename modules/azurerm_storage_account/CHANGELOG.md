# Changelog

All notable changes to the Storage Account Terraform module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.2](https://github.com/PatrykIti/azurerm-terraform-modules/compare/SAv1.2.1...SAv1.2.2) (2025-09-22)

### 🐛 Bug Fixes

* **kubernetes-cluster,network-security-group,route-table,storage-account,subnet,virtual-network:** complete module implementation with tests and examples ([#65](https://github.com/PatrykIti/azurerm-terraform-modules/issues/65)) ([80dd2b9](https://github.com/PatrykIti/azurerm-terraform-modules/commit/80dd2b956a2ff8d970ea14ab1bd823234c22ea4a))
* **kubernetes-cluster,network-security-group,route-table,storage-account,subnet,virtual-network:** complete module implementation with tests and examples ([#67](https://github.com/PatrykIti/azurerm-terraform-modules/issues/67)) ([ddff590](https://github.com/PatrykIti/azurerm-terraform-modules/commit/ddff59038ed839e6ec5d0c538764c2b6fa56204c))
* **kubernetes-cluster,network-security-group,route-table,storage-account,subnet,virtual-network:** complete module implementation with tests and examples ([#68](https://github.com/PatrykIti/azurerm-terraform-modules/issues/68)) ([51e7c3e](https://github.com/PatrykIti/azurerm-terraform-modules/commit/51e7c3e7c3226b16fe499579a65a5d585f4752b3))
* **kubernetes-cluster,network-security-group,route-table,storage-account,subnet,virtual-network:** complete module implementation with tests and examples ([#69](https://github.com/PatrykIti/azurerm-terraform-modules/issues/69)) ([faf325c](https://github.com/PatrykIti/azurerm-terraform-modules/commit/faf325c0e00da3ac745efa5e664bf40c305420e1))

# Changelog

All notable changes to the Azure Storage Account Terraform module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Version Format

This module uses the format: `SAv{major}.{minor}.{patch}`
- `SA` = Storage Account module identifier
- `v` = version prefix
- Semantic versioning: `major.minor.patch`

## [Unreleased]

### Added
- Initial module structure and configuration
- Support for all storage account types (BlobStorage, BlockBlobStorage, FileStorage, Storage, StorageV2)
- Security features: HTTPS-only, TLS 1.2+, infrastructure encryption
- Network security: Private endpoints, network ACLs, firewall rules
- Monitoring: Diagnostic settings integration with Log Analytics
- Identity: System and user-assigned managed identities
- Encryption: Customer-managed keys with Key Vault
- Advanced features: Threat protection, lifecycle management, static website
- Comprehensive examples: simple, complete, secure, multi-region

### Changed
- N/A (initial release)

### Deprecated
- N/A (initial release)

### Removed
- N/A (initial release)

### Fixed
- N/A (initial release)

### Security
- Default security settings enforce HTTPS-only and TLS 1.2 minimum
- Public blob access disabled by default
- Support for infrastructure encryption

## [SAv1.0.0] - TBD

### Added
- Initial stable release
- Complete storage account management capabilities
- Enterprise-ready security features
- Multi-region support with replication options
- Comprehensive documentation and examples
- Terraform 1.3+ support
- AzureRM provider 3.0+ support

### Module Features
- **Core Functionality**
  - Create and manage Azure Storage Accounts
  - Support for all account kinds and tiers
  - Configurable replication types
  - Access tier management

- **Security**
  - Private endpoint support
  - Network ACLs and firewall rules
  - Customer-managed encryption keys
  - Infrastructure encryption
  - Advanced threat protection

- **Monitoring**
  - Diagnostic settings
  - Metrics and logs to Log Analytics
  - Configurable retention

- **Advanced Features**
  - Lifecycle management policies
  - Static website hosting
  - CORS configuration
  - Blob versioning and soft delete
  - Change feed support

### Examples Provided
1. **Simple**: Basic storage account with minimal configuration
2. **Complete**: Full-featured deployment with all enterprise capabilities
3. **Secure**: Maximum security configuration for sensitive data
4. **Multi-Region**: Disaster recovery setup across multiple regions

## Upgrade Guide

### Upgrading to SAv1.0.0
This is the initial release. No upgrade steps required.

## Version History Guidelines

When updating this changelog:

1. **Unreleased Section**: Add new changes here during development
2. **Version Sections**: Move unreleased items here when releasing
3. **Categories**: Use Added, Changed, Deprecated, Removed, Fixed, Security
4. **Breaking Changes**: Clearly mark with **BREAKING CHANGE:**
5. **References**: Link to issues/PRs where applicable

### Example Entry Format
```markdown
## [SAv1.1.0] - 2024-01-15

### Added
- Support for storage account failover operations (#123)
- New variable `enable_large_file_share` for file storage optimization

### Changed
- **BREAKING CHANGE:** Renamed variable `enable_logs` to `enable_diagnostic_settings` (#125)
- Updated minimum AzureRM provider version to 3.50.0

### Fixed
- Fixed issue with private endpoint DNS zone IDs (#124)
```
