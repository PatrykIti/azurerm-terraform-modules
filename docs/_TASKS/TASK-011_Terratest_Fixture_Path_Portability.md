# TASK-011: Terratest Fixture Path Portability
# FileName: TASK-011_Terratest_Fixture_Path_Portability.md

**Priority:** 🟡 Medium
**Category:** Testing
**Estimated Effort:** Medium
**Dependencies:** None
**Status:** ✅ **Done** (2025-12-29)

---

## Overview

Remove hardcoded module paths in `test_structure.CopyTerraformFolderToTemp` calls so fixtures
are resolved relative to the test execution context (package dir). This improves portability
across local runs and CI and prevents future modules from embedding fixed paths.

## Scope

- `modules/*/tests/*.go`
- `scripts/templates/*.go`
- `docs/TESTING_GUIDE/*.md`

## Current Gaps (Summary)

- `_test.go` files hardcode module paths (e.g., `azuredevops_identity/tests/fixtures/basic`).
- Templates generate the same hardcoded paths, causing regressions in new modules.
- Testing guide examples still show the old pattern.

## Target State

- All `CopyTerraformFolderToTemp` calls use relative fixture paths (e.g., `fixtures/basic`)
  with a local root (`"."`), independent of module name.
- Template test files follow the same pattern.
- Testing guide examples match the updated approach.

## Implementation Checklist

- [x] Replace `CopyTerraformFolderToTemp(..., "../..", "MODULE/tests/fixtures/...")` with
      `CopyTerraformFolderToTemp(..., ".", "fixtures/...")` across all module tests.
- [x] Update fixture path variables/struct fields to `fixtures/...` where used.
- [x] Update `scripts/templates/*_test.go` and `scripts/templates/integration_test.go` /
      `performance_test.go` to the relative fixture pattern.
- [x] Update `docs/TESTING_GUIDE/*.md` examples to match the new fixture path pattern.
- [x] Verify no hardcoded module fixture paths remain (`rg "tests/fixtures" modules/*/tests`).
- [x] Update `docs/_TASKS/README.md`.

## Acceptance Criteria

- No `_test.go` file uses `module/tests/fixtures` paths in `CopyTerraformFolderToTemp`.
- Templates generate tests with relative fixture paths only.
- Testing guide examples use the new relative path pattern.
- `rg "tests/fixtures" modules/*/tests` returns no matches.
