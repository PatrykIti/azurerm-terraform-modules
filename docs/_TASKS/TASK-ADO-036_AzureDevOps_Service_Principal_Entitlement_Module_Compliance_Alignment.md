# TASK-ADO-036: Azure DevOps Service Principal Entitlement Module Compliance Alignment
# FileName: TASK-ADO-036_AzureDevOps_Service_Principal_Entitlement_Module_Compliance_Alignment.md

**Priority:** 🔴 High  
**Category:** Azure DevOps Modules  
**Estimated Effort:** Medium  
**Dependencies:** docs/MODULE_GUIDE, docs/TESTING_GUIDE, docs/TERRAFORM_BEST_PRACTICES_GUIDE.md, modules/azuredevops_group (tests baseline)  
**Status:** 🟡 To Do

---

## Overview

Bring `modules/azuredevops_service_principal_entitlement` to full repository standards. Fill in missing tests, fixtures, example docs, and automation so the module matches the structure and test rigor of `modules/azuredevops_group`.

## Current Gaps

- Examples missing `.terraform-docs.yml`.
- Main resource uses `for_each` over a list input; this module should manage a single entitlement resource (iteration belongs in the caller, aligned with `modules/azuredevops_group`).
- Tests layout incomplete: only `fixtures/basic`, no `complete`/`secure`, missing `test_outputs/` and `.gitignore`.
- Go tests are placeholders (`t.Skip`) and do not follow test-structure stages.
- Unit tests only cover defaults/validation; missing `naming` and `outputs`.
- `tests/README.md` and `test_config.yaml` do not describe or orchestrate Go tests.

## Scope

- Module: `modules/azuredevops_service_principal_entitlement/`
- Examples: `modules/azuredevops_service_principal_entitlement/examples/*`
- Tests: `modules/azuredevops_service_principal_entitlement/tests/`
- Docs: module README, tests README, examples README (where applicable)

## Docs to Update

### In-Module
- `modules/azuredevops_service_principal_entitlement/tests/README.md`
- `modules/azuredevops_service_principal_entitlement/examples/*/README.md`
- `modules/azuredevops_service_principal_entitlement/examples/*/.terraform-docs.yml`

### Repo-Level
- `docs/_TASKS/README.md`

## Work Items

- **Module API:** remove `for_each` from the primary `azuredevops_service_principal_entitlement` resource and switch to a single entitlement input object (caller iterates across modules as needed), matching the `azuredevops_group` pattern. Update README, inputs, outputs, and examples accordingly.
- **Examples:** add `.terraform-docs.yml` to `examples/basic|complete|secure`; ensure example READMEs include usage + cleanup and ADO prerequisites.
- **Fixtures:** add `tests/fixtures/complete` and `tests/fixtures/secure` (and `negative` if needed for validation), each with `main.tf`, `variables.tf`, `outputs.tf`. Use local module source and deterministic naming. Use dedicated service principal object IDs per scenario to avoid collisions.
- **Unit tests:** add `tests/unit/naming.tftest.hcl` (derived key logic) and `tests/unit/outputs.tftest.hcl` (map outputs, `try()` usage). Expand validation tests to cover invalid license types and empty `origin_id`.
- **Go tests:** replace placeholder tests with real Terratest suite using test-structure stages (`setup/deploy/validate/cleanup`), `t.Parallel()`, and fixtures for `basic`, `complete`, `secure`, plus a validation test for negative fixtures if created.
- **Helpers:** implement `getTerraformOptions`, env validation, and reusable output checks in `tests/test_helpers.go`. Mirror patterns in `modules/azuredevops_group/tests`.
- **Test orchestration:** align `tests/Makefile`, `run_tests_parallel.sh`, `run_tests_sequential.sh`, and `test_config.yaml` with `modules/azuredevops_group/tests` (logging, required env vars, suites for basic/complete/secure/validation/integration).
- **Test artifacts:** add `tests/test_outputs/.gitkeep` and `tests/.gitignore` (copy baseline from `modules/azuredevops_group/tests/.gitignore`).

## Test Environment Requirements

- Required env vars:
  - `AZDO_ORG_SERVICE_URL`
  - `AZDO_PERSONAL_ACCESS_TOKEN`
  - `AZDO_SERVICE_PRINCIPAL_ORIGIN_ID_BASIC`
  - `AZDO_SERVICE_PRINCIPAL_ORIGIN_ID_COMPLETE`
  - `AZDO_SERVICE_PRINCIPAL_ORIGIN_ID_SECURE`
- Optional: any additional IDs if `complete` uses multiple entitlements.

## Acceptance Criteria

- Module layout matches MODULE_GUIDE and TESTING_GUIDE for Azure DevOps modules.
- Primary resource is single-instance (no `for_each` on the main resource block); iteration happens in consuming configs, consistent with `modules/azuredevops_group`.
- `examples/*` include `.terraform-docs.yml` and updated READMEs.
- `tests/` includes `fixtures/basic|complete|secure`, `unit/defaults|naming|outputs|validation`, `.gitignore`, `test_outputs/`.
- Go tests run against real ADO with test-structure stages and validate outputs.
- `tests/README.md` documents Go + Terraform tests and required env vars.
- `test_config.yaml` defines suites for basic/complete/secure/validation/integration similar to `modules/azuredevops_group`.

## Implementation Checklist

- [ ] Add missing example `.terraform-docs.yml` and refresh example READMEs.
- [ ] Add fixtures: `tests/fixtures/complete`, `tests/fixtures/secure`, (optional `negative`).
- [ ] Add `tests/unit/naming.tftest.hcl` and `tests/unit/outputs.tftest.hcl`; extend validation.
- [ ] Implement Terratest suite in `tests/azuredevops_service_principal_entitlement_test.go`.
- [ ] Implement integration/performance tests with short-mode skips.
- [ ] Expand `tests/test_helpers.go` and `test_env.sh`.
- [ ] Align `tests/Makefile`, `run_tests_parallel.sh`, `run_tests_sequential.sh`, `test_config.yaml`.
- [ ] Add `tests/test_outputs/.gitkeep` + `tests/.gitignore`.
- [ ] Update `docs/_TASKS/README.md` task list/stats.

## Completion Requirements (Changelog)

- Create a new changelog entry in `docs/_CHANGELOG/` using the next sequential number and date slug.
- Update the index in `docs/_CHANGELOG/README.md` with the new entry.
