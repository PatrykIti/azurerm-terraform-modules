# TASK-043: Linux Virtual Machine Compliance Re-audit

**Module:** `modules/azurerm_linux_virtual_machine`  
**Mode:** `AUDIT_ONLY`  
**Primary Resource:** `azurerm_linux_virtual_machine`  
**Provider Version:** `azurerm` `4.57.0`

## Overview
This task captures remediation required after a compliance re-audit of `modules/azurerm_linux_virtual_machine` against:
- `docs/MODULE_GUIDE/10-checklist.md`
- `docs/MODULE_GUIDE/11-scope-and-provider-coverage-status-check.md` (including addendums)
- `docs/TESTING_GUIDE/README.md`
- `docs/TERRAFORM_BEST_PRACTICES_GUIDE.md`

Audit snapshot:
- Scope Status: `GREEN`
- Provider Coverage Status: `RED`
- Overall Status: `RED`

Note: direct provider schema pull (`terraform providers schema -json`) was blocked in this environment by offline registry access, so capability evidence is based on module code + repo standards.

## Current Gaps
### High
- Non-deterministic diagnostic category discovery is used (`data.azurerm_monitor_diagnostic_categories`) with runtime expansion via `areas`, which conflicts with the mandatory explicit-input diagnostics model.  
  Evidence: `modules/azurerm_linux_virtual_machine/diagnostics.tf:1`, `modules/azurerm_linux_virtual_machine/diagnostics.tf:11`, `modules/azurerm_linux_virtual_machine/diagnostics.tf:17`, `modules/azurerm_linux_virtual_machine/variables.tf:543`

### Medium
- Diagnostic settings schema/validation is incomplete for current checklist requirements:
  - no `partner_solution_id` input wiring,
  - no validation enforcing at least one log/metric/category-group per entry,
  - destination IDs are checked for `null` but not normalized against empty strings.
  Evidence: `modules/azurerm_linux_virtual_machine/variables.tf:546`, `modules/azurerm_linux_virtual_machine/variables.tf:571`, `modules/azurerm_linux_virtual_machine/variables.tf:595`, `modules/azurerm_linux_virtual_machine/diagnostics.tf:43`, `modules/azurerm_linux_virtual_machine/diagnostics.tf:65`
- Terratest fixture module `source` paths point to `../../` instead of the module root expected by the copy pattern (`../../../` for `tests/fixtures/*`), so fixtures resolve to `tests/` instead of the module directory.
  Evidence: `modules/azurerm_linux_virtual_machine/tests/linux_virtual_machine_test.go:22`, `modules/azurerm_linux_virtual_machine/tests/fixtures/basic/main.tf:68`, `modules/azurerm_linux_virtual_machine/tests/fixtures/complete/main.tf:101`, `modules/azurerm_linux_virtual_machine/tests/fixtures/secure/main.tf:59`
- Test runner scripts and YAML inventory reference non-existent test/benchmark names, reducing trust in automation output.
  Evidence: `modules/azurerm_linux_virtual_machine/tests/run_tests_parallel.sh:60`, `modules/azurerm_linux_virtual_machine/tests/run_tests_parallel.sh:62`, `modules/azurerm_linux_virtual_machine/tests/run_tests_parallel.sh:65`, `modules/azurerm_linux_virtual_machine/tests/run_tests_sequential.sh:40`, `modules/azurerm_linux_virtual_machine/tests/test_config.yaml:11`, `modules/azurerm_linux_virtual_machine/tests/test_config.yaml:26`
- `tests/Makefile` is not aligned with required Terratest logging/env-normalization pattern (`run_with_log`, `LOG_DIR`, ARM/AZURE normalization across targets).
  Evidence: `modules/azurerm_linux_virtual_machine/tests/Makefile:1`, `modules/azurerm_linux_virtual_machine/tests/Makefile:25`
- Release tag prefix is inconsistent with repo convention and module docs (`LINUXVM` vs `LINUXVMv`).
  Evidence: `modules/azurerm_linux_virtual_machine/module.json:5`, `modules/azurerm_linux_virtual_machine/VERSIONING.md:112`, `modules/README.md:22`

