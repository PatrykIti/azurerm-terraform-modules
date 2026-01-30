# TASK-ADO-032: Azure DevOps Artifacts Feed Module Audit Fixes
# FileName: TASK-ADO-032_AzureDevOps_Artifacts_Feed_Module_Audit_Fixes.md

**Priority:** 🟡 Medium
**Category:** Azure DevOps Modules
**Estimated Effort:** Small
**Dependencies:** None
**Status:** 🟢 **Done**

---

## Overview

Resolve audit findings for `modules/azuredevops_artifacts_feed` focused on
documentation consistency and cleanup of Terraform/test artifacts.

---

## Current Gaps

- Example READMEs show `../../` module sources and omit providers, while example
  `main.tf` uses `git::https` sources with an `azuredevops` provider.
- VERSIONING compatibility matrix references AzureRM provider and an outdated
  Terraform version instead of Azure DevOps provider 1.12.2 and Terraform >= 1.12.2.
- Module tree contains Terraform artifacts: `.terraform/`, `.terraform.lock.hcl`,
  and `tests/test_outputs/*.log`.

---

## Scope

- Remove Terraform/test artifacts from the module tree and keep them ignored.
- Regenerate example READMEs so module sources/providers match example configs.
- Fix VERSIONING compatibility matrix to reflect Azure DevOps provider and current
  Terraform minimum.

---

## Docs to Update

**In-module**
- `modules/azuredevops_artifacts_feed/examples/basic/README.md`
- `modules/azuredevops_artifacts_feed/examples/complete/README.md`
- `modules/azuredevops_artifacts_feed/examples/secure/README.md`
- `modules/azuredevops_artifacts_feed/VERSIONING.md`

**Outside**
- `docs/_TASKS/README.md`

---

## Acceptance Criteria

- Example READMEs show the `git::https` module source and list the `azuredevops`
  provider.
- VERSIONING compatibility matrix references `azuredevops` 1.12.2 and Terraform
  `>= 1.12.2` (no AzureRM references).
- `.terraform/`, `.terraform.lock.hcl`, and `tests/test_outputs/*.log` are removed
  and not reintroduced after doc/test runs.

---

## Implementation Checklist

- [x] Remove `modules/azuredevops_artifacts_feed/.terraform/`.
- [x] Remove `modules/azuredevops_artifacts_feed/.terraform.lock.hcl`.
- [x] Remove `modules/azuredevops_artifacts_feed/tests/test_outputs/*.log`.
- [x] Regenerate docs (`./scripts/update-module-docs.sh azuredevops_artifacts_feed`).
- [x] Update VERSIONING compatibility matrix to Azure DevOps provider + Terraform min.
- [x] Confirm example READMEs match current example `main.tf`.
