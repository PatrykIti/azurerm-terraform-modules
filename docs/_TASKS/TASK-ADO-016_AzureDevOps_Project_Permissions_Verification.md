# TASK-ADO-016: Azure DevOps Project Permissions module – verification & alignment
# FileName: TASK-ADO-016_AzureDevOps_Project_Permissions_Verification.md

**Priority:** 🟡 Medium  
**Category:** Module Cleanup / Documentation / Testing  
**Estimated Effort:** Small  
**Dependencies:** TASK-ADO-001  
**Status:** ✅ **Done** (2025-12-25)

---

## Cel

Dostosowac `modules/azuredevops_project_permissions` do wytycznych:
- `docs/MODULE_GUIDE/`
- `docs/TESTING_GUIDE/`
- `docs/TERRAFORM_BEST_PRACTICES_GUIDE.md`

oraz potwierdzic, ze testy i przyklady sa spójne z AKS baseline i repo standardami.

---

## Zakres i zmiany

1) **Examples**
   - Dodac `terraform { required_providers ... }` z `microsoft/azuredevops`.
   - Ujednolicic README w examples (features/usage/cleanup).

2) **Tests**
   - Fixtures z `required_providers` (unikamy `hashicorp/azuredevops`).
   - `tests/Makefile` zgodny z guide (nazwy testów, logi do `test_outputs`, cele `fmt/lint/ci`).
   - `run_tests_parallel.sh` i `run_tests_sequential.sh` jak w `azuredevops_project` (logi + JSON + env check).
   - `tests/README.md` spójne z Makefile (bez `test-all`/`test-short`).

3) **Inputs/Docs/Security**
   - Walidacje `trimspace` w `variables.tf`.
   - README: provider requirements w Usage.
   - SECURITY: referencja do `examples/secure`.

---

## Testy

- `terraform test -test-directory=tests/unit` (po `terraform init` w module).

---

## Definition of Done

- [x] Examples i fixtures z poprawnym `required_providers`.
- [x] Test scripts/Makefile/README spójne z `docs/TESTING_GUIDE/`.
- [x] README/SECURITY zgodne z `docs/MODULE_GUIDE/` i security baseline.
- [x] Unit tests uruchomione lokalnie.
