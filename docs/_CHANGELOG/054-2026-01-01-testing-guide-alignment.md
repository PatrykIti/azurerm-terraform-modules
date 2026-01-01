# Filename: 054-2026-01-01-testing-guide-alignment.md

# 054. Testing guide alignment (AKS + Azure DevOps)

**Date:** 2026-01-01  
**Type:** Maintenance / Documentation  
**Scope:** `docs/TESTING_GUIDE/*`, `docs/_TASKS/*`, `docs/_CHANGELOG/*`  
**Tasks:** TASK-013

---

## Key Changes

- Aligned the testing pyramid with current CI (integration tests are end-to-end per module, no separate E2E tier).
- Updated CI/CD guidance to match `pr-validation.yml` and `module-ci.yml` plus module-runner behavior.
- Added Azure DevOps-specific auth and fixture naming guidance alongside AzureRM patterns.
- Fixed fixture path examples and Terraform test CLI usage.
- Expanded troubleshooting to cover Azure DevOps auth and skipped tests.
