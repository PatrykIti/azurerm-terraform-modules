# 024 - 2025-12-25 - Storage Account module alignment (docs + diagnostics)

## Summary

Aligned `modules/azurerm_storage_account` with repository guides and added diagnostic settings support for storage account and service scopes.

## Changes

- Added module-level diagnostic settings with scope support and category filtering per region.
- Added `diagnostic_settings_skipped` output for skipped entries.
- Updated module documentation (README, SECURITY, IMPORT, docs index) and contribution guide.
- Normalized examples (local module source, added missing variables.tf, switched to module diagnostics).
- Updated test docs, added unit tests for diagnostics, and aligned fixture Terraform versions.
- Refreshed module automation (generate-docs script, Makefile) and added tests `.gitignore`.

## Impact

- New optional input: `diagnostic_settings`.
- Examples now use local module source (`../..`) for development/testing.
