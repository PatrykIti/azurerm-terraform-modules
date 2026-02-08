# TASK-042: Linux Function App Compliance Reaudit
# FileName: TASK-042_Linux_Function_App_Compliance_Reaudit.md

**Priority:** High  
**Category:** Compliance / Reaudit  
**Estimated Effort:** Medium-Large  
**Dependencies:** TASK-036, TASK-041 (reference parity for Function App feature coverage)  
**Status:** To Do

---

## Overview

Reaudit `modules/azurerm_linux_function_app` in `AUDIT_ONLY` mode against:
- `docs/_PROMPTS/MODULE_AUDIT_TASK_PROMPT.md`
- `docs/MODULE_GUIDE/10-checklist.md`
- `docs/MODULE_GUIDE/11-scope-and-provider-coverage-status-check.md` (including addendums)

Target baseline:
- `PRIMARY_RESOURCE=azurerm_linux_function_app`
- `PROVIDER_VERSION=4.57.0`

Current status from audit:
- Scope Status: `YELLOW`
- Provider Coverage Status: `YELLOW`
- Overall Status: `YELLOW`

---

## Current Gaps

### Medium

1. Primary resource provider-coverage gaps: module does not expose several provider-supported capabilities for `azurerm_linux_function_app`:
- `sticky_settings`
- `storage_key_vault_secret_id`
- `virtual_network_backup_restore_enabled`
- `vnet_image_pull_enabled`
- `webdeploy_publish_basic_authentication_enabled`

2. Diagnostic settings implementation is not compliant with the repo diagnostic pattern:
- Uses `data.azurerm_monitor_diagnostic_categories` runtime discovery.
- Uses derived `areas` behavior instead of explicit validated categories.
- Missing pinned category allow-list validation in `variables.tf`.

3. Terratest compile gate fails (`go test ./... -run '^$'`), with unused vars/imports and missing `os` import in `tests/integration_test.go`.

4. Test harness drift against guide/addendum:
- `tests/Makefile` does not follow the standard logging wrapper pattern (`run_with_log`, normalized ARM/AZURE env handling, `test_outputs/all_*.log` behavior).
- `run_tests_parallel.sh` and `run_tests_sequential.sh` include a non-existent test name and use benchmark name under `-run`.

5. Tests/docs scope drift:
- `tests/integration_test.go` includes private-endpoint scenario scaffolding while private endpoint is out of module scope.
- `tests/README.md` references fixture/test targets that do not exist in current module test layout.

### Low

1. README examples block contains truncated descriptions for `complete` and `secure`.

2. `VERSIONING.md` compatibility matrix is stale vs module pinning (`azurerm 4.57.0`, Terraform `>= 1.12.2`).

---

## Scope

In scope for remediation:
1. Bring module coverage and diagnostics implementation into compliance for `azurerm_linux_function_app` (provider `4.57.0`).
2. Align tests, fixtures, scripts, and test docs with current testing guide/addendum.
3. Remove scope drift and stale documentation.

Out of scope:
1. Renaming module path, commit scope, or tag prefix.
2. Expanding module responsibility to private endpoints/RBAC/network glue resources.
3. Updating `docs/_TASKS/README.md` in this task (handled by parent consolidation workflow).

---

## Docs to Update (in-module + outside)

In-module:
1. `modules/azurerm_linux_function_app/README.md`
2. `modules/azurerm_linux_function_app/docs/README.md`
3. `modules/azurerm_linux_function_app/SECURITY.md`
4. `modules/azurerm_linux_function_app/VERSIONING.md`
5. `modules/azurerm_linux_function_app/tests/README.md`
6. Example READMEs impacted by diagnostics/feature changes (`examples/*/README.md` where applicable)

Outside module:
1. `docs/_CHANGELOG/README.md` (index update if new changelog entry is added)
2. New changelog entry under `docs/_CHANGELOG/` for compliance remediation

---

## Acceptance Criteria

1. Capability coverage matrix for `azurerm_linux_function_app` (provider `4.57.0`) shows all supported primary-resource capabilities as:
- Implemented, or
- Intentionally omitted with explicit rationale documented in module docs.

2. Diagnostics implementation complies with checklist/addendum:
- No runtime category discovery data source.
- Explicit input-driven categories.
- Category/group/metric validation pinned to provider/resource support.
- Destination semantics and empty-string rejection validated in `variables.tf`.

3. Scope integrity is preserved:
- No out-of-scope private-endpoint behavior in module tests/docs.
- Tests/fixtures reflect module atomic scope.

4. Test quality gate:
- `go test ./... -run '^$'` passes in `modules/azurerm_linux_function_app/tests`.
- Unit/integration docs and scripts reference real test targets/fixtures.
- Test logging behavior follows repo test harness conventions.

5. Documentation consistency:
- README markers and generated sections remain valid.
- Example list descriptions are complete and accurate.
- Versioning/provider compatibility text matches current module pinning.

---

## Implementation Checklist

- [ ] Build and document the explicit provider capability diff for `azurerm_linux_function_app` (`4.57.0`) and map to module inputs/blocks/outputs.
- [ ] Add/align missing primary-resource capabilities or document intentional omissions with rationale.
- [ ] Refactor diagnostics to explicit, deterministic input model; remove runtime category discovery.
- [ ] Add diagnostic validation coverage in unit tests (positive + negative paths).
- [ ] Fix Terratest compile errors in `tests/integration_test.go`.
- [ ] Align `tests/Makefile` with repository logging/env normalization pattern.
- [ ] Fix test runner scripts to call real test names and avoid invalid benchmark usage with `-run`.
- [ ] Remove or explicitly defer out-of-scope private-endpoint test scaffolding.
- [ ] Reconcile `tests/README.md` with actual fixtures/targets/files.
- [ ] Refresh module docs (`README`, `docs/README`, `SECURITY`, `VERSIONING`) and regenerate terraform-docs sections.
- [ ] Validate remediation with local gates (`terraform fmt/validate`, `terraform test`, Go compile gate), documenting environment-only blockers if any.
