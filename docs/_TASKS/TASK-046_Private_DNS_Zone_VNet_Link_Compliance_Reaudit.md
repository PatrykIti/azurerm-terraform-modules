# TASK-046: Private DNS Zone VNet Link Compliance Re-audit
# FileName: TASK-046_Private_DNS_Zone_VNet_Link_Compliance_Reaudit.md

**Priority:** High  
**Category:** Compliance / Re-audit Remediation  
**Estimated Effort:** Medium  
**Module:** `modules/azurerm_private_dns_zone_virtual_network_link`  
**Status:** To Do

---

## Overview

This task tracks remediation for an `AUDIT_ONLY` compliance review of:

- `MODULE_PATH=modules/azurerm_private_dns_zone_virtual_network_link`
- `PRIMARY_RESOURCE=azurerm_private_dns_zone_virtual_network_link`
- `PROVIDER_VERSION=4.57.0`

Audit outcome is **YELLOW** due to multiple medium-severity gaps in provider-capability alignment, test portability, and release/docs consistency.

---

## Current Gaps

1. **`resolution_policy` validation/docs are misaligned with provider/API capability.**
   - Module currently allows `Default` and `Recursive`.
   - Azure CLI for Private DNS VNet Link indicates allowed values `Default` and `NxDomainRedirect`.
   - Evidence:
     - `modules/azurerm_private_dns_zone_virtual_network_link/variables.tf:59`
     - `modules/azurerm_private_dns_zone_virtual_network_link/variables.tf:64`
     - `modules/azurerm_private_dns_zone_virtual_network_link/README.md:75`
     - `modules/azurerm_private_dns_zone_virtual_network_link/docs/README.md:16`

2. **Terratest fixture portability is broken for copied temp test runs.**
   - Tests copy from root `"."` while fixtures reference module source via `../../../`, which escapes copied folder structure.
   - Evidence:
     - `modules/azurerm_private_dns_zone_virtual_network_link/tests/private_dns_zone_virtual_network_link_test.go:21`
     - `modules/azurerm_private_dns_zone_virtual_network_link/tests/performance_test.go:19`
     - `modules/azurerm_private_dns_zone_virtual_network_link/tests/fixtures/basic/main.tf:34`
     - `modules/azurerm_private_dns_zone_virtual_network_link/tests/fixtures/complete/main.tf:34`
     - `modules/azurerm_private_dns_zone_virtual_network_link/tests/fixtures/secure/main.tf:34`

3. **Stale/out-of-scope network fixture contains unsupported module inputs.**
   - Uses `location` and `network_rules` inputs that this module does not expose.
   - Omits required resource inputs (`private_dns_zone_name`, `virtual_network_id`).
   - Evidence:
     - `modules/azurerm_private_dns_zone_virtual_network_link/tests/fixtures/network/main.tf:17`
     - `modules/azurerm_private_dns_zone_virtual_network_link/tests/fixtures/network/main.tf:19`

4. **Release tag prefix configuration is inconsistent with repository convention and docs.**
   - `module.json` uses `PDNSZLNK` (no trailing `v`) while docs/reference usage expect `PDNSZLNKv`.
   - Evidence:
     - `modules/azurerm_private_dns_zone_virtual_network_link/module.json:5`
     - `modules/azurerm_private_dns_zone_virtual_network_link/VERSIONING.md:10`
     - `modules/azurerm_private_dns_zone_virtual_network_link/docs/IMPORT.md:37`
     - `modules/README.md:38`

5. **Version/prerequisite documentation drift.**
   - Version compatibility matrix and tests README still mention older Terraform/provider ranges.
   - Evidence:
     - `modules/azurerm_private_dns_zone_virtual_network_link/VERSIONING.md:120`
     - `modules/azurerm_private_dns_zone_virtual_network_link/tests/README.md:8`

6. **Unit tests do not explicitly cover `resolution_policy` positive/negative validation paths.**
   - Evidence:
     - `modules/azurerm_private_dns_zone_virtual_network_link/tests/unit/validation.tftest.hcl:18`

---

## Scope

### In Scope

- Keep module atomic boundary to `azurerm_private_dns_zone_virtual_network_link`.
- Align `resolution_policy` behavior with provider/API capability for `azurerm` `4.57.0`.
- Fix Terratest fixture/copy path portability and remove or correct stale fixture content.
- Align release metadata (`tag_prefix`) and module-local docs with repo standards.
- Add missing unit-test coverage for `resolution_policy`.

### Out of Scope

- Adding new resources outside current module boundary.
- Refactoring unrelated modules.
- Changing public inputs/outputs beyond correctness/compliance fixes documented here.

---

## Docs to Update

### In-module

- `modules/azurerm_private_dns_zone_virtual_network_link/README.md`
- `modules/azurerm_private_dns_zone_virtual_network_link/docs/README.md`
- `modules/azurerm_private_dns_zone_virtual_network_link/docs/IMPORT.md`
- `modules/azurerm_private_dns_zone_virtual_network_link/VERSIONING.md`
- `modules/azurerm_private_dns_zone_virtual_network_link/tests/README.md`

### Outside module

- `modules/README.md` (tag prefix row consistency)
- `docs/_CHANGELOG/071-2026-01-30-private-dns-zone-vnet-link.md` (if tag-prefix examples are documented there)

---

## Acceptance Criteria

1. `resolution_policy` validation supports provider/API-correct values and rejects invalid ones.
2. README/docs descriptions for `resolution_policy` match implemented validation exactly.
3. Terratest copy strategy + fixture source paths work in temp-copy mode (no escaped module source path).
4. `tests/fixtures/network/main.tf` is either corrected to module scope or removed from active fixture inventory.
5. Unit tests include explicit positive and negative cases for `resolution_policy`.
6. `module.json.tag_prefix` decision is consistent with repository convention (`...v`) and semantic-release tag format.
7. Import/versioning/examples documentation uses the same tag-prefix convention as release config.
8. `VERSIONING.md` compatibility matrix reflects Terraform/provider versions used by the module.
9. `tests/README.md` prerequisites match current module/tooling requirements.
10. Compliance gate re-run reports no High findings and no unresolved Medium findings for this task scope.

---

## Implementation Checklist

- [ ] Confirm provider/schema semantics for `azurerm_private_dns_zone_virtual_network_link.resolution_policy` at `azurerm` `4.57.0` and document source.
- [ ] Update `variables.tf` validation and error messages for `resolution_policy`.
- [ ] Update module docs (`README.md`, `docs/README.md`) to match corrected enum and applicability notes.
- [ ] Add/update unit tests in `tests/unit/validation.tftest.hcl` for accepted and rejected `resolution_policy` values.
- [ ] Fix Terratest path model:
  - [ ] align `CopyTerraformFolderToTemp` root/fixture path strategy in Go tests,
  - [ ] ensure fixture `source` paths resolve in copied temp layout.
- [ ] Repair or remove stale `tests/fixtures/network/main.tf` so fixture set is in-module and runnable.
- [ ] Reconcile release metadata:
  - [ ] align `module.json.tag_prefix` with repo convention,
  - [ ] verify `.releaserc.js` tag output remains correct,
  - [ ] align `docs/IMPORT.md`, `VERSIONING.md`, and `modules/README.md`.
- [ ] Refresh docs via module doc automation and verify no marker drift.
- [ ] Run validation gates (or document environmental blockers):
  - [ ] `go test ./... -run '^$'` in module `tests/`,
  - [ ] `terraform test -test-directory=tests/unit`,
  - [ ] module `validate`/`fmt` checks.

