# TASK-ADO-019: Azure DevOps Artifacts Feed Module Refactor
# FileName: TASK-ADO-019_AzureDevOps_Artifacts_Feed_Module_Refactor.md

**Priority:** 🟡 Medium
**Category:** Azure DevOps Modules
**Estimated Effort:** Medium
**Dependencies:** TASK-ADO-011
**Status:** ✅ **Done** (2026-02-14)

---

## Overview

Refactor `modules/azuredevops_artifacts_feed` to align with MODULE_GUIDE/TESTING_GUIDE/TERRAFORM_BEST_PRACTICES: single primary feed resource, stable keys for child resources, strong validation, and refreshed docs/tests.

## Completion Summary

- Main resource is single and non-iterated: `azuredevops_feed.feed`.
- Child resources (`azuredevops_feed_permission`, `azuredevops_feed_retention_policy`) use stable map keys derived from explicit `key` fallbacks.
- Subresources are attached only to module-managed feed (`feed_id = azuredevops_feed.feed.id`).
- Input validation covers:
  - required non-empty `name`, `project_id`
  - allowed permission roles
  - positive retention limits
  - unique stable keys for permission/retention collections.
- Outputs expose single feed identity and stable child ID maps.
- Import docs include key derivation and matching import address examples.
- Examples/tests/docs are aligned with current interface.

## Provider Schema Note

`terraform providers schema` confirms `azuredevops_feed` attributes: `id`, `name`, `project_id`. The provider does not expose `description`, so it was not added to module inputs.

## Verification Evidence (2026-02-14)

- Provider schema check:
  - `terraform -chdir=modules/azuredevops_artifacts_feed providers schema -json` + jq over `azuredevops_feed.block.attributes`
  - result: `id`, `name`, `project_id`
- Full module gate executed successfully:
  - module `init` + `validate`
  - examples `basic|complete|secure` `init` + `validate`
  - `terraform test -test-directory=tests/unit`
  - integration compile: `go test -c -run 'Test.*Integration' ./...` in `modules/azuredevops_artifacts_feed/tests`
- Evidence log:
  - `/tmp/task_ado_019_checks_20260214_225819.log`

## Acceptance Criteria

- Module aligns with MODULE_GUIDE and TERRAFORM_BEST_PRACTICES. ✅
- Stable `for_each` keys for permissions/retention. ✅
- Feed inputs align with provider schema fields. ✅
- README + examples + `docs/IMPORT.md` updated. ✅
- Unit + integration compile checks passing. ✅

## Implementation Checklist

- [x] Update variables.tf: require name/project_id, remove external feed/project references from subresource inputs.
- [x] Refactor main.tf to single feed resource and module-owned child bindings.
- [x] Update outputs.tf to direct single-feed references and stable child maps.
- [x] Add/refresh `docs/IMPORT.md` and README docs sections.
- [x] Extend import docs with key-derivation examples and addresses.
- [x] Keep explicit comments in locals for stable key derivation.
- [x] Update examples (`basic`, `complete`, `secure`) to current interface.
- [x] Update tests (fixtures, unit, Terratest harness artifacts/config).
- [x] Run docs/tests validation gate and capture evidence.
