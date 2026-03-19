# Changelog

All notable changes to this module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial release of the azurerm_managed_redis module
- Core Managed Redis support via `azurerm_managed_redis`
- Optional geo-replication membership management via `azurerm_managed_redis_geo_replication`
- Inline diagnostic settings targeting the default database resource
- Basic, complete, secure, diagnostic-settings, customer-managed-key, and geo-replication examples
- Unit tests and Terratest scaffolding aligned with repo conventions

### Security
- Supports public network access hardening, CMK, and user-assigned identity validation
- Documents persistence, access key, and geo-replication operational risks

---

**Note**: This changelog is automatically updated by semantic-release based on conventional commits.
