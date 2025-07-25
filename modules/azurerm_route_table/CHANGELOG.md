# Changelog

All notable changes to this module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial release of the azurerm_route_table module
- Core functionality for managing Azure Route Tables with custom routes configuration and BGP route propagation settings
- Network wrapper example demonstrating subnet association pattern

### Changed
- BREAKING: Removed subnet association functionality from the module. Subnet associations should now be managed at the wrapper/consumer level using `azurerm_subnet_route_table_association` resources. This change addresses Terraform's limitation with for_each and unknown values at plan time.

### Security
- All security features are enabled by default
- Follows Azure security best practices

---

**Note**: This changelog is automatically updated by semantic-release based on conventional commits.