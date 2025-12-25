# Filename: 022-2025-12-25-azuredevops-project-test-verification.md

# 022. Azure DevOps Project module test verification

**Date:** 2025-12-25  
**Type:** Maintenance / Verification  
**Scope:** `modules/azuredevops_project/tests/*`, `docs/_CHANGELOG/*`  
**Tasks:** TASK-ADO-001

---

## Key Changes

- **Verification:** confirmed `make test` execution against a real Azure DevOps org (projects created and deleted).
- **Fixtures:** added explicit provider source blocks to avoid defaulting to `hashicorp/azuredevops`.
- **Logs:** test output is persisted under `modules/azuredevops_project/tests/test_outputs/`.