### Low
- Version compatibility table in module versioning doc is stale (`Terraform >= 1.3.0`, `azurerm 4.36.0`) relative to module pinning.
  Evidence: `modules/azurerm_linux_virtual_machine/VERSIONING.md:120`, `modules/azurerm_linux_virtual_machine/versions.tf:2`, `modules/azurerm_linux_virtual_machine/versions.tf:7`
- Main README does not link module `docs/README.md` in the additional documentation section.
  Evidence: `modules/azurerm_linux_virtual_machine/README.md:155`, `modules/azurerm_linux_virtual_machine/docs/README.md:1`

## Scope
In scope for remediation:
- Diagnostics model and validations (`variables.tf`, `diagnostics.tf`, README/docs/tests/examples as needed)
- Test harness correctness (`tests/fixtures`, `tests/Makefile`, `tests/run_tests_*.sh`, `tests/test_config.yaml`, unit/integration tests)
- Release metadata consistency (`module.json`, release/versioning docs)
- Documentation alignment with implemented behavior

Out of scope:
- Adding unrelated resources (networking glue, RBAC, private endpoints, budgets)
- Broad repo-wide refactors unrelated to this module

## Docs to Update
### In-module
- `modules/azurerm_linux_virtual_machine/README.md`
- `modules/azurerm_linux_virtual_machine/docs/README.md`
- `modules/azurerm_linux_virtual_machine/docs/IMPORT.md` (if import addresses/IDs change due diagnostics refactor)
- `modules/azurerm_linux_virtual_machine/SECURITY.md`
- `modules/azurerm_linux_virtual_machine/VERSIONING.md`
- `modules/azurerm_linux_virtual_machine/tests/README.md`

### Outside module
- `modules/README.md` (tag prefix consistency if changed)
- `README.md` (only if module release reference format changes)
- `docs/_CHANGELOG/*` entry for the compliance remediation release

## Acceptance Criteria
- Diagnostic settings are explicit-input driven and deterministic (no `azurerm_monitor_diagnostic_categories` data source in module).
- `diagnostic_settings` schema includes full destination support required by checklist (including `partner_solution_id`) and validates:
  - at least one category/group per entry,
  - destination coherence,
  - no empty-string destination IDs.
- Fixture `source` paths for module-under-test are corrected to resolve the module root after `CopyTerraformFolderToTemp`.
- `tests/run_tests_parallel.sh`, `tests/run_tests_sequential.sh`, and `tests/test_config.yaml` only reference real test/benchmark names.
- `tests/Makefile` follows required logging/env normalization pattern and writes logs under `tests/test_outputs/`.
- Release tag prefix metadata is internally consistent across `module.json`, docs, and indexes.
- Module docs are regenerated and consistent with actual implementation.

## Implementation Checklist
- [ ] Refactor diagnostics model to remove runtime category discovery and `areas`-driven expansion.
- [ ] Extend and harden `diagnostic_settings` input contract (`partner_solution_id`, non-empty destinations, category presence).
- [ ] Update diagnostics unit tests with positive/negative cases for category and destination validation.
- [ ] Correct fixture module `source` paths in `tests/fixtures/*/main.tf` for Terratest copy semantics.
- [ ] Align `tests/Makefile` to the standard Terratest pattern (`SHELL := /bin/bash`, `LOG_DIR`, `run_with_log`, ARM/AZURE normalization).
- [ ] Synchronize test inventories in `run_tests_parallel.sh`, `run_tests_sequential.sh`, and `test_config.yaml` with actual Go tests/benchmarks.
- [ ] Fix tag prefix consistency (`LINUXVMv` format) and align release/versioning docs.
- [ ] Regenerate module and example docs, then verify README markers and examples list remain correct.
- [ ] Run validation gates (`terraform fmt`, `terraform validate`, `terraform test`, `go test` compile/integration as environment allows) and record residual environmental blockers.
