# Contributing to Azure Storage Account Module

This guide covers contribution guidelines specific to the Storage Account module. For general repository standards, see the [main CONTRIBUTING.md](../../CONTRIBUTING.md).

## Module Overview

This module manages Azure Storage Accounts with secure defaults and optional advanced features:
- Network isolation (private endpoints, network rules)
- Encryption (infrastructure + customer-managed keys)
- Lifecycle management policies
- Queue/static website resources (separate azurerm resources)
- Diagnostic settings for storage account and services

## Module Structure

```
modules/azurerm_storage_account/
├── docs/IMPORT.md
├── examples/                 # basic, complete, secure + feature-specific examples
├── tests/                    # unit + Terratest
├── module.json               # module metadata
├── main.tf / variables.tf / outputs.tf
├── README.md / SECURITY.md / CHANGELOG.md
├── generate-docs.sh / Makefile
└── versions.tf
```

## Module-Specific Notes

### Provider Behavior
Some features are managed via separate resources (provider changes):
- `azurerm_storage_account_static_website`
- `azurerm_storage_account_queue_properties`

### Known Limitations / Considerations
- **Archive tier + ZRS**: Archive lifecycle tier is not supported with ZRS.
- **Diagnostic categories**: Categories differ per scope and region; the module filters by available categories.
- **Private endpoints**: Each storage service requires its own private endpoint.

## Development Workflow

### Documentation
- Module README: `make docs` or `./generate-docs.sh`
- Release-safe update from repo root: `./scripts/update-module-docs.sh azurerm_storage_account`

### Testing
- Unit tests: `terraform test -test-directory=tests/unit`
- Terratest: `cd tests && make test`
- Validate fixtures: `cd tests && make validate-fixtures`

## Release Process

- **Tag format**: `SAv{major}.{minor}.{patch}` (see `module.json`)
- **Commit scope**: `storage-account`
- Use the repository release workflow for version bumps.

## Checklist (Module Changes)

- [ ] Inputs/outputs updated with validations
- [ ] Examples updated (basic/complete/secure)
- [ ] Tests updated and passing
- [ ] README regenerated
- [ ] `docs/IMPORT.md` updated if applicable
