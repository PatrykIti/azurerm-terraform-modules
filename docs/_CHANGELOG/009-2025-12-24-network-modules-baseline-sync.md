# Filename: 009-2025-12-24-network-modules-baseline-sync.md

# 009. Network modules baseline sync (AKS alignment)

**Date:** 2025-12-24  
**Type:** Fix / Maintenance  
**Scope:** `modules/azurerm_route_table/`, `modules/azurerm_storage_account/`, `modules/azurerm_subnet/`, `modules/azurerm_virtual_network/`  
**Tasks:** —

---

## Key Changes

- **Provider pin aligned:** updated azurerm version to **4.57.0** in module `versions.tf`, examples, and fixtures to match the AKS baseline.
- **Versioning docs:** bumped minimum Terraform version to **>= 1.12.2** in `VERSIONING.md` for the four modules.
- **Tests Go version:** standardized `modules/azurerm_virtual_network/tests/go.mod` to **go 1.21**.
- **Docs regenerated:** refreshed module README files to reflect the new provider pin.

## Validation

- `azurerm_route_table`: `terraform init -upgrade -backend=false`, `terraform validate`, `terraform test -test-directory=tests/unit` (34 passed)
- `azurerm_storage_account`: same flow, 37 passed
- `azurerm_subnet`: same flow, 35 passed
- `azurerm_virtual_network`: `terraform init -upgrade -backend=false`, `terraform validate` (no unit tests)
