# TASK-047: Private Endpoint Compliance Re-Audit

## Overview

Re-audit and align `modules/azurerm_private_endpoint` with repository compliance requirements for `AUDIT_ONLY` mode against:

- `PRIMARY_RESOURCE=azurerm_private_endpoint`
- `PROVIDER_VERSION=4.57.0`

The module is structurally complete and functionally close to target, but has compliance drift in logic placement, validation rigor, and documentation/testing consistency.

## Current Gaps

1. Input-only rule duplication between `variables.tf` and `lifecycle.precondition` adds avoidable maintenance risk.
   - Evidence: `modules/azurerm_private_endpoint/variables.tf:73`, `modules/azurerm_private_endpoint/main.tf:69`
2. Some string validations allow whitespace/empty token edge cases that should be rejected before plan/apply.
   - Evidence: `modules/azurerm_private_endpoint/variables.tf:76`, `modules/azurerm_private_endpoint/variables.tf:100`
3. Resource local name (`main`) is not provider-aligned naming (`private_endpoint`) per repo naming guidance.
   - Evidence: `modules/azurerm_private_endpoint/main.tf:15`
4. Versioning document is stale versus pinned Terraform/provider versions.
   - Evidence: `modules/azurerm_private_endpoint/VERSIONING.md:120`, `modules/azurerm_private_endpoint/versions.tf:2`
5. Test docs/scripts are inconsistent with actual behavior.
   - Evidence: `modules/azurerm_private_endpoint/tests/README.md:106`, `modules/azurerm_private_endpoint/tests/private_endpoint_test.go:164`, `modules/azurerm_private_endpoint/tests/run_tests_parallel.sh:21`, `modules/azurerm_private_endpoint/tests/Makefile:185`
6. Test matrix versions in YAML are outdated relative to module requirement.
   - Evidence: `modules/azurerm_private_endpoint/tests/test_config.yaml:127`, `modules/azurerm_private_endpoint/versions.tf:2`

## Scope

In scope:

- Compliance-only updates for `modules/azurerm_private_endpoint` Terraform code, docs, examples/test docs, and test harness scripts.
- Naming/provider-alignment addendum cleanup for local resource naming consistency.
- Go tests + fixtures addendum conformance where applicable.

Out of scope:

- Expanding module ownership beyond `azurerm_private_endpoint`.
- Adding cross-resource glue (RBAC, DNS record management, networking modules, budgets).
- Broad repo-wide refactors outside direct references required for this module.

## Docs to Update

In-module:

- `modules/azurerm_private_endpoint/README.md`
- `modules/azurerm_private_endpoint/docs/README.md`
- `modules/azurerm_private_endpoint/docs/IMPORT.md`
- `modules/azurerm_private_endpoint/VERSIONING.md`
- `modules/azurerm_private_endpoint/tests/README.md`
- `modules/azurerm_private_endpoint/tests/test_config.yaml`

Outside module:

- `docs/_TASKS/README.md` (To Do row + counts, by coordinating agent)

## Acceptance Criteria

- Input-only constraints are enforced in `variables.tf`; `precondition` is used only for rules that cannot be validated as input.
- `azurerm_private_endpoint` capability exposure for provider `4.57.0` remains complete or omissions are explicitly documented with rationale.
- Resource/data local names follow provider-aligned naming convention consistently across code/docs/import examples.
- `VERSIONING.md`, test README guidance, and test matrix versions match actual module/tooling behavior.
- Test runner scripts reliably capture logs/errors and align with the repo testing Makefile conventions.
- Compliance status after remediation is at least:
  - Scope Status: `GREEN`
  - Provider Coverage Status: `GREEN`
  - Overall Status: `GREEN` (or `YELLOW` only with explicitly accepted follow-ups)

## Implementation Checklist

- [ ] Remove duplicated input-only checks from `main.tf` preconditions when equivalent validation already exists in `variables.tf`.
- [ ] Tighten validation for optional string fields (`private_connection_resource_id`, `private_connection_resource_alias`, `subresource_names`) to reject empty/whitespace values.
- [ ] Align local resource naming to provider-guided convention and update all dependent references/outputs/import docs.
- [ ] Refresh `VERSIONING.md` compatibility matrix to current pinned versions.
- [ ] Reconcile `tests/README.md` with real behavior (location defaults, teardown controls, commands).
- [ ] Fix `tests/run_tests_parallel.sh` log redirection and ensure test targets produce consistent logs.
- [ ] Align `tests/test_config.yaml` Terraform matrix with module requirements and supported CI policy.
- [ ] Re-run documentation generation (`make docs`) and confirm markers/sections remain valid.
- [ ] Execute compliance verification gates (`fmt`, `validate`, `terraform test`, `go test` compile) and attach results.
