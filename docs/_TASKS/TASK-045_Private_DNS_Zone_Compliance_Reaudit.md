# TASK-045: Private DNS Zone Compliance Re-audit

## Overview

Re-audit remediation plan for `modules/azurerm_private_dns_zone` in `AUDIT_ONLY` mode against:
- `docs/_PROMPTS/MODULE_AUDIT_TASK_PROMPT.md`
- `docs/MODULE_GUIDE/10-checklist.md`
- `docs/MODULE_GUIDE/11-scope-and-provider-coverage-status-check.md` (including naming/provider-alignment and Go tests/fixtures addendums)

The module is structurally close to standard and keeps atomic scope, but has multiple compliance gaps in testing quality, docs accuracy, and provider-coverage validation evidence.

## Current Gaps

1. **Invalid/out-of-scope fixture and broken scenario wiring**
- `tests/fixtures/network/main.tf` passes unsupported module arguments (`location`, `network_rules`) and uses an invalid zone name format for this resource, so this fixture cannot represent valid module behavior and is out-of-scope for `azurerm_private_dns_zone`.

2. **Terratest suite quality and coverage gaps**
- `tests/integration_test.go` is only `t.Skip(...)` placeholder and does not provide real integration assertions.
- `tests/private_dns_zone_test.go` has mostly non-specific assertions (`NotEmpty`) and TODO-level validation comments, so major implemented behaviors (SOA propagation, tags semantics, output correctness beyond existence) are not thoroughly asserted.

3. **Go tests + fixtures addendum non-compliance in fixture documentation/consistency**
- `tests/README.md` describes “network connectivity”, “monitoring and logging validation”, and similar scenarios that are not implemented for this module scope.
- `tests/test_config.yaml` lists Terraform versions (`1.5.x`, `1.6.x`, `1.7.x`) and environment expectations that drift from module pinning (`>= 1.12.2`) and current harness behavior.

4. **Module docs drift from actual release/version baseline**
- `VERSIONING.md` compatibility matrix still references older provider/version values (`4.36.0`, `>= 1.3.0`) and includes examples that imply scope not managed by this module (e.g., private endpoint support wording).

5. **Provider-coverage matrix not documented in-module**
- The module implements core `azurerm_private_dns_zone` arguments/blocks (`name`, `resource_group_name`, `soa_record`, `tags`, `timeouts`), but explicit “intentionally omitted / not applicable” capability mapping is not documented in module docs, which weakens repeatable audit evidence.

## Scope

### In scope
- `modules/azurerm_private_dns_zone/**` (module-local remediation work only)
- Documentation and tests alignment with module atomic boundary (`azurerm_private_dns_zone` only)
- Coverage evidence for AzureRM `4.57.0` provider capabilities

### Out of scope
- Implementing adjacent modules (`azurerm_private_dns_zone_virtual_network_link`, DNS record modules, private endpoint, RBAC, budgets)
- Repo-wide task index updates by this worker (parent agent handles `docs/_TASKS/README.md`)

## Docs to Update

### In-module docs
- `modules/azurerm_private_dns_zone/tests/README.md`
- `modules/azurerm_private_dns_zone/tests/test_config.yaml`
- `modules/azurerm_private_dns_zone/VERSIONING.md`
- `modules/azurerm_private_dns_zone/docs/README.md` (add provider capability mapping summary)
- `modules/azurerm_private_dns_zone/README.md` (if capability omissions/rationale are surfaced there)

### Outside module
- Optional follow-up decision note in central guidance if maintainers want a standard template for capability matrix persistence per module (no file mandated in this task).

## Acceptance Criteria

- `tests/fixtures/network/main.tf` is either removed or replaced with a valid, in-scope scenario for `azurerm_private_dns_zone` (no unsupported inputs).
- Terratest suite contains at least one non-placeholder integration flow and explicit assertions for implemented feature groups (SOA options, tags, key outputs).
- `tests/README.md` and `tests/test_config.yaml` accurately reflect real tests, supported scenarios, and Terraform/provider version baselines.
- `VERSIONING.md` compatibility matrix and examples match current module requirements (`terraform >= 1.12.2`, `azurerm 4.57.0`) and do not imply out-of-scope capabilities.
- Module documentation includes explicit provider capability coverage notes for `azurerm_private_dns_zone` (implemented vs intentionally omitted/not applicable) aligned with checklist 11 matrix expectations.
- Addendum checks pass for naming/provider alignment and Go tests/fixtures consistency.

## Implementation Checklist

- [ ] Remove or refactor invalid network fixture (`tests/fixtures/network/main.tf`) to in-scope valid inputs only.
- [ ] Replace `t.Skip` placeholder in `tests/integration_test.go` with executable integration test logic or consolidate by removing dead entry and documenting actual coverage approach.
- [ ] Strengthen assertions in `tests/private_dns_zone_test.go` to validate concrete behavior (SOA fields, deterministic output expectations, tags).
- [ ] Align `tests/README.md` scenario descriptions with actual implemented tests and module scope boundaries.
- [ ] Update `tests/test_config.yaml` Terraform version matrix and scenario lists to match current module/tooling reality.
- [ ] Correct outdated version/provider references and misleading examples in `VERSIONING.md`.
- [ ] Add provider capability coverage section to module docs (`docs/README.md` and/or `README.md`) for AzureRM `4.57.0`.
- [ ] Run static verification for touched docs/tests (format/lint where applicable) and confirm no out-of-scope resources are introduced.
