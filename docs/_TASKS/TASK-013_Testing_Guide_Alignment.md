# TASK-013: Testing Guide Alignment (AKS + Azure DevOps)
# FileName: TASK-013_Testing_Guide_Alignment.md

**Priority:** 🟡 Medium
**Category:** Documentation / Standards
**Estimated Effort:** Medium
**Dependencies:** —
**Status:** ✅ **Done** (2026-01-01)

---

## Overview

Align `docs/TESTING_GUIDE/*` with the real testing patterns used in
`modules/azurerm_kubernetes_cluster` and `modules/azuredevops_repository`,
including CI workflows, test structure, helpers, fixtures, and provider-specific
authentication.

---

## Scope

1) **Testing Pyramid**
   - Collapse E2E into integration (per-module end-to-end).
   - Update execution strategy to match actual GitHub Actions workflows.

2) **Unit Tests**
   - Correct CLI usage for running specific tests.
   - Include Azure DevOps mock provider examples.

3) **Terratest Integration**
   - Document AzureRM vs Azure DevOps authentication requirements.
   - Clarify that `test_env.sh` is a committed template and local overrides are untracked.

4) **Fixtures & Naming**
   - Keep AKS naming patterns for AzureRM fixtures.
   - Add Azure DevOps fixture naming rules and examples.

5) **CI/CD**
   - Update workflow docs to match `pr-validation.yml` and `module-ci.yml`.
   - Document module-runner behavior and security scan outputs.

6) **Troubleshooting**
   - Add Azure DevOps auth failures and skipped-test guidance.

---

## Acceptance Criteria

- All `docs/TESTING_GUIDE/*` sections match current workflows and module test patterns.
- Azure DevOps provider requirements are documented alongside AzureRM guidance.
- No references to standalone E2E tiers that do not exist in CI.
- Examples use correct fixture paths and current Terraform CLI flags.

---

## Implementation Checklist

- [x] Update `docs/TESTING_GUIDE/README.md`.
- [x] Update `docs/TESTING_GUIDE/01-testing-philosophy.md`.
- [x] Update `docs/TESTING_GUIDE/02-test-organization.md`.
- [x] Update `docs/TESTING_GUIDE/03-native-terraform-tests.md`.
- [x] Update `docs/TESTING_GUIDE/04-terratest-integration-overview.md`.
- [x] Update `docs/TESTING_GUIDE/05-terratest-file-structure.md`.
- [x] Update `docs/TESTING_GUIDE/06-terratest-helpers-and-validation.md`.
- [x] Update `docs/TESTING_GUIDE/07-terratest-fixtures-and-execution.md`.
- [x] Update `docs/TESTING_GUIDE/08-advanced-testing.md`.
- [x] Update `docs/TESTING_GUIDE/09-cicd-integration.md`.
- [x] Update `docs/TESTING_GUIDE/10-troubleshooting-guide.md`.

---

## Docs to Update After Completion

- `docs/_TASKS/README.md` (add task row, update counters)
- `docs/_CHANGELOG/README.md` (add new entry)
- `docs/_CHANGELOG/054-2026-01-01-testing-guide-alignment.md` (new changelog item)
